import 'dart:async';
import 'dart:io';
import 'dart:math' show min;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/services/yolo_service.dart';
import 'package:app/core/utils/dialogs.dart';
import 'package:app/core/widgets/app_scaffold.dart';
import 'package:app/core/widgets/box_painter.dart';
import 'package:app/core/widgets/upload_area.dart';
import 'package:app/features/dof/data/models/dof_item_model.dart';
import 'package:app/features/fiscalizacao/presentation/providers/fiscalizacao_providers.dart';

class CapturaScreen extends ConsumerStatefulWidget {
  final DofItemModel dofItem;

  const CapturaScreen({super.key, required this.dofItem});

  @override
  ConsumerState<CapturaScreen> createState() => _CapturaScreenState();
}

/// Which part of a saved region a resize gesture grabbed.
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

/// What the current region-mode pan gesture is doing.
enum _RegionDragKind { creating, resizing, moving }

/// Smallest allowed region width/height (fraction of image size), used both
/// to discard accidental taps when creating a region and to stop a
/// resize/move gesture from collapsing or inverting a region.
const double _kMinRegionSize = 0.02;

/// Touch tolerance (in widget pixels) for grabbing a corner/edge handle.
const double _kRegionHandleTouchRadius = 18.0;

/// Diameter of the trash-can drop target shown while an existing region is
/// being dragged (moved), and how far its center sits above the bottom edge
/// of the image. Kept as widget-pixel constants (not fractions) since the
/// icon has a fixed visual size regardless of image/zoom.
const double _kTrashIconDiameter = 56.0;
const double _kTrashIconBottomMargin = 24.0;

/// How close the finger must be to the trash icon's center for a
/// drag-to-delete drop to count. Deliberately more generous than the visual
/// icon radius so it's easy to hit without precise aim.
const double _kTrashHitRadius = 42.0;

class _CapturaScreenState extends ConsumerState<CapturaScreen> {
  final _transformController = TransformationController();
  final _picker = ImagePicker();

  // Per-frame drag state kept local to avoid notifier rebuilds
  int? _draggingCircleIndex;
  Recognition? _draggingOriginalDetection;
  Offset? _draggingCenterOverride;
  bool _significantDrag = false;
  Size? _currentWidgetSize;
  bool _hasExistingSession = false;

  // Region resize/move drag state (kept local, same reasoning as above).
  _RegionDragKind? _regionDragKind;
  // "creating": fixed anchor point the rect is drawn from.
  // "moving": pointer position at gesture start (used to compute a delta).
  // "resizing": unused (the fixed reference is the opposite corner/edge of
  // _regionOriginalRect, derived from _regionActiveHandle instead).
  Offset? _regionStartPoint;
  Rect? _regionOriginalRect; // rect snapshot at gesture start, fraction space
  _RegionHandle? _regionActiveHandle; // grabbed handle, only for "resizing"

  // True while a "moving" drag's current finger position is hovering over
  // the trash-can drop target. Only meaningful while
  // _regionDragKind == _RegionDragKind.moving; drives both the trash icon's
  // highlighted look and whether releasing deletes the region instead of
  // committing the move.
  bool _overTrashZone = false;

  // How many fingers are currently touching the photo. Tracked via raw
  // Listener callbacks (see _onPointerDown/_onPointerMove/_onPointerUp
  // below) instead of GestureDetector's onPan* callbacks, because a
  // PanGestureRecognizer living inside the same widget tree as
  // InteractiveViewer's internal scale recognizer competes for the gesture
  // arena and unpredictably blocks two-finger pinch-to-zoom. Raw Listener
  // events never enter the arena, so they can never interfere with
  // InteractiveViewer's own pinch/pan handling.
  int _activePointerCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final notifier = ref.read(capturaNotifierProvider.notifier);
      await notifier.initModel();

      final ds = ref.read(fiscalizacaoLocalDatasourceProvider);
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
    final session = ref.read(capturaNotifierProvider).current;
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

  /// Returns the handle of [rectPx] (already in widget-pixel space) that is
  /// within [tolerance] pixels of [point], or null if none is close enough.
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

  /// Hit-tests the 8 handles of every saved region (topmost/last-added first)
  /// against [localPosition]. Returns the region index and grabbed handle,
  /// or null if the touch wasn't close enough to any handle.
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

  /// Hit-tests the interior of every saved region (topmost/last-added first)
  /// against [localPosition], for the "move whole region" gesture. Assumes
  /// handles were already checked (and missed) by the caller.
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
        .read(capturaNotifierProvider.notifier)
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
    final state = ref.read(capturaNotifierProvider);

