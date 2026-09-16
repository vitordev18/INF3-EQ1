import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fiscaliza/features/dof/data/models/dof_item_model.dart';
import 'package:fiscaliza/features/dof/presentation/upload/upload_dof_screen.dart';
import 'package:fiscaliza/features/dof/presentation/upload/upload_dof_view_model.dart';

class _VmComItens extends UploadDofViewModel {
  final List<DofItemModel> itens;

  _VmComItens(this.itens);

  @override
  UploadDofState build() => UploadDofState(parsedItems: itens);
}

void main() {
  DofItemModel item({
    required String numero,
    required String produto,
    required String especie,
    String popular = 'Cupiúba',
    double saldoTotal = 32.13,
  }) => DofItemModel(
    id: numero,
    numero: numero,
    produto: produto,
    especieCientifico: especie,
    nomePopular: popular,
    saldoLivre: 1,
    saldoTotal: saldoTotal,
    unidade: 'm³',
  );

  Future<void> montar(WidgetTester tester, List<DofItemModel> itens) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          uploadDofViewModelProvider.overrideWith(() => _VmComItens(itens)),
        ],
        child: const MaterialApp(home: UploadDofScreen()),
      ),
    );
    await tester.pump();
  }

  testWidgets('itens lidos aparecem como lista, sem DataTable', (tester) async {
    await montar(tester, [
      item(numero: '001', produto: 'Madeira serrada', especie: 'Goupia glabra'),
      item(numero: '002', produto: 'Madeira beneficiada', especie: 'Dipteryx odorata'),
    ]);

    expect(find.byType(DataTable), findsNothing);
    expect(find.text('Madeira serrada'), findsOneWidget);
    expect(find.text('Madeira beneficiada'), findsOneWidget);
    expect(find.text('2 itens lidos'), findsOneWidget);
  });

  testWidgets('cada item mostra número, espécie e saldo declarado',
      (tester) async {
    await montar(tester, [
      item(numero: '007', produto: 'Madeira serrada', especie: 'Goupia glabra'),
    ]);

    expect(find.text('N° 007'), findsOneWidget);
    expect(find.text('Espécie: Goupia glabra (Cupiúba)'), findsOneWidget);
    expect(find.textContaining('Saldo Declarado: 32.13 m³'), findsOneWidget);
  });

  testWidgets('singular quando há um item só', (tester) async {
    await montar(tester, [
      item(numero: '001', produto: 'Madeira serrada', especie: 'Goupia glabra'),
    ]);

    expect(find.text('1 item lido'), findsOneWidget);
  });

  testWidgets('renderiza sem overflow em tela estreita', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await montar(tester, [
      item(
        numero: '001',
        produto: 'Madeira beneficiada de lei para construção civil',
        especie: 'Handroanthus serratifolius',
        popular: 'Ipê Amarelo',
      ),
    ]);

    expect(tester.takeException(), isNull);
  });

  testWidgets('sem itens exibe o estado vazio', (tester) async {
    await montar(tester, []);

    expect(
      find.textContaining('Nenhum dado para exibir'),
      findsOneWidget,
    );
  });
}
