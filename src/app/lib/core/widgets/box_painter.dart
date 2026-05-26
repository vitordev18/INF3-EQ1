import 'dart:math';
import 'package:flutter/material.dart';
import '../services/yolo_service.dart';

List<Recognition> sortDetectionsSpatially(List<Recognition> detections) {
  return List<Recognition>.from(detections)..sort((a, b) {
    final yCompare = a.location.top.compareTo(b.location.top);
    if (yCompare.abs() > 0.02) return yCompare;
    return a.location.left.compareTo(b.location.left);
  });
}

const List<Color> _boxColors = [
  Color(0xFF43A047),
];

class BoundingBoxPainter extends CustomPainter {
  final List<Recognition> detections;
  final bool isDarkMode;

  BoundingBoxPainter(this.detections, {this.isDarkMode = false});

  void _drawNumberedCircle(
      Canvas canvas, Size size, Recognition d, Color color, int number) {
    final cx = (d.location.left + d.location.right) / 2 * size.width;
    final cy = (d.location.top + d.location.bottom) / 2 * size.height;

    final boxWidth = d.location.width * size.width;
    final boxHeight = d.location.height * size.height;
    final halfMin = min(boxWidth, boxHeight) / 2;
    const padding = 3.0;
    final double maxAllowed = max(4.0, halfMin - padding);
    final double radius =
        (min(boxWidth, boxHeight) * 0.30).clamp(4.0, min(11.0, maxAllowed));
    final fontSize = (radius * 0.9).clamp(4.0, 9.0);

    canvas.drawCircle(
        Offset(cx, cy), radius, Paint()..color = color..style = PaintingStyle.fill);
    canvas.drawCircle(
        Offset(cx, cy),
        radius,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.5);

    final textPainter = TextPainter(
      text: TextSpan(
        text: '$number',
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(cx - textPainter.width / 2, cy - textPainter.height / 2),
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final sortedDetections = sortDetectionsSpatially(detections);

    for (var i = 0; i < sortedDetections.length; i++) {
      final d = sortedDetections[i];
      final number = i + 1;
      final color = _boxColors[d.classId % _boxColors.length];

      if (d.isOBB && d.angle != null) {
        _drawOBB(canvas, size, d, color);
      } else {
        _drawRegularBox(canvas, size, d, color);
      }

      _drawNumberedCircle(canvas, size, d, color, number);
    }
  }

  void _drawRegularBox(Canvas canvas, Size size, Recognition d, Color color) {
    final rect = Rect.fromLTRB(
      d.location.left * size.width,
      d.location.top * size.height,
      d.location.right * size.width,
      d.location.bottom * size.height,
    );

    canvas.drawRect(
        rect,
        Paint()
          ..color = color.withValues(alpha: 0.75)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0);
  }

  void _drawOBB(Canvas canvas, Size size, Recognition d, Color color) {
    final cx = (d.location.left + d.location.right) / 2 * size.width;
    final cy = (d.location.top + d.location.bottom) / 2 * size.height;
    final w = d.location.width * size.width;
    final h = d.location.height * size.height;

    final theta = d.angle!;
    final cosA = cos(theta);
    final sinA = sin(theta);
    final hw = w / 2;
    final hh = h / 2;

    final corners = [
      Offset(-hw, -hh),
      Offset(hw, -hh),
      Offset(hw, hh),
      Offset(-hw, hh),
    ];

    final rotated = corners
        .map((c) => Offset(
              cx + c.dx * cosA - c.dy * sinA,
              cy + c.dx * sinA + c.dy * cosA,
            ))
        .toList();

    final path = Path()
      ..moveTo(rotated[0].dx, rotated[0].dy)
      ..lineTo(rotated[1].dx, rotated[1].dy)
      ..lineTo(rotated[2].dx, rotated[2].dy)
      ..lineTo(rotated[3].dx, rotated[3].dy)
      ..close();

    canvas.drawPath(
        path,
        Paint()
          ..color = color.withValues(alpha: 0.75)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0);

    canvas.drawLine(
        rotated[0],
        rotated[1],
        Paint()
          ..color = color.withValues(alpha: 0.75)
          ..strokeWidth = 1.5
          ..strokeCap = StrokeCap.round);
  }

  @override
  bool shouldRepaint(covariant BoundingBoxPainter oldDelegate) =>
      oldDelegate.detections != detections;
}
