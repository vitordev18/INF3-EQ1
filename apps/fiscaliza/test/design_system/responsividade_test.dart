import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fiscaliza/features/fiscalizacao/presentation/cadastro/cadastro_screen.dart';
import 'package:fiscaliza/features/fiscalizacao/presentation/validacao/validacao_screen.dart';

void main() {
  const tamanhos = <String, Size>{
    'compacto (320x568)': Size(320, 568),
    'comum (411x891)': Size(411, 891),
    'grande (480x1024)': Size(480, 1024),
    'tablet (768x1024)': Size(768, 1024),
  };

  Future<void> renderizarSemOverflow(
    WidgetTester tester,
    Widget tela,
    Size size,
  ) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(MaterialApp(home: tela));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  }

  for (final entry in tamanhos.entries) {
    testWidgets('CadastroScreen renderiza em ${entry.key}', (tester) async {
      await renderizarSemOverflow(tester, const CadastroScreen(), entry.value);
    });

    testWidgets('ValidacaoScreen renderiza em ${entry.key}', (tester) async {
      await renderizarSemOverflow(tester, const ValidacaoScreen(), entry.value);
    });
  }

  testWidgets('texto acompanha fonte ampliada do sistema', (tester) async {
    await tester.pumpWidget(
      const MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(1.5)),
        child: MaterialApp(home: CadastroScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
