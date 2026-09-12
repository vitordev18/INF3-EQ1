import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fiscaliza/app/app.dart';
import 'package:fiscaliza/features/splash/splash_screen.dart';

void main() {
  testWidgets('app inicia na splash com o tema aplicado', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: App()));
    await tester.pump();

    expect(find.byType(SplashScreen), findsOneWidget);

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.theme, isNotNull);
    expect(app.theme!.useMaterial3, isTrue);
    expect(app.title, 'FISCALIZA');

    await tester.pump(const Duration(milliseconds: 1300));
  });
}
