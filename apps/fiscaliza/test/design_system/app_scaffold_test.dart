import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fiscaliza/design_system/components/app_scaffold.dart';

void main() {
  group('AppScaffold', () {
    testWidgets('renderiza o corpo informado', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: AppScaffold(body: Text('conteúdo'))),
      );

      expect(find.text('conteúdo'), findsOneWidget);
    });

    testWidgets('sem AppBar, protege a área de cima', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: AppScaffold(body: Text('x'))),
      );

      final safeArea = tester.widget<SafeArea>(
        find.ancestor(of: find.text('x'), matching: find.byType(SafeArea)).first,
      );
      expect(safeArea.top, isTrue);
    });

    testWidgets('com AppBar, não duplica a proteção de cima', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AppScaffold(appBar: AppBar(title: const Text('t')),
              body: const Text('x')),
        ),
      );

      final safeArea = tester.widget<SafeArea>(
        find.ancestor(of: find.text('x'), matching: find.byType(SafeArea)).first,
      );
      expect(safeArea.top, isFalse);
    });

    testWidgets('renderiza a barra inferior quando informada', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AppScaffold(body: Text('x'), bottomBar: Text('barra')),
        ),
      );

      expect(find.text('barra'), findsOneWidget);
    });
  });
}
