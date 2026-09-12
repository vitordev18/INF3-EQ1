import 'package:flutter/material.dart';

class Recognition {
  final int classId;
  final String label;
  final double score;
  final Rect location;

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
