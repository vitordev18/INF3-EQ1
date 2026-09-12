import 'package:fiscaliza/features/fiscalizacao/presentation/captura/widgets/thumbnail_strip.dart';
import 'package:fiscaliza/design_system/components/auto_dismiss_hint.dart';
import 'package:fiscaliza/design_system/painters/region_selector_painter.dart';
import 'package:fiscaliza/features/fiscalizacao/presentation/captura/widgets/header_card.dart';
import 'package:fiscaliza/core/ml/recognition.dart';
import 'dart:async';
import 'dart:io';
import 'dart:math' show min;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import 'package:fiscaliza/design_system/theme/app_colors.dart';
import 'package:fiscaliza/design_system/dialogs/confirm_dialog.dart';
import 'package:fiscaliza/design_system/components/app_scaffold.dart';
import 'package:fiscaliza/design_system/painters/bounding_box_painter.dart';
import 'package:fiscaliza/design_system/components/upload_area.dart';
import 'package:fiscaliza/features/dof/data/models/dof_item_model.dart';
import 'package:fiscaliza/features/fiscalizacao/data/fiscalizacao_providers.dart';
import 'package:fiscaliza/features/fiscalizacao/presentation/captura/captura_state.dart';
import 'package:fiscaliza/features/fiscalizacao/presentation/captura/captura_view_model.dart';
import 'package:fiscaliza/features/fiscalizacao/presentation/captura/foto_session.dart';

class CapturaScreen extends ConsumerStatefulWidget {
  final DofItemModel dofItem;

  const CapturaScreen({super.key, required this.dofItem});

  @override
  ConsumerState<CapturaScreen> createState() => _CapturaScreenState();
}

enum _RegionHandle {
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
  top,
  bottom,
  left,
  right,
}

enum _RegionDragKind { creating, resizing, moving }

const double _kMinRegionSize = 0.02;

const double _kRegionHandleTouchRadius = 18.0;

const double _kTrashIconDiameter = 56.0;
const double _kTrashIconBottomMargin = 24.0;

const double _kTrashHitRadius = 42.0;

class _CapturaScreenState extends ConsumerState<CapturaScreen> {
  final _transformController = TransformationController();
  final _picker = ImagePicker();

  int? _draggingCircleIndex;
  Recognition? _draggingOriginalDetection;
  Offset? _draggingCenterOverride;
  bool _significantDrag = false;
  Size? _currentWidgetSize;
  bool _hasExistingSession = false;

  _RegionDragKind? _regionDragKind;
  Offset? _regionStartPoint;
  Rect? _regionOriginalRect;
  _RegionHandle? _regionActiveHandle;

  bool _overTrashZone = false;

  int _activePointerCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final notifier = ref.read(capturaViewModelProvider.notifier);
      await notifier.initModel();

