import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fiscaliza/design_system/components/app_icon.dart';
import 'package:fiscaliza/design_system/components/fiscaliza_list_tile.dart';

void main() {
  Future<void> montar(WidgetTester tester, Widget filho, {double largura = 320}) {
    tester.view.physicalSize = Size(largura, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    return tester.pumpWidget(
      MaterialApp(home: Scaffold(body: filho)),
    );
  }

  group('FiscalizaMetaChip', () {
    testWidgets('texto longo não estoura em tela estreita', (tester) async {
      await montar(
        tester,
        const FiscalizaMetaChip(
          icon: AppIcon.box,
          text: 'Saldo Declarado: 1234567.890 m³ de madeira beneficiada de lei',
          color: Colors.black,
        ),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('texto curto é exibido por inteiro', (tester) async {
      await montar(
        tester,
        const FiscalizaMetaChip(
          icon: AppIcon.box,
          text: 'Saldo: 32.130 m³',
          color: Colors.black,
        ),
      );

      expect(find.text('Saldo: 32.130 m³'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('FiscalizaListTile', () {
    testWidgets('exibe título, pill e linhas de meta', (tester) async {
      await montar(
        tester,
        const FiscalizaListTile(
          title: 'Madeira serrada',
          pill: Text('Pendente'),
          metaRows: [Text('Espécie: Goupia glabra')],
        ),
      );

      expect(find.text('Madeira serrada'), findsOneWidget);
      expect(find.text('Pendente'), findsOneWidget);
      expect(find.text('Espécie: Goupia glabra'), findsOneWidget);
    });

    testWidgets('título longo com pill não estoura', (tester) async {
      await montar(
        tester,
        const FiscalizaListTile(
          title: 'Madeira beneficiada de lei para construção civil pesada',
          pill: Text('Em Andamento'),
          metaRows: [
            FiscalizaMetaChip(
              icon: AppIcon.box,
              text: 'Saldo Declarado: 7222000.000 m³',
              color: Colors.black,
            ),
          ],
        ),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('mostra divisor só quando pedido', (tester) async {
      await montar(
        tester,
        const FiscalizaListTile(title: 'A', showDivider: true),
      );
      expect(find.byType(Divider), findsOneWidget);

      await montar(
        tester,
        const FiscalizaListTile(title: 'B', showDivider: false),
      );
      expect(find.byType(Divider), findsNothing);
    });
  });
}
