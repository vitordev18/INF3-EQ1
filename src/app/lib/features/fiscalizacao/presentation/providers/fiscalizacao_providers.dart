import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import 'package:app/core/services/yolo_service.dart';
import 'package:app/features/dof/data/models/dof_item_model.dart';
import 'package:app/features/dof/presentation/providers/dof_providers.dart';
import 'package:app/features/fiscalizacao/data/datasources/fiscalizacao_local_datasource.dart';
import 'package:app/features/fiscalizacao/data/models/fiscalizacao_registro_model.dart';
import 'package:app/features/fiscalizacao/domain/entities/status_fiscalizacao.dart';

// ─── Edit action sealed class (para undo) ─────────────────────────────────────

sealed class FiscEditAction {}

class FiscAddedDetections extends FiscEditAction {
  final List<Recognition> added;
  FiscAddedDetections(this.added);
}

class FiscRemovedDetection extends FiscEditAction {
  final Recognition removed;
  final int originalIndex;
  FiscRemovedDetection(this.removed, this.originalIndex);
}

class FiscMovedDetection extends FiscEditAction {
  final Recognition oldDetection;
  final Recognition newDetection;
  FiscMovedDetection(this.oldDetection, this.newDetection);
}

// ─── Data classes ─────────────────────────────────────────────────────────────

class FotoSession {
  final File imageFile;
  final img.Image? decodedImage;
  final List<Recognition> detections;
  final List<FiscEditAction> undoStack;
  final List<Rect> savedRegions;
  final bool awaitingRegionSelection;

  const FotoSession({
    required this.imageFile,
    this.decodedImage,
    this.detections = const [],
    this.undoStack = const [],
    this.savedRegions = const [],
    this.awaitingRegionSelection = true,
  });

  int get count => detections.length;
  int get width => decodedImage?.width ?? 640;
  int get height => decodedImage?.height ?? 640;

  FotoSession copyWith({
    File? imageFile,
    img.Image? decodedImage,
    List<Recognition>? detections,
    List<FiscEditAction>? undoStack,
    List<Rect>? savedRegions,
    bool? awaitingRegionSelection,
  }) =>
      FotoSession(
        imageFile: imageFile ?? this.imageFile,
        decodedImage: decodedImage ?? this.decodedImage,
        detections: detections ?? this.detections,
        undoStack: undoStack ?? this.undoStack,
        savedRegions: savedRegions ?? this.savedRegions,
        awaitingRegionSelection:
            awaitingRegionSelection ?? this.awaitingRegionSelection,
      );
}

class CapturaState {
  final List<FotoSession> fotos;
  final int currentIndex;
  final bool isProcessing;
  final bool modelReady;
  final bool modelError;
  final bool isEditMode;
  final bool isRegionMode;
  final Rect? draggingRegion;

  const CapturaState({
    this.fotos = const [],
    this.currentIndex = 0,
    this.isProcessing = false,
    this.modelReady = false,
    this.modelError = false,
    this.isEditMode = false,
    this.isRegionMode = false,
    this.draggingRegion,
  });

  int get totalCount => fotos.fold(0, (s, f) => s + f.count);

  FotoSession? get current =>
      fotos.isEmpty ? null : fotos[currentIndex];

  CapturaState copyWith({
    List<FotoSession>? fotos,
    int? currentIndex,
    bool? isProcessing,
    bool? modelReady,
    bool? modelError,
    bool? isEditMode,
    bool? isRegionMode,
    // Use a nullable getter pattern to allow explicit null assignment
    Object? draggingRegion = _sentinel,
  }) =>
      CapturaState(
        fotos: fotos ?? this.fotos,
        currentIndex: currentIndex ?? this.currentIndex,
        isProcessing: isProcessing ?? this.isProcessing,
        modelReady: modelReady ?? this.modelReady,
        modelError: modelError ?? this.modelError,
        isEditMode: isEditMode ?? this.isEditMode,
        isRegionMode: isRegionMode ?? this.isRegionMode,
        draggingRegion: draggingRegion == _sentinel
            ? this.draggingRegion
            : draggingRegion as Rect?,
      );
}

const Object _sentinel = Object();

// ─── Providers ────────────────────────────────────────────────────────────────

final yoloServiceProvider = Provider<YoloService>((ref) => YoloService());

