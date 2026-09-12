import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fiscaliza/design_system/components/status_pill.dart';
import 'package:fiscaliza/features/fiscalizacao/domain/entities/status_fiscalizacao.dart';

void main() {
  Widget montar(StatusFiscalizacao status) =>
      MaterialApp(home: Scaffold(body: Center(child: StatusPill(status))));

  group('StatusPill', () {
    testWidgets('renderiza o rótulo de cada status', (tester) async {
      const esperado = {
        StatusFiscalizacao.pendente: 'Pendente',
        StatusFiscalizacao.emAndamento: 'Em Andamento',
        StatusFiscalizacao.concluido: 'Concluído',
        StatusFiscalizacao.excedente: 'Excedente',
      };

      for (final entry in esperado.entries) {
        await tester.pumpWidget(montar(entry.key));
        expect(find.text(entry.value), findsOneWidget,
            reason: 'status ${entry.key.name}');
      }
    });

    testWidgets('excedente é visualmente distinto de concluído',
        (tester) async {
      expect(
        StatusPill.colorFor(StatusFiscalizacao.excedente),
        isNot(StatusPill.colorFor(StatusFiscalizacao.concluido)),
      );
    });

    test('cada status tem cor e texto próprios', () {
      final cores = StatusFiscalizacao.values.map(StatusPill.colorFor).toSet();
      final textos = StatusFiscalizacao.values.map(StatusPill.textFor).toSet();

      expect(cores, hasLength(StatusFiscalizacao.values.length));
      expect(textos, hasLength(StatusFiscalizacao.values.length));
    });

    testWidgets('texto não quebra em tela estreita', (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(montar(StatusFiscalizacao.emAndamento));

      expect(tester.takeException(), isNull);
      expect(find.text('Em Andamento'), findsOneWidget);
    });
  });
}
