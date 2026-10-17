import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fiscaliza/design_system/components/action_bottom_bar.dart';
import 'package:fiscaliza/features/dof/data/models/dof_item_model.dart';
import 'package:fiscaliza/features/fiscalizacao/data/fiscalizacao_providers.dart';
import 'package:fiscaliza/features/fiscalizacao/presentation/hub/hub_fiscalizacao_screen.dart';

void main() {
  DofItemModel item(String numero) => DofItemModel(
    id: numero,
    numero: numero,
    produto: 'Madeira serrada',
    especieCientifico: 'Goupia glabra',
    nomePopular: 'Cupiúba',
    saldoLivre: 1,
    saldoTotal: 32.13,
    unidade: 'm³',
  );

  Future<void> montar(WidgetTester tester, List<DofItemModel> itens) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          itensDaSessaoAtivaProvider.overrideWithValue(itens),
        ],
        child: const MaterialApp(home: FiscalizacaoHubScreen()),
      ),
    );
    await tester.pump();
  }

  testWidgets('FAB Produto Extra não sobrepõe a barra Concluir Fiscalização',
      (tester) async {
    await montar(tester, [item('001'), item('002')]);

    final fab = tester.getRect(find.byType(FloatingActionButton));
    final barra = tester.getRect(find.byType(ActionBottomBar));

    expect(
      fab.bottom,
      lessThanOrEqualTo(barra.top),
      reason: 'o FAB precisa terminar antes de a barra começar',
    );
  });

  testWidgets('FAB fica ancorado no canto inferior direito', (tester) async {
    await montar(tester, [item('001')]);

    final fab = tester.getRect(find.byType(FloatingActionButton));
    final tela = tester.getRect(find.byType(MaterialApp));

    expect(
      fab.right,
      greaterThan(tela.width / 2),
      reason: 'deve estar na metade direita da tela',
    );
    expect(
      tela.width - fab.right,
      lessThan(32),
      reason: 'deve estar encostado na margem direita',
    );
  });

  testWidgets('FAB é posicionado pelo Scaffold, não por um Stack manual',
      (tester) async {
    await montar(tester, [item('001')]);

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
    expect(scaffold.floatingActionButton, isNotNull);
  });

  testWidgets('sem itens o FAB não aparece', (tester) async {
    await montar(tester, []);

    expect(find.byType(FloatingActionButton), findsNothing);
    expect(find.textContaining('Nenhum produto lido'), findsOneWidget);
  });

  testWidgets('último item da lista continua alcançável abaixo do FAB',
      (tester) async {
    await montar(tester, [
      for (int i = 1; i <= 12; i++) item(i.toString().padLeft(3, '0')),
    ]);

    await tester.drag(
      find.byType(SingleChildScrollView).first,
      const Offset(0, -2000),
    );
    await tester.pump();

    final scrollView = tester.widget<SingleChildScrollView>(
      find.byType(SingleChildScrollView).first,
    );
    expect(
      scrollView.padding,
      const EdgeInsets.only(bottom: 88),
      reason: 'a lista reserva espaço para o FAB no fim da rolagem',
    );
    expect(tester.takeException(), isNull);
  });
}