final fiscalizacaoLocalDatasourceProvider =
    Provider<FiscalizacaoLocalDatasource>((ref) {
  final isarService = ref.watch(isarServiceProvider);
  return FiscalizacaoLocalDatasource(isarService);
});

final registroPorItemProvider =
    FutureProvider.family<FiscalizacaoRegistroModel?, String>(
  (ref, dofItemId) {
    final ds = ref.watch(fiscalizacaoLocalDatasourceProvider);
    return ds.getByDofItemId(dofItemId);
  },
);

final capturaNotifierProvider =
    AutoDisposeNotifierProvider<CapturaNotifier, CapturaState>(
  CapturaNotifier.new,
);

// ─── Notifier ─────────────────────────────────────────────────────────────────

class CapturaNotifier extends AutoDisposeNotifier<CapturaState> {
  late YoloService _yolo;
  static const int _maxUndoDepth = 20;

  @override
  CapturaState build() {
    _yolo = ref.read(yoloServiceProvider);
    return const CapturaState();
  }

  Future<void> initModel() async {
    try {
      await _yolo.init();
      state = state.copyWith(modelReady: true);
    } catch (e) {
      debugPrint('[Captura] Erro ao inicializar modelo: $e');
      state = state.copyWith(modelError: true);
    }
  }

  // Adds photo WITHOUT running YOLO — user must tap "Detectar"
  Future<void> addPhoto(File file) async {
    state = state.copyWith(isProcessing: true);
    try {
      final bytes = await file.readAsBytes();
      final decoded = img.decodeImage(bytes);
      final session = FotoSession(
        imageFile: file,
        decodedImage: decoded,
        awaitingRegionSelection: true,
      );
      final newFotos = [...state.fotos, session];
      state = state.copyWith(
        fotos: newFotos,
        currentIndex: newFotos.length - 1,
        isProcessing: false,
        isEditMode: false,
        isRegionMode: false,
        draggingRegion: null,
      );
    } catch (e) {
      debugPrint('[Captura] Erro ao processar foto: $e');
      state = state.copyWith(isProcessing: false);
    }
  }

  // Runs YOLO on saved regions (or full image if no regions selected)
  Future<void> confirmRegionAndProcess() async {
    final session = state.current;
    if (session == null) return;

    final idx = state.currentIndex;
    var newFotos = [...state.fotos];
    newFotos[idx] = session.copyWith(awaitingRegionSelection: false);
    state = state.copyWith(
      fotos: newFotos,
      isRegionMode: false,
      isProcessing: true,
      draggingRegion: null,
    );

    try {
      final decoded = state.fotos[idx].decodedImage ??
          img.decodeImage(await session.imageFile.readAsBytes());
      if (decoded == null) {
        state = state.copyWith(isProcessing: false);
        return;
      }

      final regions = session.savedRegions.isNotEmpty
          ? session.savedRegions
          : [const Rect.fromLTWH(0, 0, 1, 1)];

      final List<Recognition> allDetections = [];

      for (final region in regions) {
        List<Recognition> detections;
        if (region.left == 0 &&
            region.top == 0 &&
            region.right == 1 &&
            region.bottom == 1) {
          detections = await _yolo.runInference(decoded);
        } else {
          final rx = (region.left * decoded.width).round();
          final ry = (region.top * decoded.height).round();
          final rw =
              (region.width * decoded.width).round().clamp(1, decoded.width);
          final rh = (region.height * decoded.height)
              .round()
              .clamp(1, decoded.height);
          final cropped =
              img.copyCrop(decoded, x: rx, y: ry, width: rw, height: rh);
          final regional = await _yolo.runInference(cropped);
          detections = regional
              .map((d) => Recognition(
                    d.classId,
                    d.label,
                    d.score,
                    Rect.fromLTRB(
                      region.left + d.location.left * region.width,
                      region.top + d.location.top * region.height,
                      region.left + d.location.right * region.width,
                      region.top + d.location.bottom * region.height,
                    ),
                    angle: d.angle,
                  ))
              .toList();
        }

        for (final newD in detections) {
          final isDup = allDetections.any((e) =>
              YoloService.iou(newD.location, e.location) >
              YoloService.nmsThreshold);
          if (!isDup) allDetections.add(newD);
        }
      }

      newFotos = [...state.fotos];
      newFotos[idx] = state.fotos[idx].copyWith(
        detections: allDetections,
        undoStack: [],
        decodedImage: decoded,
      );
      state = state.copyWith(fotos: newFotos, isProcessing: false);
    } catch (e) {
      debugPrint('[Captura] Erro ao processar: $e');
      state = state.copyWith(isProcessing: false);
    }
  }

