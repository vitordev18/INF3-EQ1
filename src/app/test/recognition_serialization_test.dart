import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/core/services/yolo_service.dart';

void main() {
  group('Recognition JSON serialization', () {
    test('round-trip preserves all fields for regular box', () {
      final original = Recognition(
        1,
        'tora',
        0.92,
        const Rect.fromLTRB(0.1, 0.2, 0.4, 0.6),
      );

      final json = original.toJson();
      final restored = Recognition.fromJson(json);

      expect(restored.classId, equals(1));
      expect(restored.label, equals('tora'));
      expect(restored.score, closeTo(0.92, 1e-9));
      expect(restored.location.left, closeTo(0.1, 1e-9));
      expect(restored.location.top, closeTo(0.2, 1e-9));
      expect(restored.location.right, closeTo(0.4, 1e-9));
      expect(restored.location.bottom, closeTo(0.6, 1e-9));
      expect(restored.angle, isNull);
    });

    test('round-trip preserves angle for OBB box', () {
      final original = Recognition(
        0,
        'madeira',
        0.78,
        const Rect.fromLTRB(0.0, 0.0, 0.5, 0.5),
        angle: 1.5708,
      );

      final json = original.toJson();
      final restored = Recognition.fromJson(json);

      expect(restored.angle, isNotNull);
      expect(restored.angle!, closeTo(1.5708, 1e-9));
    });

    test('toJson omits angle key when null', () {
      final r = Recognition(0, 'x', 0.5, const Rect.fromLTRB(0, 0, 1, 1));
      expect(r.toJson().containsKey('angle'), isFalse);
    });
  });
}
