import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class Recognition {
  final int classId;
  final String label;
  final double score;
  final Rect location; // Coordenadas normalizadas 0.0 a 1.0

  /// Ângulo de rotação em RADIANOS (apenas modelos OBB).
  /// null para modelos regulares.
  final double? angle;

  bool get isOBB => angle != null;

  Recognition(
    this.classId,
    this.label,
    this.score,
    this.location, {
    this.angle,
  });

  Map<String, dynamic> toJson() => {
        'classId': classId,
        'label': label,
        'score': score,
        'left': location.left,
        'top': location.top,
        'right': location.right,
        'bottom': location.bottom,
        if (angle != null) 'angle': angle,
      };

  factory Recognition.fromJson(Map<String, dynamic> json) => Recognition(
        json['classId'] as int,
        json['label'] as String,
        (json['score'] as num).toDouble(),
        Rect.fromLTRB(
          (json['left'] as num).toDouble(),
          (json['top'] as num).toDouble(),
          (json['right'] as num).toDouble(),
          (json['bottom'] as num).toDouble(),
        ),
        angle: json['angle'] != null ? (json['angle'] as num).toDouble() : null,
      );
}

// ─── Tipo do modelo detectado automaticamente ──────────────────────────────
enum YoloModelType { regular, obb }

class YoloService {
  Interpreter? _interpreter;
  List<String> _labels = [];

  List<String> get labels => _labels;

  static const int inputSize = 640;
  static const double confidenceThreshold = 0.25;
  static const double nmsThreshold = 0.30;

  bool _isNCHW = false;
  YoloModelType _modelType = YoloModelType.regular;

  int _numRows = 6;
  int _numAnchors = 8400;
  int _numClasses = 80;

  Future<void> init() async {
    _interpreter = await Interpreter.fromAsset(
      'assets/models/yolo_madeira2.tflite',
    );

    final labelsData = await rootBundle.loadString('assets/models/labels.txt');
    _labels = labelsData
        .split('\n')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final inputShape = _interpreter!.getInputTensor(0).shape;
    _isNCHW = (inputShape.length == 4 && inputShape[1] == 3);

    final outputShape = _interpreter!.getOutputTensor(0).shape;
    _numRows = outputShape[1];
    _numAnchors = outputShape[2];

    if (_numRows == 85) {
      _modelType = YoloModelType.obb;
      _numClasses = _numRows - 5;
    } else {
      _modelType = YoloModelType.regular;
      _numClasses = _numRows - 4;
    }

    if (_labels.length != _numClasses) {
      debugPrint(
        '[YOLO] AVISO: labels.txt tem ${_labels.length} classes, '
        'mas o modelo espera $_numClasses. Ajuste o labels.txt!',
      );
    }

    debugPrint(
      '[YOLO] Input shape  : $inputShape  =>  '
      '${_isNCHW ? "NCHW" : "NHWC"}',
    );
    debugPrint(
      '[YOLO] Output shape : $outputShape  =>  '
      '${_modelType.name.toUpperCase()} | '
      '$_numClasses classes | $_numAnchors anchors',
    );
  }

