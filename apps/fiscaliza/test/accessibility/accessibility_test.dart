import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fiscaliza/features/fiscalizacao/presentation/cadastro/cadastro_screen.dart';
import 'package:fiscaliza/features/fiscalizacao/presentation/validacao/validacao_screen.dart';

void main() {
  Future<void> verificarDiretrizes(WidgetTester tester, Widget tela) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(MaterialApp(home: tela));

    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));

    handle.dispose();
  }

  testWidgets('CadastroScreen respeita as diretrizes de acessibilidade',
      (tester) async {
    await verificarDiretrizes(tester, const CadastroScreen());
  });

  testWidgets('ValidacaoScreen respeita as diretrizes de acessibilidade',
      (tester) async {
    await verificarDiretrizes(tester, const ValidacaoScreen());
  });
}
