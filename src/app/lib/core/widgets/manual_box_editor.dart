import 'package:flutter/material.dart';

class ManualBoxEditorPainter extends CustomPainter {
  final Rect normalizedRect;

  static const double handleRadius = 12.0;
  static const double handleHitRadius = 24.0;

  ManualBoxEditorPainter(this.normalizedRect);

  @override
  void paint(Canvas canvas, Size size) {
    final pixelRect = Rect.fromLTRB(
      normalizedRect.left * size.width,
      normalizedRect.top * size.height,
      normalizedRect.right * size.width,
      normalizedRect.bottom * size.height,
    );

    canvas.drawRect(
      pixelRect,
      Paint()
        ..color = Colors.blue.withAlpha(40)
        ..style = PaintingStyle.fill,
    );

    canvas.drawRect(
      pixelRect,
      Paint()
        ..color = Colors.blueAccent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    for (final corner in _corners(pixelRect)) {
      canvas.drawCircle(
        corner,
        handleRadius,
        Paint()
          ..color = Colors.blueAccent
          ..style = PaintingStyle.fill,
      );
      canvas.drawCircle(
        corner,
        handleRadius,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }

  List<Offset> _corners(Rect r) => [
        r.topLeft,
        r.topRight,
        r.bottomLeft,
        r.bottomRight,
      ];

  static int getHandleIndex(
    Offset tapPixel,
    Rect normalizedRect,
    Size widgetSize,
  ) {
    final pixelRect = Rect.fromLTRB(
      normalizedRect.left * widgetSize.width,
      normalizedRect.top * widgetSize.height,
      normalizedRect.right * widgetSize.width,
      normalizedRect.bottom * widgetSize.height,
    );
    final corners = [
      pixelRect.topLeft,
      pixelRect.topRight,
      pixelRect.bottomLeft,
      pixelRect.bottomRight,
    ];
    for (int i = 0; i < corners.length; i++) {
      if ((corners[i] - tapPixel).distance <= handleHitRadius) return i;
    }
    return -1;
  }

  @override
  bool shouldRepaint(covariant ManualBoxEditorPainter old) =>
      old.normalizedRect != normalizedRect;
}