  Future<List<Recognition>> runInference(img.Image image) async {
    if (_interpreter == null || _labels.isEmpty) return [];

    final img.Image resized = img.copyResize(
      image,
      width: inputSize,
      height: inputSize,
      interpolation: img.Interpolation.linear,
    );

    List inputTensor;
    if (_isNCHW) {
      inputTensor = List.generate(
        1,
        (_) => List.generate(
          3,
          (c) => List.generate(
            inputSize,
            (y) => List.generate(inputSize, (x) {
              final p = resized.getPixel(x, y);
              return c == 0
                  ? p.r / 255.0
                  : c == 1
                  ? p.g / 255.0
                  : p.b / 255.0;
            }),
          ),
        ),
      );
    } else {
      inputTensor = List.generate(
        1,
        (_) => List.generate(
          inputSize,
          (y) => List.generate(inputSize, (x) {
            final p = resized.getPixel(x, y);
            return [p.r / 255.0, p.g / 255.0, p.b / 255.0];
          }),
        ),
      );
    }

    final output = List.generate(
      1,
      (_) => List.generate(_numRows, (_) => List.filled(_numAnchors, 0.0)),
    );

    _interpreter!.run(inputTensor, output);

    final raw = output[0];

    final coordsAreNormalized = _detectIfNormalized(raw);

    final List<Recognition> candidates = [];

    for (int i = 0; i < _numAnchors; i++) {
      final int scoreOffset = _modelType == YoloModelType.obb ? 5 : 4;

      int bestClass = 0;
      double bestScore = 0.0;
      for (int c = 0; c < _numClasses; c++) {
        final s = raw[scoreOffset + c][i];
        if (s > bestScore) {
          bestScore = s;
          bestClass = c;
        }
      }

      if (bestScore < confidenceThreshold) continue;

      final double cx = raw[0][i];
      final double cy = raw[1][i];
      final double w = raw[2][i];
      final double h = raw[3][i];

      final double? theta = _modelType == YoloModelType.obb ? raw[4][i] : null;

      final double divisor = coordsAreNormalized ? 1.0 : inputSize.toDouble();

      final double left = ((cx - w / 2) / divisor).clamp(0.0, 1.0);
      final double top = ((cy - h / 2) / divisor).clamp(0.0, 1.0);
      final double right = ((cx + w / 2) / divisor).clamp(0.0, 1.0);
      final double bottom = ((cy + h / 2) / divisor).clamp(0.0, 1.0);

      if (right <= left || bottom <= top) continue;
      if (bestClass >= _labels.length) continue;

      candidates.add(
        Recognition(
          bestClass,
          _labels[bestClass],
          bestScore,
          Rect.fromLTRB(left, top, right, bottom),
          angle: theta,
        ),
      );
    }

    return _applyNMS(candidates);
  }

  bool _detectIfNormalized(List<List<double>> raw) {
    int pixelCount = 0;
    int normalCount = 0;
    int sampled = 0;

    final int scoreOffset = _modelType == YoloModelType.obb ? 5 : 4;

    for (int i = 0; i < _numAnchors && sampled < 20; i++) {
      double maxScore = 0.0;
      for (int c = 0; c < min(_numClasses, 80); c++) {
        final s = raw[scoreOffset + c][i];
        if (s > maxScore) maxScore = s;
      }
      if (maxScore < 0.1) continue;

      final double cx = raw[0][i];
      if (cx > 1.5) {
        pixelCount++;
      } else {
        normalCount++;
      }
      sampled++;
    }

    return normalCount >= pixelCount;
  }

  // Fraction of a box's area that must be covered by a higher-score box
  // to suppress it even when IoU is below nmsThreshold.
  static const double _containmentThreshold = 0.75;

  List<Recognition> _applyNMS(List<Recognition> candidates) {
    if (candidates.isEmpty) return [];

    final Map<int, List<Recognition>> byClass = {};
    for (final c in candidates) {
      byClass.putIfAbsent(c.classId, () => []).add(c);
    }

    final List<Recognition> out = [];
    for (final boxes in byClass.values) {
      boxes.sort((a, b) => b.score.compareTo(a.score));
      final suppressed = List.filled(boxes.length, false);
      for (int i = 0; i < boxes.length; i++) {
        if (suppressed[i]) continue;
        out.add(boxes[i]);
        for (int j = i + 1; j < boxes.length; j++) {
          if (suppressed[j]) continue;
          if (YoloService.iou(boxes[i].location, boxes[j].location) >
              nmsThreshold) {
            suppressed[j] = true;
          } else if (_overlapFraction(boxes[j].location, boxes[i].location) >
              _containmentThreshold) {
            // boxes[j] is mostly covered by the higher-score boxes[i]
            suppressed[j] = true;
          }
        }
      }
    }
    return out;
  }

  /// Fraction of [target]'s area that is covered by [reference].
  static double _overlapFraction(Rect target, Rect reference) {
    final l = max(target.left, reference.left);
    final t = max(target.top, reference.top);
    final r = min(target.right, reference.right);
    final b = min(target.bottom, reference.bottom);
    if (r <= l || b <= t) return 0.0;
    final inter = (r - l) * (b - t);
    final targetArea = target.width * target.height;
    return targetArea <= 0 ? 0.0 : inter / targetArea;
  }

  static double iou(Rect a, Rect b) {
    final l = max(a.left, b.left);
    final t = max(a.top, b.top);
    final r = min(a.right, b.right);
    final bt = min(a.bottom, b.bottom);
    if (r <= l || bt <= t) return 0.0;
    final inter = (r - l) * (bt - t);
    final union = a.width * a.height + b.width * b.height - inter;
    return union <= 0 ? 0.0 : inter / union;
  }
}