  void addSavedRegion(Rect region) {
    if (state.fotos.isEmpty) return;
    final idx = state.currentIndex;
    final session = state.fotos[idx];
    final newFotos = [...state.fotos];
    newFotos[idx] =
        session.copyWith(savedRegions: [...session.savedRegions, region]);
    state = state.copyWith(fotos: newFotos);
  }

  void removeSavedRegion(int regionIndex) {
    if (state.fotos.isEmpty) return;
    final idx = state.currentIndex;
    final session = state.fotos[idx];
    if (regionIndex < 0 || regionIndex >= session.savedRegions.length) return;
    final region = session.savedRegions[regionIndex];
    final newRegions = [...session.savedRegions]..removeAt(regionIndex);
    final newDetections = session.detections.where((r) {
      final cx = (r.location.left + r.location.right) / 2;
      final cy = (r.location.top + r.location.bottom) / 2;
      return !region.contains(Offset(cx, cy));
    }).toList();
    final newFotos = [...state.fotos];
    newFotos[idx] =
        session.copyWith(savedRegions: newRegions, detections: newDetections);
    state = state.copyWith(fotos: newFotos);
  }

  void setDraggingRegion(Rect? region) {
    state = state.copyWith(draggingRegion: region);
  }

  void setIsRegionMode(bool value) {
    state = state.copyWith(
      isRegionMode: value,
      isEditMode: value ? false : state.isEditMode,
    );
  }

  void removePhoto(int index) {
    if (index < 0 || index >= state.fotos.length) return;
    final newFotos = [...state.fotos]..removeAt(index);
    final newIndex = newFotos.isEmpty
        ? 0
        : (index >= newFotos.length ? newFotos.length - 1 : index);
    state = state.copyWith(
      fotos: newFotos,
      currentIndex: newIndex,
      isEditMode: false,
      isRegionMode: false,
    );
  }

  void clearAll() {
    final wasReady = state.modelReady;
    state = CapturaState(modelReady: wasReady);
  }

  void navigateTo(int index) {
    if (index < 0 || index >= state.fotos.length) return;
    state = state.copyWith(
      currentIndex: index,
      isEditMode: false,
      isRegionMode: false,
      draggingRegion: null,
    );
  }

  void toggleEditMode() {
    state = state.copyWith(
      isEditMode: !state.isEditMode,
      isRegionMode: false,
    );
  }

  void undo() {
    if (state.fotos.isEmpty) return;
    final idx = state.currentIndex;
    final session = state.fotos[idx];
    if (session.undoStack.isEmpty) return;
    final action = session.undoStack.last;
    final newStack = session.undoStack.sublist(0, session.undoStack.length - 1);
    List<Recognition> newDets = [...session.detections];
    switch (action) {
      case FiscRemovedDetection(:final removed, :final originalIndex):
        newDets.insert(originalIndex.clamp(0, newDets.length), removed);
      case FiscAddedDetections(:final added):
        newDets.removeWhere(added.contains);
      case FiscMovedDetection(:final oldDetection, :final newDetection):
        final i = newDets.indexOf(newDetection);
        if (i >= 0) newDets[i] = oldDetection;
    }
    final newFotos = [...state.fotos];
    newFotos[idx] = session.copyWith(detections: newDets, undoStack: newStack);
    state = state.copyWith(fotos: newFotos);
  }

  void addManualDetection(int fotoIndex, Rect normalizedLocation) {
    if (fotoIndex < 0 || fotoIndex >= state.fotos.length) return;
    final session = state.fotos[fotoIndex];
    final label = _yolo.labels.isNotEmpty ? _yolo.labels[0] : 'madeira';
    final newDet = Recognition(0, label, 1.0, normalizedLocation);
    final newDets = [...session.detections, newDet];
    var newStack = [...session.undoStack, FiscAddedDetections([newDet])];
    if (newStack.length > _maxUndoDepth) newStack = newStack.sublist(1);
    final newFotos = [...state.fotos];
    newFotos[fotoIndex] =
        session.copyWith(detections: newDets, undoStack: newStack);
    state = state.copyWith(fotos: newFotos);
  }

