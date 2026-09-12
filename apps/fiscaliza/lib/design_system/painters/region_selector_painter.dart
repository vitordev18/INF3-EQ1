import 'package:flutter/material.dart';

import 'package:fiscaliza/design_system/theme/app_colors.dart';

class RegionSelectorPainter extends CustomPainter {
  final List<Rect> savedRegions;
  final Rect? draggingRegion;

  RegionSelectorPainter(this.savedRegions, this.draggingRegion);

  @override
  void paint(Canvas canvas, Size size) {
    final allRegions = <Rect>[
      ...savedRegions,
      // ignore: use_null_aware_elements
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
      const handleRadius = 5.0;
      for (final corner in [
        Offset(rect.left, rect.top),
        Offset(rect.right, rect.top),
        Offset(rect.left, rect.bottom),
        Offset(rect.right, rect.bottom),
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
  bool shouldRepaint(covariant RegionSelectorPainter oldDelegate) =>
      oldDelegate.savedRegions != savedRegions ||
      oldDelegate.draggingRegion != draggingRegion;
}

