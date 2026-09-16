import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fiscaliza/features/relatorio/data/relatorio_providers.dart';
import 'package:fiscaliza/features/relatorio/domain/linha_relatorio.dart';
import 'package:fiscaliza/features/relatorio/presentation/relatorio_screen.dart';

void main() {
  CabecalhoRelatorio cabecalho() => CabecalhoRelatorio(
    madeireiraNome: 'Madeireira Rio Verde',
    cnpj: '12.345.678/0001-90',
    endereco: 'Rod. BR-163, km 42',
    dataFiscalizacao: DateTime(2026, 9, 15),
  );

  LinhaRelatorio linha({
    int numeroOrdem = 1,
    double totalFisicoM3 = 0.45,
    double? totalDofM3 = 10,
    double diferencaM3 = 9.55,
    bool primeira = true,
  }) => LinhaRelatorio(
    numeroOrdem: numeroOrdem,
    especieCientifico: 'Goupia glabra',
    nomePopular: 'Cupiúba',
    larguraCm: 30,
    alturaCm: 5,
    comprimentoM: 3,
    quantidade: 10,
    totalFisicoM3: totalFisicoM3,
    totalDofM3: totalDofM3,
    diferencaM3: diferencaM3,
    isPrimeiraDaEspecie: primeira,
  );

  Future<void> montar(WidgetTester tester, Stream<Relatorio?> stream) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          relatorioSessaoAtivaProvider.overrideWith((ref) => stream),
        ],
        child: const MaterialApp(home: RelatorioScreen()),
      ),
    );
    await tester.pump();
  }

  testWidgets('exibe cabeçalho e card da espécie, sem tabela', (tester) async {
    await montar(
      tester,
      Stream.value(Relatorio(cabecalho: cabecalho(), linhas: [linha()])),
    );

    expect(find.byType(DataTable), findsNothing);
    expect(find.text('Madeireira Rio Verde'), findsOneWidget);
    expect(find.text('12.345.678/0001-90'), findsOneWidget);
    expect(find.text('15/09/2026'), findsOneWidget);
    expect(find.text('Goupia glabra'), findsOneWidget);
    expect(find.text('Cupiúba'), findsOneWidget);
    expect(find.text('TOTAL DOF'), findsOneWidget);
    expect(find.text('N° 1'), findsOneWidget);
    expect(find.text('30.0 × 5.0 cm × 3.00 m'), findsOneWidget);
    expect(find.text('Saldo restante'), findsOneWidget);
  });

  testWidgets('espécie com duas medidas vira um card com duas linhas',
      (tester) async {
    await montar(
      tester,
      Stream.value(
        Relatorio(
          cabecalho: cabecalho(),
          linhas: [
            linha(),
            linha(
              numeroOrdem: 2,
              totalFisicoM3: 0.30,
              totalDofM3: null,
              diferencaM3: 9.25,
              primeira: false,
            ),
          ],
        ),
      ),
    );

    expect(find.text('Goupia glabra'), findsOneWidget);
    expect(find.text('TOTAL DOF'), findsOneWidget);
    expect(find.text('N° 1'), findsOneWidget);
    expect(find.text('N° 2'), findsOneWidget);
    expect(find.text('9.250 m³'), findsWidgets);
  });

  testWidgets('diferença negativa marca o card como excedente', (tester) async {
    await montar(
      tester,
      Stream.value(
        Relatorio(
          cabecalho: cabecalho(),
          linhas: [linha(diferencaM3: -1.5)],
        ),
      ),
    );

    expect(find.text('Excedente'), findsOneWidget);
    expect(find.text('Saldo restante'), findsNothing);
  });

  testWidgets('espécie sem medição informa a ausência', (tester) async {
    await montar(
      tester,
      Stream.value(
        Relatorio(
          cabecalho: cabecalho(),
          linhas: [
            const LinhaRelatorio(
              numeroOrdem: 1,
              especieCientifico: 'Goupia glabra',
              nomePopular: 'Cupiúba',
              larguraCm: 0,
              alturaCm: 0,
              comprimentoM: 0,
              quantidade: 0,
              totalFisicoM3: 0,
              totalDofM3: 7.5,
              diferencaM3: 7.5,
              isPrimeiraDaEspecie: true,
            ),
          ],
        ),
      ),
    );

    expect(
      find.text('Nenhuma medida registrada para esta espécie.'),
      findsOneWidget,
    );
  });

  testWidgets('renderiza sem overflow em tela estreita', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await montar(
      tester,
      Stream.value(
        Relatorio(
          cabecalho: cabecalho(),
          linhas: [
            const LinhaRelatorio(
              numeroOrdem: 1,
              especieCientifico: 'Handroanthus serratifolius',
              nomePopular: 'Ipê Amarelo',
              larguraCm: 30,
              alturaCm: 5,
              comprimentoM: 3,
              quantidade: 1200,
              totalFisicoM3: 54.1234,
              totalDofM3: 1234.5678,
              diferencaM3: 1180.4444,
              isPrimeiraDaEspecie: true,
            ),
          ],
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('campo em branco aparece como Não informado', (tester) async {
    final semCnpj = CabecalhoRelatorio(
      madeireiraNome: 'Madeireira Rio Verde',
      cnpj: '',
      endereco: '',
      dataFiscalizacao: DateTime(2026, 9, 15),
    );

    await montar(
      tester,
      Stream.value(Relatorio(cabecalho: semCnpj, linhas: [linha()])),
    );

    expect(find.text('Não informado'), findsNWidgets(2));
  });

  testWidgets('atualiza a tela quando o provider emite de novo',
      (tester) async {
    final controller = StreamController<Relatorio?>();
    addTearDown(controller.close);

    await montar(tester, controller.stream);

    controller.add(Relatorio(cabecalho: cabecalho(), linhas: [linha()]));
    await tester.pump();
    expect(find.text('Goupia glabra'), findsOneWidget);

    controller.add(
      Relatorio(
        cabecalho: cabecalho(),
        linhas: [
          linha(),
          linha(
            numeroOrdem: 2,
            totalFisicoM3: 0.30,
            totalDofM3: null,
            diferencaM3: 9.25,
            primeira: false,
          ),
        ],
      ),
    );
    await tester.pump();

    expect(find.text('Goupia glabra'), findsOneWidget);
    expect(find.text('N° 2'), findsOneWidget);
  });

  testWidgets('sem sessão ativa mostra a mensagem correspondente',
      (tester) async {
    await montar(tester, Stream.value(null));

    expect(
      find.text('Nenhuma fiscalização em andamento.'),
      findsOneWidget,
    );
  });

  testWidgets('sessão sem itens mostra a mensagem de relatório vazio',
      (tester) async {
    await montar(
      tester,
      Stream.value(Relatorio(cabecalho: cabecalho(), linhas: const [])),
    );

    expect(
      find.text('Nenhum item importado nesta fiscalização.'),
      findsOneWidget,
    );
  });
}