  void removeDetection(int fotoIndex, int detectionIndex) {
    if (fotoIndex < 0 || fotoIndex >= state.fotos.length) return;
    final session = state.fotos[fotoIndex];
    if (detectionIndex < 0 || detectionIndex >= session.detections.length) {
      return;
    }
    final removed = session.detections[detectionIndex];
    final newDets = [...session.detections]..removeAt(detectionIndex);
    var newStack = [
      ...session.undoStack,
      FiscRemovedDetection(removed, detectionIndex),
    ];
    if (newStack.length > _maxUndoDepth) newStack = newStack.sublist(1);
    final newFotos = [...state.fotos];
    newFotos[fotoIndex] =
        session.copyWith(detections: newDets, undoStack: newStack);
    state = state.copyWith(fotos: newFotos);
  }

  void moveDetectionCommit(
      int fotoIndex, Recognition oldDet, Recognition newDet) {
    if (fotoIndex < 0 || fotoIndex >= state.fotos.length) return;
    final session = state.fotos[fotoIndex];
    final i = session.detections.indexOf(oldDet);
    if (i < 0) return;
    final newDets = [...session.detections];
    newDets[i] = newDet;
    var newStack = [
      ...session.undoStack,
      FiscMovedDetection(oldDet, newDet),
    ];
    if (newStack.length > _maxUndoDepth) newStack = newStack.sublist(1);
    final newFotos = [...state.fotos];
    newFotos[fotoIndex] =
        session.copyWith(detections: newDets, undoStack: newStack);
    state = state.copyWith(fotos: newFotos);
  }

  Size averageDetectionSize() {
    final results = state.current?.detections ?? [];
    if (results.isEmpty) return const Size(0.06, 0.06);
    final avgW =
        results.map((r) => r.location.width).reduce((a, b) => a + b) /
            results.length;
    final avgH =
        results.map((r) => r.location.height).reduce((a, b) => a + b) /
            results.length;
    return Size(avgW.clamp(0.01, 0.5), avgH.clamp(0.01, 0.5));
  }

  Future<void> saveCaptura(
    DofItemModel dofItem,
    FiscalizacaoLocalDatasource datasource,
  ) async {
    state = state.copyWith(isProcessing: true);
    try {
      final docsDir = await getApplicationDocumentsDirectory();
      final photoDir =
          Directory('${docsDir.path}/fiscalizacao/${dofItem.id}');
      await photoDir.create(recursive: true);

      final savedPaths = <String>[];
      final detecoesPorFoto = <String>[];
      for (int i = 0; i < state.fotos.length; i++) {
        final session = state.fotos[i];
        final timestamp = DateTime.now().millisecondsSinceEpoch + i;
        final destPath = '${photoDir.path}/$timestamp.jpg';
        if (!session.imageFile.path.startsWith(docsDir.path)) {
          await session.imageFile.copy(destPath);
          savedPaths.add(destPath);
        } else {
          savedPaths.add(session.imageFile.path);
        }
        detecoesPorFoto.add(
          jsonEncode(session.detections.map((r) => r.toJson()).toList()),
        );
      }

      final totalCount = state.totalCount;
      final status = totalCount <= dofItem.saldoTotal
          ? StatusFiscalizacao.concluido
          : StatusFiscalizacao.excedente;

      final existing = await datasource.getByDofItemId(dofItem.id);

      final registro = FiscalizacaoRegistroModel(
        id: existing?.id ?? const Uuid().v4(),
        dofItemId: dofItem.id,
        contagemTotal: totalCount,
        fotoPaths: savedPaths,
        dataCaptura: DateTime.now(),
        status: status,
        detecoesPorFoto: detecoesPorFoto,
      );
      if (existing != null) {
        registro.isarId = existing.isarId;
      }

      await datasource.saveRegistro(registro);
      state = state.copyWith(isProcessing: false);
    } catch (e) {
      debugPrint('[Captura] Erro ao salvar: $e');
      state = state.copyWith(isProcessing: false);
    }
  }
}