    final ds = ref.read(fiscalizacaoLocalDatasourceProvider);
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
        .read(capturaNotifierProvider.notifier)
        .saveCaptura(widget.dofItem, ds);
    if (!mounted) return;
    ref.invalidate(registroPorItemProvider(widget.dofItem.id));
    Navigator.of(context).pop();
  }

  Future<void> _handleBackPress() async {
    final hasChanges = ref.read(capturaNotifierProvider).isDirty;
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
    final ds = ref.read(fiscalizacaoLocalDatasourceProvider);
    await ref
        .read(capturaNotifierProvider.notifier)
        .removePhotoAndCleanup(index, widget.dofItem.id, ds);
    final totalCount = ref.read(capturaNotifierProvider).totalCount;
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
    final notifier = ref.read(capturaNotifierProvider.notifier);
    final session = state.current!;
    final inRegionMode = state.isRegionMode || session.awaitingRegionSelection;
    if (inRegionMode) {
      final widgetSize = Size(constraints.maxWidth, constraints.maxHeight);

      // 1) Did we grab a handle of an already-saved region? -> resize.
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

      // 2) Did we tap inside an already-saved region (not on a handle)?
      //    -> move the whole region.
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

      // 3) Otherwise, start drawing a brand-new region anchored at the
      //    touch point (the anchor is fixed for the whole gesture, unlike
      //    the previous implementation which re-derived it from the
      //    previous frame's already-expanded rect).
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
    final notifier = ref.read(capturaNotifierProvider.notifier);
    final session = state.current!;
    final inRegionMode = state.isRegionMode || session.awaitingRegionSelection;
    if (inRegionMode) {
      // Current pointer position, fraction space, clamped to the image
      // bounds. Every branch below computes the new rect from a FIXED
      // reference (an anchor point or the original rect snapshot) plus
      // this current position — never by folding the previous frame's
      // already-updated rect, which is what made the old implementation
      // only ever grow (dragging back past a point wouldn't shrink it).
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

  /// Recomputes [original] after dragging [handle] to [cur] (fraction
  /// space). The side(s) the handle owns move to [cur]; every other side
  /// stays exactly at its original position (the "fixed anchor"). Each
  /// moving side is clamped against its *original* opposite side so the
  /// rect can never invert or shrink below [_kMinRegionSize] while
  /// dragging.
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

  /// Translates [original] by [delta] (fraction space), clamped so the
  /// moved rect stays fully within the 0..1 image bounds without changing
  /// its size.
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

  /// Whether [localPosition] (widget-pixel space) is close enough to the
  /// trash-can drop target's center to count as "dropped on the trash".
  bool _isOverTrash(Offset localPosition, Size widgetSize) {
    final trashCenter = Offset(
      widgetSize.width / 2,
      widgetSize.height - _kTrashIconBottomMargin - _kTrashIconDiameter / 2,
    );
    return (localPosition - trashCenter).distance <= _kTrashHitRadius;
  }

  void _handlePanEnd(CapturaState state) {
    final notifier = ref.read(capturaNotifierProvider.notifier);
    final session = state.current!;
    final inRegionMode = state.isRegionMode || session.awaitingRegionSelection;
    if (inRegionMode) {
      final dr = state.draggingRegion;
      final kind = _regionDragKind;
      if (kind == _RegionDragKind.moving && _overTrashZone && dr != null) {
        // Released on the trash target while moving an already-saved
        // region: discard it (and any detections inside it) instead of
        // committing the move.
        notifier.discardDraggedRegion(dr);
      } else {
        // Resizing/moving always commit the (already saved) region back —
        // its size was clamped to _kMinRegionSize throughout the drag, so
        // it can never end up "too small". Creating a brand new region
        // still discards accidental taps/micro-drags, same as before.
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

  /// Handles the gesture being interrupted before onPanEnd fires (e.g. the
  /// OS steals the pointer for an edge-swipe). If we had picked up an
  /// existing region to resize/move it, put it back exactly as it was —
  /// silently losing an already-saved region because the gesture got
  /// cancelled would be far worse than just ignoring the interrupted edit.
  void _handlePanCancel(CapturaState state) {
    final notifier = ref.read(capturaNotifierProvider.notifier);
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

  // --- Raw pointer routing (region/edit drag vs. pinch-to-zoom) ---
  //
  // These wrap _handlePanStart/_handlePanUpdate/_handlePanEnd/_handlePanCancel
  // (which contain all the actual drag/resize/move logic, unchanged) and are
  // wired to a Listener instead of GestureDetector's onPan* callbacks. See
  // the comment on _activePointerCount for why.

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
      // A second finger just joined: this is now a pinch-to-zoom gesture,
      // not a single-finger drag. Cancel whatever single-finger
      // resize/move/detection-drag was in progress (restoring it exactly
      // as it was, same as an OS-interrupted gesture) so InteractiveViewer's
      // own scale recognizer is free to handle both fingers.
      _handlePanCancel(state);
    }
  }

  void _onPointerMove(
    PointerMoveEvent event,
    BoxConstraints constraints,
    CapturaState state,
  ) {
    // Only drive our own drag logic while exactly one finger is down. With
    // 0 fingers there's nothing to update; with 2+ fingers this is a pinch
    // and _onPointerDown already cancelled any single-finger drag above.
    if (_activePointerCount != 1) return;
    final session = state.current;
    if (session == null) return;
    final inRegionMode = state.isRegionMode || session.awaitingRegionSelection;
    if (inRegionMode || state.isEditMode) {
      // Use localDelta (not delta): delta is in raw device/global pixels,
      // while localDelta is transformed into this widget's local coordinate
      // space — the same space localPosition and constraints.maxWidth/
      // maxHeight are already in. Without this, dragging a region handle or
      // detection circle would move too fast/slow whenever the photo is
      // zoomed in via InteractiveViewer's pinch-to-zoom.
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
    // Only commit when the last finger of the sequence lifted. If this was
    // one finger lifting out of a multi-touch pinch, the drag was already
    // cancelled (not started) when the 2nd finger touched down, so there's
    // nothing to commit — and the remaining finger(s) shouldn't suddenly
    // resume a drag either (_handlePanUpdate is a no-op with no drag state).
    if (_activePointerCount == 0) {
      _handlePanEnd(state);
    }
  }

  void _onPointerCancel(PointerCancelEvent event, CapturaState state) {
    if (_activePointerCount > 0) _activePointerCount--;
    _handlePanCancel(state);
  }

  void _handleEditTap(Offset localPosition, CapturaState state) {
    final notifier = ref.read(capturaNotifierProvider.notifier);
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
    final state = ref.watch(capturaNotifierProvider);
    final session = state.current;
    final totalCount = state.totalCount;
    final registroAsync = ref.watch(registroPorItemProvider(widget.dofItem.id));
    final volumeTotalM3 = registroAsync.value?.volumeTotalM3 ?? 0.0;
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
            icon: const Icon(Icons.chevron_left, color: AppColors.black),
            onPressed: _handleBackPress,
            iconSize: 30,
          ),
        ),
        body: Stack(
          children: [
            Column(
              children: [
                _HeaderCard(
                  dofItem: widget.dofItem,
                  isOver: isOver,
                  volumeTotalM3: volumeTotalM3,
                ),

                // ── Image area ──────────────────────────────────────────────
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
                                                        _RegionSelectorPainter(
                                                          session.savedRegions,
                                                          state.draggingRegion,
                                                        ),
                                                  ),
                                                // Region instruction chip
                                                if (inRegionMode &&
                                                    !state.isProcessing)
                                                  Positioned(
                                                    bottom: 8,
                                                    left: 0,
                                                    right: 0,
                                                    child: Center(
                                                      child: _AutoDismissHint(
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
                                                // Trash drop target: to
                                                // delete a saved region, the
                                                // user long-presses/drags it
                                                // (the existing "move"
                                                // gesture) down onto this
                                                // icon, which slides up from
                                                // the bottom edge only while
                                                // such a drag is in
                                                // progress, and highlights
                                                // once the finger is close
                                                // enough to it to count as a
                                                // drop.
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
                                                // Edit mode chip
                                                if (state.isEditMode)
                                                  Positioned(
                                                    bottom: 8,
                                                    left: 0,
                                                    right: 0,
                                                    child: Center(
                                                      child: _AutoDismissHint(
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
                                                // Loading overlay
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
                              // Left navigation arrow
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
                                              capturaNotifierProvider.notifier,
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
                              // Right navigation arrow
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
                                              capturaNotifierProvider.notifier,
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

                // ── Thumbnail strip ─────────────────────────────────────────
                if (state.fotos.isNotEmpty) _buildThumbnailStrip(state),

                // ── Detection card ──────────────────────────────────────────
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

                // ── Bottom buttons ──────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Detectar button
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
                                          .read(capturaNotifierProvider.notifier)
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
                                        .read(capturaNotifierProvider.notifier)
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

                      // Ghost toolbar
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
                                      .read(capturaNotifierProvider.notifier)
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
                                      .read(capturaNotifierProvider.notifier)
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
                                            capturaNotifierProvider.notifier,
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

                      // Save button
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

  Widget _buildThumbnailStrip(CapturaState state) {
    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: state.fotos.length + 1,
        itemBuilder: (context, i) {
          if (i == state.fotos.length) {
            return Padding(
              padding: const EdgeInsets.only(left: 4),
              child: GestureDetector(
                onTap: _showImageSourceSheet,
                child: Container(
                  width: 48,
                  decoration: BoxDecoration(
                    color: AppColors.green.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 20),
                ),
              ),
            );
          }
          final isActive = i == state.currentIndex;
          final count = state.fotos[i].count;
          return Padding(
            padding: const EdgeInsets.only(right: 4),
            child: GestureDetector(
              onTap: () {
                ref.read(capturaNotifierProvider.notifier).navigateTo(i);
                _transformController.value = Matrix4.identity();
              },
              onLongPress: () => _confirmDeletePhoto(i),
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: isActive
                          ? Border.all(color: AppColors.green, width: 2)
                          : Border.all(color: Colors.grey.shade500, width: 1),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(isActive ? 2 : 3),
                      child: Image.file(
                        state.fotos[i].imageFile,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(2),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 3,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      '$count',
                      style: const TextStyle(
                        color: AppColors.green,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Header Card ──────────────────────────────────────────────────────────────

class _HeaderCard extends StatelessWidget {
  final DofItemModel dofItem;
  final bool isOver;
  final double volumeTotalM3;

  const _HeaderCard({
    required this.dofItem,
    required this.isOver,
    this.volumeTotalM3 = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    final showVolume = volumeTotalM3 > 0.0;
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  dofItem.produto,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${dofItem.especieCientifico} (${dofItem.nomePopular})',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Saldo: ${dofItem.saldoTotal.toStringAsFixed(2)} ${dofItem.unidade}',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showVolume) ...[
                Text(
                  'Volume',
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                ),
                Text(
                  '${volumeTotalM3.toStringAsFixed(3)} m³',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isOver ? Colors.red.shade700 : AppColors.green,
                  ),
                ),
              ] else
                Text(''),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Region Selector Painter ──────────────────────────────────────────────────

class _RegionSelectorPainter extends CustomPainter {
  final List<Rect> savedRegions;
  final Rect? draggingRegion;

  _RegionSelectorPainter(this.savedRegions, this.draggingRegion);

  @override
  void paint(Canvas canvas, Size size) {
    final allRegions = [...savedRegions, ?draggingRegion];

    for (int i = 0; i < allRegions.length; i++) {
      final region = allRegions[i];
      final rect = Rect.fromLTRB(
        region.left * size.width,
        region.top * size.height,
        region.right * size.width,
        region.bottom * size.height,
      );

      final isSaved = i < savedRegions.length;
      final borderPaint = Paint()
        ..color = isSaved
            ? AppColors.green
            : AppColors.green.withValues(alpha: 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = isSaved ? 2.5 : 1.5;

      canvas.drawRect(rect, borderPaint);

      final handlePaint = Paint()..color = Colors.white;
      const handleRadius = 5.0;
      for (final corner in [
        // Corners
        Offset(rect.left, rect.top),
        Offset(rect.right, rect.top),
        Offset(rect.left, rect.bottom),
        Offset(rect.right, rect.bottom),
        // Edge midpoints
        Offset(rect.center.dx, rect.top),
        Offset(rect.center.dx, rect.bottom),
        Offset(rect.left, rect.center.dy),
        Offset(rect.right, rect.center.dy),
      ]) {
        canvas.drawCircle(corner, handleRadius, handlePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _RegionSelectorPainter oldDelegate) =>
      oldDelegate.savedRegions != savedRegions ||
      oldDelegate.draggingRegion != draggingRegion;
}

/// Fades out and stops blocking touches a fixed duration after being mounted.
/// Re-arms automatically whenever the caller's `if` condition remounts it.
class _AutoDismissHint extends StatefulWidget {
  final Widget child;

  const _AutoDismissHint({required this.child});

  @override
  State<_AutoDismissHint> createState() => _AutoDismissHintState();
}

class _AutoDismissHintState extends State<_AutoDismissHint> {
  static const _duration = Duration(seconds: 3);
  bool _visible = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(_duration, () {
      if (mounted) setState(() => _visible = false);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedOpacity(
        opacity: _visible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 250),
        child: widget.child,
      ),
    );
  }
}