      final ds = ref.read(fiscalizacaoRepositoryProvider);
      final existing = await ds.getByDofItemId(widget.dofItem.id);
      if (existing != null && mounted) {
        setState(() => _hasExistingSession = true);
        await notifier.loadFromExisting(existing);
      }
    });
  }

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  List<Recognition> _resultsForDisplay(FotoSession session) {
    final results = session.detections;
    if (_draggingCircleIndex == null || _draggingCenterOverride == null) {
      return results;
    }
    final list = List<Recognition>.from(results);
    final old = list[_draggingCircleIndex!];
    list[_draggingCircleIndex!] = Recognition(
      old.classId,
      old.label,
      old.score,
      Rect.fromCenter(
        center: _draggingCenterOverride!,
        width: old.location.width,
        height: old.location.height,
      ),
      angle: old.angle,
    );
    return list;
  }

  int? _hitTestCircle(Offset localPosition, {double extraPadding = 16.0}) {
    if (_currentWidgetSize == null) return null;
    final session = ref.read(capturaViewModelProvider).current;
    if (session == null) return null;
    final results = session.detections;
    for (int i = results.length - 1; i >= 0; i--) {
      final d = results[i];
      final cx =
          (d.location.left + d.location.right) / 2 * _currentWidgetSize!.width;
      final cy =
          (d.location.top + d.location.bottom) / 2 * _currentWidgetSize!.height;
      final bw = d.location.width * _currentWidgetSize!.width;
      final bh = d.location.height * _currentWidgetSize!.height;
      final drawnRadius = (min(bw, bh) * 0.30).clamp(5.0, 11.0);
      final hitR = drawnRadius + extraPadding;
      final dx = localPosition.dx - cx;
      final dy = localPosition.dy - cy;
      if (dx * dx + dy * dy <= hitR * hitR) return i;
    }
    return null;
  }

  _RegionHandle? _handleNear(Rect rectPx, Offset point, double tolerance) {
    final candidates = <_RegionHandle, Offset>{
      _RegionHandle.topLeft: Offset(rectPx.left, rectPx.top),
      _RegionHandle.topRight: Offset(rectPx.right, rectPx.top),
      _RegionHandle.bottomLeft: Offset(rectPx.left, rectPx.bottom),
      _RegionHandle.bottomRight: Offset(rectPx.right, rectPx.bottom),
      _RegionHandle.top: Offset(rectPx.center.dx, rectPx.top),
      _RegionHandle.bottom: Offset(rectPx.center.dx, rectPx.bottom),
      _RegionHandle.left: Offset(rectPx.left, rectPx.center.dy),
      _RegionHandle.right: Offset(rectPx.right, rectPx.center.dy),
    };
    _RegionHandle? best;
    double bestDistSq = tolerance * tolerance;
    for (final entry in candidates.entries) {
      final distSq = (entry.value - point).distanceSquared;
      if (distSq <= bestDistSq) {
        bestDistSq = distSq;
        best = entry.key;
      }
    }
    return best;
  }

  ({int index, _RegionHandle handle})? _hitTestRegionHandle(
    Offset localPosition,
    List<Rect> savedRegions,
    Size widgetSize,
  ) {
    for (int i = savedRegions.length - 1; i >= 0; i--) {
      final r = savedRegions[i];
      final rectPx = Rect.fromLTRB(
        r.left * widgetSize.width,
        r.top * widgetSize.height,
        r.right * widgetSize.width,
        r.bottom * widgetSize.height,
      );
      final handle = _handleNear(
        rectPx,
        localPosition,
        _kRegionHandleTouchRadius,
      );
      if (handle != null) return (index: i, handle: handle);
    }
    return null;
  }

  int? _hitTestRegionInterior(
    Offset localPosition,
    List<Rect> savedRegions,
    Size widgetSize,
  ) {
    final fx = localPosition.dx / widgetSize.width;
    final fy = localPosition.dy / widgetSize.height;
    for (int i = savedRegions.length - 1; i >= 0; i--) {
      if (savedRegions[i].contains(Offset(fx, fy))) return i;
    }
    return null;
  }

  String _getSummary(FotoSession session, bool isProcessing) {
    if (isProcessing) return 'Processando...';
    final results = session.detections;
    if (results.isEmpty) return 'Nenhum objeto detectado.';
    final Map<String, int> counts = {};
    for (final r in results) {
      counts[r.label] = (counts[r.label] ?? 0) + 1;
    }
    return counts.entries.map((e) => '${e.value}x ${e.key}').join('  |  ');
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source, maxWidth: 1280);
    if (picked == null || !mounted) return;
    _transformController.value = Matrix4.identity();
    await ref
        .read(capturaViewModelProvider.notifier)
        .addPhoto(File(picked.path));
  }

  void _showImageSourceSheet() {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: const Text('Galeria'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded),
              title: const Text('Câmera'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveAndPop() async {
    final state = ref.read(capturaViewModelProvider);

    final ds = ref.read(fiscalizacaoRepositoryProvider);
    final totalMedido = await ds.getTotalMedidoByDofItem(widget.dofItem.id);
    final totalContado = state.totalCount;

    if (totalContado > 0 && totalMedido < totalContado) {
      if (!mounted) return;
      final continuar = await showConfirmDialog(
        context,
        title: 'Medição incompleta',
        message:
            'Foram contadas $totalContado peças, mas apenas $totalMedido foram medidas. '
            'O status da fiscalização permanecerá como "Em Andamento".',
        confirmLabel: 'Salvar',
        variant: ConfirmDialogVariant.danger,
      );
      if (!continuar || !mounted) return;
    }

    await ref
        .read(capturaViewModelProvider.notifier)
        .saveCaptura(widget.dofItem, ds);
    if (!mounted) return;
    ref.invalidate(registroPorItemProvider(widget.dofItem.id));
    Navigator.of(context).pop();
  }

  Future<void> _handleBackPress() async {
    final hasChanges = ref.read(capturaViewModelProvider).isDirty;
    if (!hasChanges) {
      Navigator.of(context).pop();
      return;
    }
    final discard = await showConfirmDialog(
      context,
      title: 'Sair sem salvar?',
      message:
          'As fotos e detecções desta sessão ainda não foram salvas. '
          'Se sair agora, elas serão perdidas.',
      confirmLabel: 'Sair sem salvar',
      variant: ConfirmDialogVariant.danger,
    );
    if (discard && mounted) Navigator.of(context).pop();
  }

  Future<void> _confirmDeletePhoto(int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remover foto?'),
        content: const Text('Esta foto e suas detecções serão removidas.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remover', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final ds = ref.read(fiscalizacaoRepositoryProvider);
    await ref
        .read(capturaViewModelProvider.notifier)
        .removePhotoAndCleanup(index, widget.dofItem.id, ds);
    final totalCount = ref.read(capturaViewModelProvider).totalCount;
    await ds.recalcularEPersistirVolume(widget.dofItem, totalCount);
    if (mounted) ref.invalidate(registroPorItemProvider(widget.dofItem.id));
  }

  ButtonStyle _ghostButtonStyle({required bool isActive}) {
    if (isActive) {
      return OutlinedButton.styleFrom(
        side: const BorderSide(color: AppColors.green, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        minimumSize: const Size.fromHeight(40),
        backgroundColor: AppColors.green.withValues(alpha: 0.12),
        foregroundColor: AppColors.green,
      );
    }
    return OutlinedButton.styleFrom(
      side: BorderSide(color: Colors.grey.shade400, width: 1.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      minimumSize: const Size.fromHeight(40),
      foregroundColor: Colors.grey.shade700,
    );
  }

  void _handlePanStart(
    Offset localPosition,
    BoxConstraints constraints,
    CapturaState state,
  ) {
    final notifier = ref.read(capturaViewModelProvider.notifier);
    final session = state.current!;
    final inRegionMode = state.isRegionMode || session.awaitingRegionSelection;
    if (inRegionMode) {
      final widgetSize = Size(constraints.maxWidth, constraints.maxHeight);

      final handleHit = _hitTestRegionHandle(
        localPosition,
        session.savedRegions,
        widgetSize,
      );
      if (handleHit != null) {
        final original = notifier.beginEditRegion(handleHit.index);
        if (original != null) {
          setState(() {
            _regionDragKind = _RegionDragKind.resizing;
            _regionOriginalRect = original;
            _regionActiveHandle = handleHit.handle;
            _regionStartPoint = null;
          });
        }
        return;
      }

      final interiorHit = _hitTestRegionInterior(
        localPosition,
        session.savedRegions,
        widgetSize,
      );
      if (interiorHit != null) {
        final original = notifier.beginEditRegion(interiorHit);
        if (original != null) {
          setState(() {
            _regionDragKind = _RegionDragKind.moving;
            _regionOriginalRect = original;
            _regionActiveHandle = null;
            _regionStartPoint = Offset(
              localPosition.dx / constraints.maxWidth,
              localPosition.dy / constraints.maxHeight,
            );
          });
        }
        return;
      }

      final anchor = Offset(
        localPosition.dx / constraints.maxWidth,
        localPosition.dy / constraints.maxHeight,
      );
      setState(() {
        _regionDragKind = _RegionDragKind.creating;
        _regionStartPoint = anchor;
        _regionOriginalRect = null;
        _regionActiveHandle = null;
      });
      notifier.setDraggingRegion(Rect.fromLTWH(anchor.dx, anchor.dy, 0, 0));
    } else if (state.isEditMode) {
      final hitIdx = _hitTestCircle(localPosition, extraPadding: 5);
      if (hitIdx != null) {
        setState(() {
          _draggingCircleIndex = hitIdx;
          _draggingOriginalDetection = session.detections[hitIdx];
          _draggingCenterOverride = Offset(
            session.detections[hitIdx].location.center.dx,
            session.detections[hitIdx].location.center.dy,
          );
        });
      }
    }
  }

  void _handlePanUpdate(
    Offset localPosition,
    Offset delta,
    BoxConstraints constraints,
    CapturaState state,
  ) {
    final notifier = ref.read(capturaViewModelProvider.notifier);
    final session = state.current!;
    final inRegionMode = state.isRegionMode || session.awaitingRegionSelection;
    if (inRegionMode) {
      final cur = Offset(
        (localPosition.dx / constraints.maxWidth).clamp(0.0, 1.0),
        (localPosition.dy / constraints.maxHeight).clamp(0.0, 1.0),
      );
      final kind = _regionDragKind;
      if (kind == _RegionDragKind.creating) {
        final anchor = _regionStartPoint;
        if (anchor == null) return;
        notifier.setDraggingRegion(Rect.fromPoints(anchor, cur));
      } else if (kind == _RegionDragKind.resizing) {
        final original = _regionOriginalRect;
        final handle = _regionActiveHandle;
        if (original == null || handle == null) return;
        notifier.setDraggingRegion(_resizedRect(original, handle, cur));
      } else if (kind == _RegionDragKind.moving) {
        final original = _regionOriginalRect;
        final start = _regionStartPoint;
        if (original == null || start == null) return;
        notifier.setDraggingRegion(_movedRect(original, cur - start));
        final overTrash = _isOverTrash(
          localPosition,
          Size(constraints.maxWidth, constraints.maxHeight),
        );
        if (overTrash != _overTrashZone) {
          setState(() => _overTrashZone = overTrash);
        }
      }
    } else if (state.isEditMode && _draggingCircleIndex != null) {
      final dx = delta.dx / constraints.maxWidth;
      final dy = delta.dy / constraints.maxHeight;
      setState(() {
        _draggingCenterOverride = Offset(
          (_draggingCenterOverride!.dx + dx).clamp(0.0, 1.0),
          (_draggingCenterOverride!.dy + dy).clamp(0.0, 1.0),
        );
        _significantDrag = true;
      });
    }
  }

  Rect _resizedRect(Rect original, _RegionHandle handle, Offset cur) {
    double left = original.left;
    double top = original.top;
    double right = original.right;
    double bottom = original.bottom;

    final movesLeft = handle == _RegionHandle.topLeft ||
        handle == _RegionHandle.bottomLeft ||
        handle == _RegionHandle.left;
    final movesRight = handle == _RegionHandle.topRight ||
        handle == _RegionHandle.bottomRight ||
        handle == _RegionHandle.right;
    final movesTop = handle == _RegionHandle.topLeft ||
        handle == _RegionHandle.topRight ||
        handle == _RegionHandle.top;
    final movesBottom = handle == _RegionHandle.bottomLeft ||
        handle == _RegionHandle.bottomRight ||
        handle == _RegionHandle.bottom;

    if (movesLeft) left = cur.dx.clamp(0.0, original.right - _kMinRegionSize);
    if (movesRight) {
      right = cur.dx.clamp(original.left + _kMinRegionSize, 1.0);
    }
    if (movesTop) top = cur.dy.clamp(0.0, original.bottom - _kMinRegionSize);
    if (movesBottom) {
      bottom = cur.dy.clamp(original.top + _kMinRegionSize, 1.0);
    }

    return Rect.fromLTRB(left, top, right, bottom);
  }

  Rect _movedRect(Rect original, Offset delta) {
    final clampedDx = delta.dx.clamp(-original.left, 1.0 - original.right);
    final clampedDy = delta.dy.clamp(-original.top, 1.0 - original.bottom);
    return Rect.fromLTWH(
      original.left + clampedDx,
      original.top + clampedDy,
      original.width,
      original.height,
    );
  }

  bool _isOverTrash(Offset localPosition, Size widgetSize) {
    final trashCenter = Offset(
      widgetSize.width / 2,
      widgetSize.height - _kTrashIconBottomMargin - _kTrashIconDiameter / 2,
    );
    return (localPosition - trashCenter).distance <= _kTrashHitRadius;
  }

  void _handlePanEnd(CapturaState state) {
    final notifier = ref.read(capturaViewModelProvider.notifier);
    final session = state.current!;
    final inRegionMode = state.isRegionMode || session.awaitingRegionSelection;
    if (inRegionMode) {
      final dr = state.draggingRegion;
      final kind = _regionDragKind;
      if (kind == _RegionDragKind.moving && _overTrashZone && dr != null) {
        notifier.discardDraggedRegion(dr);
      } else {
        final shouldCommit = dr != null &&
            (kind == _RegionDragKind.resizing ||
                kind == _RegionDragKind.moving ||
                (kind == _RegionDragKind.creating &&
                    dr.width > _kMinRegionSize &&
                    dr.height > _kMinRegionSize));
        if (shouldCommit) {
          notifier.addSavedRegion(dr);
        }
        notifier.setDraggingRegion(null);
      }
      setState(() {
        _regionDragKind = null;
        _regionStartPoint = null;
        _regionOriginalRect = null;
        _regionActiveHandle = null;
        _overTrashZone = false;
      });
    } else if (state.isEditMode &&
        _draggingCircleIndex != null &&
        _significantDrag) {
      final old = _draggingOriginalDetection!;
      final newDet = Recognition(
        old.classId,
        old.label,
        old.score,
        Rect.fromCenter(
          center: _draggingCenterOverride!,
          width: old.location.width,
          height: old.location.height,
        ),
        angle: old.angle,
      );
      notifier.moveDetectionCommit(state.currentIndex, old, newDet);
    }
    if (state.isEditMode) {
      setState(() {
        _draggingCircleIndex = null;
        _draggingOriginalDetection = null;
        _draggingCenterOverride = null;
        _significantDrag = false;
      });
    }
  }

  void _handlePanCancel(CapturaState state) {
    final notifier = ref.read(capturaViewModelProvider.notifier);
    final session = state.current;
    if (session == null) return;
    final inRegionMode = state.isRegionMode || session.awaitingRegionSelection;
    if (inRegionMode) {
      final original = _regionOriginalRect;
      final kind = _regionDragKind;
      if ((kind == _RegionDragKind.resizing ||
              kind == _RegionDragKind.moving) &&
          original != null) {
        notifier.addSavedRegion(original);
      }
      notifier.setDraggingRegion(null);
      setState(() {
        _regionDragKind = null;
        _regionStartPoint = null;
        _regionOriginalRect = null;
        _regionActiveHandle = null;
        _overTrashZone = false;
      });
    } else if (state.isEditMode) {
      setState(() {
        _draggingCircleIndex = null;
        _draggingOriginalDetection = null;
        _draggingCenterOverride = null;
        _significantDrag = false;
      });
    }
  }

  void _onPointerDown(
    PointerDownEvent event,
    BoxConstraints constraints,
    CapturaState state,
  ) {
    _activePointerCount++;
    if (_activePointerCount == 1) {
      final session = state.current;
      if (session == null) return;
      final inRegionMode = state.isRegionMode || session.awaitingRegionSelection;
      if (inRegionMode || state.isEditMode) {
        _handlePanStart(event.localPosition, constraints, state);
      }
    } else {
      _handlePanCancel(state);
    }
  }

  void _onPointerMove(
    PointerMoveEvent event,
    BoxConstraints constraints,
    CapturaState state,
  ) {
    if (_activePointerCount != 1) return;
    final session = state.current;
    if (session == null) return;
    final inRegionMode = state.isRegionMode || session.awaitingRegionSelection;
    if (inRegionMode || state.isEditMode) {
      _handlePanUpdate(
        event.localPosition,
        event.localDelta,
        constraints,
        state,
      );
    }
  }

  void _onPointerUp(PointerUpEvent event, CapturaState state) {
    if (_activePointerCount > 0) _activePointerCount--;
    if (_activePointerCount == 0) {
      _handlePanEnd(state);
    }
  }

  void _onPointerCancel(PointerCancelEvent event, CapturaState state) {
    if (_activePointerCount > 0) _activePointerCount--;
    _handlePanCancel(state);
  }

  void _handleEditTap(Offset localPosition, CapturaState state) {
    final notifier = ref.read(capturaViewModelProvider.notifier);
    final hitIdx = _hitTestCircle(localPosition, extraPadding: 0);
    if (hitIdx != null) {
      notifier.removeDetection(state.currentIndex, hitIdx);
    } else {
      if (_currentWidgetSize == null) return;
      final center = Offset(
        (localPosition.dx / _currentWidgetSize!.width).clamp(0.0, 1.0),
        (localPosition.dy / _currentWidgetSize!.height).clamp(0.0, 1.0),
      );
      final avgSize = notifier.averageDetectionSize();
      notifier.addManualDetection(
        state.currentIndex,
        Rect.fromCenter(
          center: center,
          width: avgSize.width.clamp(0.01, 0.5),
          height: avgSize.height.clamp(0.01, 0.5),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(capturaViewModelProvider);
    final session = state.current;
    final totalCount = state.totalCount;
    final registroAsync = ref.watch(registroPorItemProvider(widget.dofItem.id));
    final volumeTotalM3 = registroAsync.valueOrNull?.volumeTotalM3 ?? 0.0;
    final isOver = volumeTotalM3 > 0.0
        ? volumeTotalM3 > widget.dofItem.saldoTotal
        : false;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _handleBackPress();
      },
      child: AppScaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          centerTitle: true,
          title: const Text(
            'Tela de Captura',
            style: TextStyle(
              color: AppColors.black,
              fontWeight: FontWeight.bold,
              fontSize: 19,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            tooltip: 'Voltar',
            icon: const Icon(Icons.chevron_left, color: AppColors.black),
            onPressed: _handleBackPress,
            iconSize: 30,
          ),
        ),
        body: Stack(
          children: [
            Column(
              children: [
                HeaderCard(
                  dofItem: widget.dofItem,
                  isOver: isOver,
                  volumeTotalM3: volumeTotalM3,
                ),

                Expanded(
                  child: session == null
                      ? Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Center(
                            child: UploadArea(
                              onTap: _showImageSourceSheet,
                              title: 'Selecione uma imagem para começar',
                              subtitle: 'Câmera',
                            ),
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Container(
                                decoration: state.isEditMode
                                    ? BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: AppColors.green,
                                          width: 2,
                                        ),
                                      )
                                    : null,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: LayoutBuilder(
                                    builder: (context, constraints) {
                                      WidgetsBinding.instance
                                          .addPostFrameCallback((_) {
                                            final s = Size(
                                              constraints.maxWidth,
                                              constraints.maxHeight,
                                            );
                                            if (_currentWidgetSize != s) {
                                              setState(
                                                () => _currentWidgetSize = s,
                                              );
                                            }
                                          });

                                      final aspectRatio =
                                          session.decodedImage != null
                                          ? session.decodedImage!.width /
                                                session.decodedImage!.height
                                          : 1.0;

                                      final inRegionMode =
                                          state.isRegionMode ||
                                          session.awaitingRegionSelection;

                                      return InteractiveViewer(
                                        transformationController:
                                            _transformController,
                                        panEnabled:
                                            !inRegionMode && !state.isEditMode,
                                        scaleEnabled: true,
                                        minScale: 1.0,
                                        maxScale: 6.0,
                                        boundaryMargin: EdgeInsets.zero,
                                        child: AspectRatio(
                                          aspectRatio: aspectRatio,
                                          child: Listener(
                                            behavior: HitTestBehavior.opaque,
                                            onPointerDown: (e) =>
                                                _onPointerDown(
                                                  e,
                                                  constraints,
                                                  state,
                                                ),
                                            onPointerMove: (e) =>
                                                _onPointerMove(
                                                  e,
                                                  constraints,
                                                  state,
                                                ),
                                            onPointerUp: (e) =>
                                                _onPointerUp(e, state),
                                            onPointerCancel: (e) =>
                                                _onPointerCancel(e, state),
                                            child: GestureDetector(
                                            onTapUp: state.isEditMode
                                                ? (d) => _handleEditTap(
                                                    d.localPosition,
                                                    state,
                                                  )
                                                : null,
                                            child: Stack(
                                              fit: StackFit.expand,
                                              children: [
                                                Image.file(
                                                  session.imageFile,
                                                  fit: BoxFit.fill,
                                                ),
                                                if (session
                                                    .detections
                                                    .isNotEmpty)
                                                  CustomPaint(
                                                    painter: BoundingBoxPainter(
                                                      _resultsForDisplay(
                                                        session,
                                                      ),
                                                    ),
                                                  ),
                                                if ((session
                                                            .savedRegions
                                                            .isNotEmpty ||
                                                        state.draggingRegion !=
                                                            null) &&
                                                    inRegionMode)
                                                  CustomPaint(
                                                    painter:
                                                        RegionSelectorPainter(
                                                          session.savedRegions,
                                                          state.draggingRegion,
                                                        ),
                                                  ),
                                                if (inRegionMode &&
                                                    !state.isProcessing)
                                                  Positioned(
                                                    bottom: 8,
                                                    left: 0,
                                                    right: 0,
                                                    child: Center(
                                                      child: AutoDismissHint(
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                                horizontal: 16,
                                                                vertical: 10,
                                                              ),
                                                          decoration: BoxDecoration(
                                                            color: Colors.white
                                                                .withValues(
                                                                  alpha: 0.90,
                                                                ),
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  20,
                                                                ),
                                                            border: Border.all(
                                                              color: AppColors
                                                                  .green,
                                                              width: 1.5,
                                                            ),
                                                          ),
                                                          child: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              Text(
                                                                session.awaitingRegionSelection
                                                                    ? 'Arraste para selecionar área'
                                                                    : 'Solte para confirmar',
                                                                style: const TextStyle(
                                                                  fontSize: 13,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  color: Colors
                                                                      .black87,
                                                                ),
                                                              ),
                                                              if (session
                                                                  .awaitingRegionSelection)
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets.only(
                                                                        top: 4,
                                                                      ),
                                                                  child: Text(
                                                                    'ou toque em "Detectar"',
                                                                    style: TextStyle(
                                                                      fontSize:
                                                                          11,
                                                                      color: Colors
                                                                          .grey
                                                                          .shade600,
                                                                    ),
                                                                  ),
                                                                ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                if (inRegionMode)
                                                  Positioned(
                                                    bottom: 0,
                                                    left: 0,
                                                    right: 0,
                                                    child: IgnorePointer(
                                                      child: Center(
                                                        child: AnimatedSlide(
                                                          duration:
                                                              const Duration(
                                                                milliseconds:
                                                                    220,
                                                              ),
                                                          curve:
                                                              Curves.easeOut,
                                                          offset:
                                                              _regionDragKind ==
                                                                  _RegionDragKind
                                                                      .moving
                                                              ? Offset.zero
                                                              : const Offset(
                                                                  0,
                                                                  1.6,
                                                                ),
                                                          child: AnimatedContainer(
                                                            duration:
                                                                const Duration(
                                                                  milliseconds:
                                                                      150,
                                                                ),
                                                            margin:
                                                                const EdgeInsets.only(
                                                                  bottom: 24,
                                                                ),
                                                            width:
                                                                _overTrashZone
                                                                ? _kTrashIconDiameter +
                                                                      8
                                                                : _kTrashIconDiameter,
                                                            height:
                                                                _overTrashZone
                                                                ? _kTrashIconDiameter +
                                                                      8
                                                                : _kTrashIconDiameter,
                                                            decoration: BoxDecoration(
                                                              shape: BoxShape
                                                                  .circle,
                                                              color:
                                                                  _overTrashZone
                                                                  ? Colors
                                                                        .red
                                                                        .shade700
                                                                  : Colors
                                                                        .black54,
                                                            ),
                                                            child: Icon(
                                                              Icons.delete,
                                                              color: Colors
                                                                  .white,
                                                              size:
                                                                  _overTrashZone
                                                                  ? 30
                                                                  : 24,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                if (state.isEditMode)
                                                  Positioned(
                                                    bottom: 8,
                                                    left: 0,
                                                    right: 0,
                                                    child: Center(
                                                      child: AutoDismissHint(
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                                horizontal: 12,
                                                                vertical: 6,
                                                              ),
                                                          decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  20,
                                                                ),
                                                            color: Colors.white
                                                                .withValues(
                                                                  alpha: 0.9,
                                                                ),
                                                            border: Border.all(
                                                              color: Colors
                                                                  .grey
                                                                  .shade400,
                                                            ),
                                                          ),
                                                          child: Text(
                                                            '✏  TOQUE PARA EDITAR',
                                                            style: TextStyle(
                                                              fontSize: 10,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: Colors
                                                                  .grey
                                                                  .shade600,
                                                              letterSpacing:
                                                                  0.5,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                if (state.isProcessing)
                                                  Container(
                                                    color: Colors.black45,
                                                    child: const Center(
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          CircularProgressIndicator(
                                                            color: Colors.white,
                                                          ),
                                                          SizedBox(height: 12),
                                                          Text(
                                                            'Detectando...',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              if (state.currentIndex > 0)
                                Positioned(
                                  left: 4,
                                  top: 0,
                                  bottom: 0,
                                  child: Center(
                                    child: GestureDetector(
                                      onTap: () {
                                        ref
                                            .read(
                                              capturaViewModelProvider.notifier,
                                            )
                                            .navigateTo(state.currentIndex - 1);
                                        _transformController.value =
                                            Matrix4.identity();
                                      },
                                      child: Container(
                                        width: 28,
                                        height: 28,
                                        decoration: BoxDecoration(
                                          color: AppColors.green.withValues(
                                            alpha: 0.85,
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.chevron_left,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              if (state.currentIndex < state.fotos.length - 1)
                                Positioned(
                                  right: 4,
                                  top: 0,
                                  bottom: 0,
                                  child: Center(
                                    child: GestureDetector(
                                      onTap: () {
                                        ref
                                            .read(
                                              capturaViewModelProvider.notifier,
                                            )
                                            .navigateTo(state.currentIndex + 1);
                                        _transformController.value =
                                            Matrix4.identity();
                                      },
                                      child: Container(
                                        width: 28,
                                        height: 28,
                                        decoration: BoxDecoration(
                                          color: AppColors.green.withValues(
                                            alpha: 0.85,
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.chevron_right,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                ),

                if (state.fotos.isNotEmpty)
                  ThumbnailStrip(
                    fotos: state.fotos,
                    currentIndex: state.currentIndex,
                    onAdicionar: _showImageSourceSheet,
                    onSelecionar: (i) {
                      ref.read(capturaViewModelProvider.notifier).navigateTo(i);
                      _transformController.value = Matrix4.identity();
                    },
                    onRemover: _confirmDeletePhoto,
                  ),

                if (session != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'DETECÇÕES',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey.shade500,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getSummary(session, state.isProcessing),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          if (state.fotos.length > 1)
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                'Total da sessão: $totalCount peça(s)',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.green,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (session != null &&
                          (session.awaitingRegionSelection ||
                              state.isRegionMode) &&
                          !state.isProcessing)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                          child: SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (state.isRegionMode &&
                                    !session.awaitingRegionSelection) ...[
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () => ref
                                          .read(capturaViewModelProvider.notifier)
                                          .cancelRegionMode(),
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide(
                                          color: Colors.grey.shade400,
                                          width: 1.5,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        foregroundColor: Colors.grey.shade700,
                                      ),
                                      child: const Text(
                                        'Cancelar',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () => ref
                                        .read(capturaViewModelProvider.notifier)
                                        .confirmRegionAndProcess(),
                                    icon: const Icon(Icons.check),
                                    label: Text(
                                      session.savedRegions.isEmpty
                                          ? 'Detectar'
                                          : 'Salvar ${session.savedRegions.length} Área(s)',
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.green,
                                      foregroundColor: Colors.white,
                                      textStyle: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      if (session != null &&
                          !session.awaitingRegionSelection &&
                          !state.isRegionMode)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => ref
                                      .read(capturaViewModelProvider.notifier)
                                      .setIsRegionMode(!state.isRegionMode),
                                  icon: const Icon(Icons.crop_free, size: 18),
                                  label: const Text('Área'),
                                  style: _ghostButtonStyle(
                                    isActive: state.isRegionMode,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => ref
                                      .read(capturaViewModelProvider.notifier)
                                      .toggleEditMode(),
                                  icon: const Icon(Icons.edit, size: 18),
                                  label: const Text('Editar'),
                                  style: _ghostButtonStyle(
                                    isActive: state.isEditMode,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => context.push(
                                    '/fiscalizacao/captura/medidas',
                                    extra: {
                                      'dofItem': widget.dofItem,
                                      'fotoIndex': state.currentIndex,
                                    },
                                  ),
                                  icon: const Icon(Icons.straighten, size: 18),
                                  label: const Text('Medidas'),
                                  style: _ghostButtonStyle(isActive: false),
                                ),
                              ),
                              if (state.isEditMode &&
                                  session.undoStack.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(left: 8),
                                  child: SizedBox(
                                    width: 40,
                                    height: 40,
                                    child: OutlinedButton(
                                      onPressed: () => ref
                                          .read(
                                            capturaViewModelProvider.notifier,
                                          )
                                          .undo(),
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide(
                                          color: Colors.grey.shade400,
                                          width: 1.5,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        padding: EdgeInsets.zero,
                                        foregroundColor: Colors.grey.shade700,
                                      ),
                                      child: const Icon(Icons.undo, size: 18),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),

                      if (state.fotos.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                          child: SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton.icon(
                              onPressed: state.isProcessing ||
                                      state.isEditMode ||
                                      state.isRegionMode ||
                                      (session?.awaitingRegionSelection ?? false)
                                  ? null
                                  : _saveAndPop,
                              icon: const Icon(
                                Icons.check_circle,
                                color: Colors.white,
                              ),
                              label: Text(
                                isOver
                                    ? 'Salvar (Excedente)'
                                    : 'Salvar Fiscalização',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isOver
                                    ? Colors.red.shade700
                                    : AppColors.green,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            if (_hasExistingSession &&
                state.isProcessing &&
                state.fotos.isEmpty)
              Container(
                color: Colors.black.withValues(alpha: 0.6),
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: AppColors.green),
                      SizedBox(height: 12),
                      Text(
                        'Carregando sessão...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
