import 'package:fiscaliza/core/ml/recognition.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import 'package:app/core/services/yolo_service.dart';
import 'package:app/features/dof/data/models/dof_item_model.dart';
import 'package:app/features/dof/presentation/providers/dof_providers.dart';
import 'package:app/features/fiscalizacao/data/datasources/fiscalizacao_local_datasource.dart';
import 'package:app/features/fiscalizacao/data/datasources/fiscalizacao_sessao_local_datasource.dart';
import 'package:app/features/fiscalizacao/data/models/fiscalizacao_registro_model.dart';
import 'package:app/features/fiscalizacao/data/models/fiscalizacao_sessao_model.dart';
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
  final bool isDirty;

  const CapturaState({
    this.fotos = const [],
    this.currentIndex = 0,
    this.isProcessing = false,
    this.modelReady = false,
    this.modelError = false,
    this.isEditMode = false,
    this.isRegionMode = false,
    this.draggingRegion,
    this.isDirty = false,
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
    bool? isDirty,
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
        isDirty: isDirty ?? this.isDirty,
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

// ─── Sessão de fiscalização (lote por import DOF) ─────────────────────────────

final fiscalizacaoSessaoLocalDatasourceProvider =
    Provider<FiscalizacaoSessaoLocalDatasource>((ref) {
  final isarService = ref.watch(isarServiceProvider);
  return FiscalizacaoSessaoLocalDatasource(isarService);
});

/// Sessão em andamento (se houver), exibida no banner de aviso do Hub de
/// Início. Após criar ou encerrar uma sessão, invalide este provider
/// (`ref.invalidate(sessaoAtivaProvider)`) para refletir a mudança na UI.
final sessaoAtivaProvider = FutureProvider<FiscalizacaoSessaoModel?>((ref) {
  final ds = ref.watch(fiscalizacaoSessaoLocalDatasourceProvider);
  return ds.getSessaoAtiva();
});

/// Últimas fiscalizações concluídas, para a seção "Últimas Fiscalizações" do
/// Hub de Início. Invalide (`ref.invalidate(sessoesRecentesProvider)`) após
/// `encerrarSessao()` para refletir a nova entrada.
final sessoesRecentesProvider =
    FutureProvider<List<FiscalizacaoSessaoModel>>((ref) {
  final ds = ref.watch(fiscalizacaoSessaoLocalDatasourceProvider);
  return ds.getSessoesRecentes();
});

/// Itens DOF da sessão ativa — o que a FiscalizacaoHubScreen deve listar.
///
/// [parsedDofItemsProvider] (em dof_providers.dart) hidrata com TODOS os
/// `DofItemModel` persistidos, sem noção de sessão — de propósito, para não
/// criar uma dependência de dof_providers.dart sobre este arquivo
/// (fiscalizacao depende de dof, não o contrário). Este provider soma essa
/// lista com [sessaoAtivaProvider] para filtrar só os itens da fiscalização
/// em andamento.
final itensDaSessaoAtivaProvider = Provider<List<DofItemModel>>((ref) {
  final sessaoAtiva = ref.watch(sessaoAtivaProvider).value;
  if (sessaoAtiva == null) return const [];
  final todosOsItens = ref.watch(parsedDofItemsProvider);
  return todosOsItens
      .where((item) => item.sessaoId == sessaoAtiva.id)
      .toList();
});

/// Progresso ao vivo da sessão ativa — (concluídos, total) — para o texto
/// "X de Y itens concluídos" do banner de aviso do Hub de Início.
///
/// Não pode vir dos snapshots de [FiscalizacaoSessaoModel]: esses só são
/// preenchidos em `encerrarSessao()`, ficando `null` enquanto a sessão está
/// em andamento (é justamente esse o momento em que o banner aparece). Por
/// isso este provider recalcula a partir dos registros de cada item — igual
/// à contagem feita em `encerrarSessao()`, mas sem persistir nada. "Concluído"
/// aqui conta tanto `concluido` quanto `excedente`: ambos são estados
/// terminais (o item já foi fotografado e processado), diferindo apenas em
/// ter ou não excedido o saldo declarado.
final progressoSessaoAtivaProvider =
    FutureProvider<(int concluidos, int total)>((ref) async {
  final itens = ref.watch(itensDaSessaoAtivaProvider);
  if (itens.isEmpty) return (0, 0);
  final ds = ref.watch(fiscalizacaoLocalDatasourceProvider);
  final registros = await Future.wait(
    itens.map((item) => ds.getByDofItemId(item.id)),
  );
  final concluidos = registros
      .where((r) =>
          r?.status == StatusFiscalizacao.concluido ||
          r?.status == StatusFiscalizacao.excedente)
      .length;
  return (concluidos, itens.length);
});

/// Resumo completo da sessão ativa — (total, concluídos, excedentes,
/// pendentes) — para o card de estatísticas da ConcluirFiscalizacaoScreen.
///
/// Usa exatamente a mesma regra de contagem de
/// [FiscalizacaoSessaoLocalDatasource.encerrarSessao] (`emAndamento`,
/// `pendente` e "sem registro" contam todos como pendente), para que os
/// números mostrados antes de concluir batam com o snapshot gravado no
/// instante em que o usuário efetivamente encerra a sessão.
final resumoSessaoAtivaProvider = FutureProvider<
    (int total, int concluidos, int excedentes, int pendentes)>((ref) async {
  final itens = ref.watch(itensDaSessaoAtivaProvider);
  if (itens.isEmpty) return (0, 0, 0, 0);
  final ds = ref.watch(fiscalizacaoLocalDatasourceProvider);
  final registros = await Future.wait(
    itens.map((item) => ds.getByDofItemId(item.id)),
  );
  var concluidos = 0;
  var excedentes = 0;
  var pendentes = 0;
  for (final r in registros) {
    switch (r?.status) {
      case StatusFiscalizacao.concluido:
        concluidos++;
        break;
      case StatusFiscalizacao.excedente:
        excedentes++;
        break;
      case StatusFiscalizacao.emAndamento:
      case StatusFiscalizacao.pendente:
      case null:
        pendentes++;
        break;
    }
  }
  return (itens.length, concluidos, excedentes, pendentes);
});

final capturaNotifierProvider =
    NotifierProvider<CapturaNotifier, CapturaState>(
  CapturaNotifier.new,
);

class CapturaViewModel extends Notifier<CapturaState> {
  late YoloService _yolo;
  static const int _maxUndoDepth = 20;

  List<Rect>? _regionEditSnapshot;
  List<Recognition>? _detectionsEditSnapshot;

  @override
  CapturaState build() {
    _yolo = ref.read(yoloServiceProvider);
    _regionEditSnapshot = null;
    _detectionsEditSnapshot = null;
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

  Future<void> addPhoto(File file) async {
    state = state.copyWith(isProcessing: true);
    try {
      final bytes = await file.readAsBytes();
      final decoded = await compute(img.decodeImage, bytes);
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
        isDirty: true,
      );
    } catch (e) {
      debugPrint('[Captura] Erro ao processar foto: $e');
      state = state.copyWith(isProcessing: false);
    }
  }

  Future<void> confirmRegionAndProcess() async {
    final session = state.current;
    if (session == null) return;

    _regionEditSnapshot = null;
    _detectionsEditSnapshot = null;

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

      final regions = session.savedRegions;

      final allRaw = await _yolo.runInference(decoded);

      final List<Recognition> allDetections;
      if (regions.isEmpty) {
        allDetections = allRaw;
      } else {
        allDetections = allRaw.where((d) {
          final cx = (d.location.left + d.location.right) / 2;
          final cy = (d.location.top + d.location.bottom) / 2;
          return regions.any((r) => r.contains(Offset(cx, cy)));
        }).toList();
      }

      newFotos = [...state.fotos];
      newFotos[idx] = state.fotos[idx].copyWith(
        detections: allDetections,
        undoStack: [],
        decodedImage: decoded,
      );
      state = state.copyWith(
        fotos: newFotos,
        isProcessing: false,
        isDirty: true,
      );
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
    state = state.copyWith(fotos: newFotos, isDirty: true);
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
    state = state.copyWith(fotos: newFotos, isDirty: true);
  }

  void discardDraggedRegion(Rect region) {
    if (state.fotos.isEmpty) return;
    final idx = state.currentIndex;
    final session = state.fotos[idx];
    final newDetections = session.detections.where((r) {
      final cx = (r.location.left + r.location.right) / 2;
      final cy = (r.location.top + r.location.bottom) / 2;
      return !region.contains(Offset(cx, cy));
    }).toList();
    final newFotos = [...state.fotos];
    newFotos[idx] = session.copyWith(detections: newDetections);
    state = state.copyWith(
      fotos: newFotos,
      draggingRegion: null,
      isDirty: true,
    );
  }

  void setDraggingRegion(Rect? region) {
    state = state.copyWith(draggingRegion: region);
  }

  Rect? beginEditRegion(int regionIndex) {
    if (state.fotos.isEmpty) return null;
    final idx = state.currentIndex;
    final session = state.fotos[idx];
    if (regionIndex < 0 || regionIndex >= session.savedRegions.length) {
      return null;
    }
    final region = session.savedRegions[regionIndex];
    final newRegions = [...session.savedRegions]..removeAt(regionIndex);
    final newFotos = [...state.fotos];
    newFotos[idx] = session.copyWith(savedRegions: newRegions);
    state = state.copyWith(fotos: newFotos, draggingRegion: region);
    return region;
  }

  void setIsRegionMode(bool value) {
    if (value) {
      final session = state.current;
      _regionEditSnapshot = session?.savedRegions;
      _detectionsEditSnapshot = session?.detections;
    }
    state = state.copyWith(
      isRegionMode: value,
      isEditMode: value ? false : state.isEditMode,
    );
  }

  void cancelRegionMode() {
    if (state.fotos.isEmpty) return;
    final idx = state.currentIndex;
    final session = state.fotos[idx];
    final newFotos = [...state.fotos];
    newFotos[idx] = session.copyWith(
      savedRegions: _regionEditSnapshot ?? session.savedRegions,
      detections: _detectionsEditSnapshot ?? session.detections,
    );
    _regionEditSnapshot = null;
    _detectionsEditSnapshot = null;
    state = state.copyWith(
      fotos: newFotos,
      isRegionMode: false,
      draggingRegion: null,
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
      isDirty: true,
    );
  }

  Future<void> removePhotoAndCleanup(
    int index,
    String dofItemId,
    FiscalizacaoRepository datasource,
  ) async {
    if (index < 0 || index >= state.fotos.length) return;
    await datasource.deleteMedicoesDaFoto(dofItemId, index);
    await datasource.reindexMedicoesAposRemocao(dofItemId, index);
    removePhoto(index);
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
    final List<Recognition> newDets = [...session.detections];
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
    state = state.copyWith(fotos: newFotos, isDirty: true);
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
    state = state.copyWith(fotos: newFotos, isDirty: true);
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
    state = state.copyWith(fotos: newFotos, isDirty: true);
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
    state = state.copyWith(fotos: newFotos, isDirty: true);
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
    FiscalizacaoRepository datasource,
  ) async {
    state = state.copyWith(isProcessing: true);
    try {
      final docsDir = await getApplicationDocumentsDirectory();
      final photoDir =
          Directory('${docsDir.path}/fiscalizacao/${dofItem.id}');
      await photoDir.create(recursive: true);

      final savedPaths = <String>[];
      final detecoesPorFoto = <String>[];
      final regioesPorFoto = <String>[];
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
        regioesPorFoto.add(
          jsonEncode(session.savedRegions
              .map((rect) => [rect.left, rect.top, rect.right, rect.bottom])
              .toList()),
        );
      }

      final totalCount = state.totalCount;

      final existing = await datasource.getByDofItemId(dofItem.id);
      final registro = FiscalizacaoRegistroModel(
        id: existing?.id ?? const Uuid().v4(),
        dofItemId: dofItem.id,
        contagemTotal: totalCount,
        fotoPaths: savedPaths,
        dataCaptura: DateTime.now(),
        status: existing?.status ?? StatusFiscalizacao.emAndamento,
        detecoesPorFoto: detecoesPorFoto,
        regioesPorFoto: regioesPorFoto,
        volumeTotalM3: existing?.volumeTotalM3 ?? 0.0,
      );
      if (existing != null) registro.isarId = existing.isarId;
      await datasource.saveRegistro(registro);

      await datasource.recalcularEPersistirVolume(dofItem, totalCount);
      state = state.copyWith(isProcessing: false, isDirty: false);
    } catch (e) {
      debugPrint('[Captura] Erro ao salvar: $e');
      state = state.copyWith(isProcessing: false);
    }
  }

  Future<void> loadFromExisting(FiscalizacaoRegistroModel registro) async {
    state = state.copyWith(isProcessing: true);
    try {
      final sessions = <FotoSession>[];
      for (var i = 0; i < registro.fotoPaths.length; i++) {
        final file = File(registro.fotoPaths[i]);
        if (!await file.exists()) continue;

        final bytes = await file.readAsBytes();
        final decoded = await compute(img.decodeImage, bytes);
        if (decoded == null) continue;

        List<Recognition> detections = [];
        if (i < registro.detecoesPorFoto.length) {
          final list = jsonDecode(registro.detecoesPorFoto[i]) as List;
          detections = list
              .map((j) => Recognition.fromJson(j as Map<String, dynamic>))
              .toList();
        }

        List<Rect> savedRegions = [];
        if (i < registro.regioesPorFoto.length) {
          final list = jsonDecode(registro.regioesPorFoto[i]) as List;
          savedRegions = list
              .map((region) {
                final r = region as List;
                if (r.length == 4) {
                  return Rect.fromLTRB(
                    (r[0] as num).toDouble(),
                    (r[1] as num).toDouble(),
                    (r[2] as num).toDouble(),
                    (r[3] as num).toDouble(),
                  );
                }
                return null;
              })
              .whereType<Rect>()
              .toList();
        }

        sessions.add(FotoSession(
          imageFile: file,
          decodedImage: decoded,
          detections: detections,
          savedRegions: savedRegions,
          awaitingRegionSelection: false,
        ));
      }

      state = state.copyWith(
        fotos: sessions,
        currentIndex: sessions.isNotEmpty ? sessions.length - 1 : 0,
        isProcessing: false,
        isEditMode: false,
        isRegionMode: false,
        isDirty: false,
      );
    } catch (e) {
      debugPrint('[Captura] Erro ao carregar registro existente: $e');
      state = state.copyWith(isProcessing: false);
    }
  }
}
