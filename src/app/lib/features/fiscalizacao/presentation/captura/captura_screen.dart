import 'dart:io';
import 'dart:math' show min, max;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/services/yolo_service.dart';
import 'package:app/core/widgets/box_painter.dart';
import 'package:app/features/dof/data/models/dof_item_model.dart';
import 'package:app/features/fiscalizacao/presentation/providers/fiscalizacao_providers.dart';

class CapturaScreen extends ConsumerStatefulWidget {
  final DofItemModel dofItem;

  const CapturaScreen({super.key, required this.dofItem});

  @override
  ConsumerState<CapturaScreen> createState() => _CapturaScreenState();
}

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
    final ds = ref.read(fiscalizacaoLocalDatasourceProvider);
    await ref
        .read(capturaNotifierProvider.notifier)
        .saveCaptura(widget.dofItem, ds);
    if (!mounted) return;
    ref.invalidate(registroPorItemProvider(widget.dofItem.id));
    context.pop();
  }

  Future<void> _confirmDeletePhoto(int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remover foto?'),
        content:
            const Text('Esta foto e suas detecções serão removidas.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remover',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    ref.read(capturaNotifierProvider.notifier).removePhoto(index);
  }

  ButtonStyle _ghostButtonStyle({required bool isActive}) {
    if (isActive) {
      return OutlinedButton.styleFrom(
        side: const BorderSide(color: AppColors.green, width: 1.5),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        minimumSize: const Size.fromHeight(40),
        backgroundColor: AppColors.green.withValues(alpha: 0.12),
        foregroundColor: AppColors.green,
      );
    }
    return OutlinedButton.styleFrom(
      side: BorderSide(color: Colors.grey.shade400, width: 1.5),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      minimumSize: const Size.fromHeight(40),
      foregroundColor: Colors.grey.shade700,
    );
  }

  void _handlePanStart(
      DragStartDetails details, BoxConstraints constraints, CapturaState state) {
    final notifier = ref.read(capturaNotifierProvider.notifier);
    final session = state.current!;
    final inRegionMode =
        state.isRegionMode || session.awaitingRegionSelection;
    if (inRegionMode) {
      notifier.setDraggingRegion(Rect.fromLTWH(
        details.localPosition.dx / constraints.maxWidth,
        details.localPosition.dy / constraints.maxHeight,
        0,
        0,
      ));
    } else if (state.isEditMode) {
      final hitIdx =
          _hitTestCircle(details.localPosition, extraPadding: 5);
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
      DragUpdateDetails details, BoxConstraints constraints, CapturaState state) {
    final notifier = ref.read(capturaNotifierProvider.notifier);
    final session = state.current!;
    final inRegionMode =
        state.isRegionMode || session.awaitingRegionSelection;
    if (inRegionMode) {
      final dr = state.draggingRegion;
      if (dr == null) return;
      final nx = details.localPosition.dx / constraints.maxWidth;
      final ny = details.localPosition.dy / constraints.maxHeight;
      notifier.setDraggingRegion(Rect.fromLTRB(
        min(dr.left, nx).clamp(0.0, 1.0),
        min(dr.top, ny).clamp(0.0, 1.0),
        max(dr.right, nx).clamp(0.0, 1.0),
        max(dr.bottom, ny).clamp(0.0, 1.0),
      ));
    } else if (state.isEditMode && _draggingCircleIndex != null) {
      final dx = details.delta.dx / constraints.maxWidth;
      final dy = details.delta.dy / constraints.maxHeight;
      setState(() {
        _draggingCenterOverride = Offset(
          (_draggingCenterOverride!.dx + dx).clamp(0.0, 1.0),
          (_draggingCenterOverride!.dy + dy).clamp(0.0, 1.0),
        );
        _significantDrag = true;
      });
    }
  }

  void _handlePanEnd(DragEndDetails details, CapturaState state) {
    final notifier = ref.read(capturaNotifierProvider.notifier);
    final session = state.current!;
    final inRegionMode =
        state.isRegionMode || session.awaitingRegionSelection;
    if (inRegionMode) {
      final dr = state.draggingRegion;
      if (dr != null && dr.width > 0.02 && dr.height > 0.02) {
        notifier.addSavedRegion(dr);
      }
      notifier.setDraggingRegion(null);
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

  void _handleEditTap(Offset localPosition, CapturaState state) {
    final notifier = ref.read(capturaNotifierProvider.notifier);
    final hitIdx = _hitTestCircle(localPosition, extraPadding: 0);
    if (hitIdx != null) {
      final label = state.current!.detections[hitIdx].label;
      notifier.removeDetection(state.currentIndex, hitIdx);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$label removido'),
          duration: const Duration(milliseconds: 500),
        ),
      );
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
    final isOver = totalCount > widget.dofItem.saldoTotal;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.green,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () => context.pop(),
        ),
        title: Text(
          widget.dofItem.produto,
          style: const TextStyle(
            color: AppColors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: state.modelError
                ? const Icon(Icons.error_outline,
                    color: Colors.red, size: 20)
                : !state.modelReady
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.black,
                        ),
                      )
                    : Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.black,
                          shape: BoxShape.circle,
                        ),
                      ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
          _HeaderCard(
            dofItem: widget.dofItem,
            totalCount: totalCount,
            isOver: isOver,
          ),

          // ── Image area ──────────────────────────────────────────────
          Expanded(
            child: session == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.image_search_outlined,
                            size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          'Selecione uma imagem para começar',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
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
                                      color: AppColors.green, width: 2),
                                )
                              : null,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
                                  final s = Size(constraints.maxWidth,
                                      constraints.maxHeight);
                                  if (_currentWidgetSize != s) {
                                    setState(
                                        () => _currentWidgetSize = s);
                                  }
                                });

                                final aspectRatio =
                                    session.decodedImage != null
                                        ? session.decodedImage!.width /
                                            session.decodedImage!.height
                                        : 1.0;

                                final inRegionMode = state.isRegionMode ||
                                    session.awaitingRegionSelection;

                                return InteractiveViewer(
                                  transformationController:
                                      _transformController,
                                  panEnabled: !inRegionMode &&
                                      !state.isEditMode,
                                  scaleEnabled: true,
                                  minScale: 1.0,
                                  maxScale: 6.0,
                                  boundaryMargin: EdgeInsets.zero,
                                  child: AspectRatio(
                                    aspectRatio: aspectRatio,
                                    child: GestureDetector(
                                      onTapUp: state.isEditMode
                                          ? (d) => _handleEditTap(
                                              d.localPosition, state)
                                          : null,
                                      onPanStart:
                                          (inRegionMode || state.isEditMode)
                                              ? (d) => _handlePanStart(
                                                  d, constraints, state)
                                              : null,
                                      onPanUpdate:
                                          (inRegionMode || state.isEditMode)
                                              ? (d) => _handlePanUpdate(
                                                  d, constraints, state)
                                              : null,
                                      onPanEnd:
                                          (inRegionMode || state.isEditMode)
                                              ? (d) =>
                                                  _handlePanEnd(d, state)
                                              : null,
                                      child: Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          Image.file(
                                            session.imageFile,
                                            fit: BoxFit.fill,
                                          ),
                                          if (session.detections.isNotEmpty)
                                            CustomPaint(
                                              painter: BoundingBoxPainter(
                                                _resultsForDisplay(session),
                                              ),
                                            ),
                                          if ((session.savedRegions
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
                                                child: Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 16,
                                                    vertical: 10,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white
                                                        .withValues(
                                                            alpha: 0.90),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                    border: Border.all(
                                                      color: AppColors.green,
                                                      width: 1.5,
                                                    ),
                                                  ),
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Text(
                                                        session.awaitingRegionSelection
                                                            ? 'Arraste para selecionar área'
                                                            : 'Solte para confirmar',
                                                        style: const TextStyle(
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color:
                                                              Colors.black87,
                                                        ),
                                                      ),
                                                      if (session
                                                          .awaitingRegionSelection)
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  top: 4),
                                                          child: Text(
                                                            'ou toque em "Detectar"',
                                                            style: TextStyle(
                                                              fontSize: 11,
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
                                          // X buttons for saved regions
                                          if (inRegionMode)
                                            for (int i = 0;
                                                i <
                                                    session
                                                        .savedRegions.length;
                                                i++)
                                              Positioned(
                                                left: (session.savedRegions[i]
                                                            .right *
                                                        constraints.maxWidth -
                                                    16)
                                                    .clamp(
                                                        0.0,
                                                        constraints.maxWidth -
                                                            28),
                                                top: (session.savedRegions[i]
                                                            .top *
                                                        constraints
                                                            .maxHeight -
                                                    16)
                                                    .clamp(
                                                        0.0,
                                                        constraints.maxHeight -
                                                            28),
                                                child: GestureDetector(
                                                  behavior: HitTestBehavior
                                                      .opaque,
                                                  onTap: () => ref
                                                      .read(
                                                          capturaNotifierProvider
                                                              .notifier)
                                                      .removeSavedRegion(i),
                                                  child: Container(
                                                    width: 20,
                                                    height: 20,
                                                    decoration:
                                                        const BoxDecoration(
                                                      color: Colors.red,
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: const Icon(
                                                      Icons.close,
                                                      size: 12,
                                                      color: Colors.white,
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
                                              child: IgnorePointer(
                                                child: Center(
                                                  child: Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      horizontal: 12,
                                                      vertical: 6,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius
                                                              .circular(20),
                                                      color: Colors.white
                                                          .withValues(
                                                              alpha: 0.9),
                                                      border: Border.all(
                                                          color: Colors
                                                              .grey.shade400),
                                                    ),
                                                    child: Text(
                                                      '✏  TOQUE PARA EDITAR',
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Colors
                                                            .grey.shade600,
                                                        letterSpacing: 0.5,
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
                                                          color: Colors.white),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                        ],
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
                                      .read(capturaNotifierProvider.notifier)
                                      .navigateTo(state.currentIndex - 1);
                                  _transformController.value =
                                      Matrix4.identity();
                                },
                                child: Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: AppColors.green
                                        .withValues(alpha: 0.85),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.chevron_left,
                                      color: Colors.white, size: 20),
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
                                      .read(capturaNotifierProvider.notifier)
                                      .navigateTo(state.currentIndex + 1);
                                  _transformController.value =
                                      Matrix4.identity();
                                },
                                child: Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: AppColors.green
                                        .withValues(alpha: 0.85),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.chevron_right,
                                      color: Colors.white, size: 20),
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
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
                      child: ElevatedButton.icon(
                        onPressed: () => ref
                            .read(capturaNotifierProvider.notifier)
                            .confirmRegionAndProcess(),
                        icon: const Icon(Icons.check),
                        label: Text(
                          session.savedRegions.isEmpty
                              ? 'Detectar'
                              : 'Detectar ${session.savedRegions.length} Área(s)',
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
                                isActive: state.isRegionMode),
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
                                isActive: state.isEditMode),
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
                                    .read(capturaNotifierProvider.notifier)
                                    .undo(),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: Colors.grey.shade400,
                                    width: 1.5,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
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

                // FAB when no photos
                if (state.fotos.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 30),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: _showImageSourceSheet,
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color:
                                AppColors.green.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.add,
                              color: Colors.white, size: 24),
                        ),
                      ),
                    ),
                  ),

                // Save button
                if (state.fotos.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed:
                            state.isProcessing ? null : _saveAndPop,
                        icon: const Icon(Icons.check_circle,
                            color: Colors.white),
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
          if (_hasExistingSession && state.isProcessing && state.fotos.isEmpty)
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
                  child: const Icon(Icons.add,
                      color: Colors.white, size: 20),
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
                ref
                    .read(capturaNotifierProvider.notifier)
                    .navigateTo(i);
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
                          : Border.all(
                              color: Colors.grey.shade500, width: 1),
                    ),
                    child: ClipRRect(
                      borderRadius:
                          BorderRadius.circular(isActive ? 2 : 3),
                      child: Image.file(state.fotos[i].imageFile,
                          fit: BoxFit.cover),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(2),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 3, vertical: 1),
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
  final int totalCount;
  final bool isOver;

  const _HeaderCard({
    required this.dofItem,
    required this.totalCount,
    required this.isOver,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                      fontWeight: FontWeight.bold, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${dofItem.especieCientifico} (${dofItem.nomePopular})',
                  style: TextStyle(
                      fontSize: 11, color: Colors.grey.shade600),
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
              Text('Contagem',
                  style: TextStyle(
                      fontSize: 10, color: Colors.grey.shade600)),
              Text(
                '$totalCount',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isOver
                      ? Colors.red.shade700
                      : AppColors.green,
                ),
              ),
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
    final allRegions = [
      ...savedRegions,
      if (draggingRegion != null) draggingRegion!,
    ];

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
      const handleSize = 8.0;
      for (final corner in [
        Offset(rect.left, rect.top),
        Offset(rect.right, rect.top),
        Offset(rect.left, rect.bottom),
        Offset(rect.right, rect.bottom),
      ]) {
        canvas.drawRect(
          Rect.fromCenter(
              center: corner,
              width: handleSize,
              height: handleSize),
          handlePaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _RegionSelectorPainter oldDelegate) =>
      oldDelegate.savedRegions != savedRegions ||
      oldDelegate.draggingRegion != draggingRegion;
}
