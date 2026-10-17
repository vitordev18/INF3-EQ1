import 'dart:io';

import 'package:excel/excel.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fiscaliza/features/dof/data/services/excel_parser_service.dart';

void main() {
  late Directory tmp;

  setUp(() async {
    tmp = await Directory.systemTemp.createTemp('dof_xlsx_test');
  });

  tearDown(() async {
    if (tmp.existsSync()) await tmp.delete(recursive: true);
  });

  Future<File> planilha(List<List<String>> linhas) async {
    final excel = Excel.createExcel();
    final sheet = excel[excel.getDefaultSheet()!];
    for (final linha in linhas) {
      sheet.appendRow(linha.map((c) => TextCellValue(c)).toList());
    }
    final f = File('${tmp.path}/dof.xlsx');
    await f.writeAsBytes(excel.encode()!);
    return f;
  }

  const cabecalho = [
    'Número',
    'Produto',
    'Espécie (Científico)',
    'Nome Popular',
    'Saldo Livre',
    'Saldo Total',
    'Unidade',
  ];

  const linhaItem = [
    '001',
    'Madeira serrada',
    'Goupia glabra',
    'Cupiúba',
    '6.57',
    '32.13',
    'm³',
  ];

  test('lê planilha com cabeçalho na primeira linha', () async {
    final f = await planilha([cabecalho, linhaItem]);

    final itens = await ExcelParserService.parseFile(file: f);

    expect(itens, hasLength(1));
    expect(itens.single.numero, '001');
    expect(itens.single.especieCientifico, 'Goupia glabra');
    expect(itens.single.saldoTotal, 32.13);
  });

  test('encontra o cabeçalho abaixo de linhas de identificação', () async {
    final f = await planilha([
      ['DOCUMENTO DE ORIGEM FLORESTAL'],
      ['Madeireira Rio Verde Ltda'],
      ['CNPJ: 12.345.678/0001-90'],
      [],
      cabecalho,
      linhaItem,
    ]);

    final itens = await ExcelParserService.parseFile(file: f);

    expect(itens, hasLength(1));
    expect(itens.single.nomePopular, 'Cupiúba');
  });

  test('não confunde as linhas acima do cabeçalho com itens', () async {
    final f = await planilha([
      ['Relatório emitido em 10/09/2026'],
      cabecalho,
      linhaItem,
      linhaItem,
    ]);

    final itens = await ExcelParserService.parseFile(file: f);

    expect(itens, hasLength(2));
  });

  test('reconhece cabeçalho de espécie sem a palavra científico', () async {
    final f = await planilha([
      ['Número', 'Produto', 'Espécie', 'Nome Popular', 'Saldo Livre', 'Saldo Total'],
      ['001', 'Madeira serrada', 'Goupia glabra', 'Cupiúba', '1', '2'],
    ]);

    final itens = await ExcelParserService.parseFile(file: f);

    expect(itens.single.especieCientifico, 'Goupia glabra');
  });

  test('unidade ausente assume m³', () async {
    final f = await planilha([
      ['Número', 'Produto', 'Espécie', 'Nome Popular', 'Saldo Livre', 'Saldo Total'],
      ['001', 'Madeira serrada', 'Goupia glabra', 'Cupiúba', '1', '2'],
    ]);

    final itens = await ExcelParserService.parseFile(file: f);

    expect(itens.single.unidade, 'm³');
  });

  test('lê o cabeçalho real do DOF, com N° corrompido pelo encoding', () async {
    final f = await planilha([
      [
        'NÃ°',
        'Produto',
        'Especie',
        'Nome Popular',
        'Saldo livre',
        'Saldo total',
        'Unidade',
      ],
      linhaItem,
    ]);

    final itens = await ExcelParserService.parseFile(file: f);

    expect(itens, hasLength(1));
    expect(itens.single.numero, '001');
    expect(itens.single.produto, 'Madeira serrada');
    expect(itens.single.especieCientifico, 'Goupia glabra');
    expect(itens.single.nomePopular, 'Cupiúba');
    expect(itens.single.saldoLivre, 6.57);
    expect(itens.single.saldoTotal, 32.13);
  });

  test('aceita as variações N°, Nº e N. na coluna de ordem', () async {
    for (final rotulo in ['N°', 'Nº', 'N.', 'Nº ', 'N']) {
      final f = await planilha([
        [rotulo, 'Produto', 'Especie', 'Nome Popular', 'Saldo livre', 'Saldo total'],
        ['007', 'Madeira serrada', 'Goupia glabra', 'Cupiúba', '1', '2'],
      ]);

      final itens = await ExcelParserService.parseFile(file: f);
      expect(itens.single.numero, '007', reason: 'rótulo "$rotulo"');
    }
  });

  test('coluna Nome Popular não é confundida com a de número', () async {
    final f = await planilha([
      ['NÃ°', 'Produto', 'Especie', 'Nome Popular', 'Saldo livre', 'Saldo total'],
      ['001', 'Madeira serrada', 'Goupia glabra', 'Cupiúba', '1', '2'],
    ]);

    final itens = await ExcelParserService.parseFile(file: f);

    expect(itens.single.numero, '001');
    expect(itens.single.nomePopular, 'Cupiúba');
  });

  test('repara o encoding dos dados, não só do cabeçalho', () async {
    final f = await planilha([
      ['NÃ°', 'Produto', 'Especie', 'Nome Popular', 'Saldo livre', 'Saldo total'],
      [
        '001',
        'Madeira beneficiada',
        'CedrÃ£o',
        'CupiÃºba',
        '1',
        '2',
      ],
    ]);

    final itens = await ExcelParserService.parseFile(file: f);

    expect(itens.single.especieCientifico, 'Cedrão');
    expect(itens.single.nomePopular, 'Cupiúba');
  });

  test('erro de coluna faltando nomeia o que falta e o que foi lido', () async {
    final f = await planilha([
      ['Produto', 'Observação'],
      ['Madeira serrada', 'qualquer'],
    ]);

    await expectLater(
      ExcelParserService.parseFile(file: f),
      throwsA(
        isA<Exception>().having(
          (e) => e.toString(),
          'mensagem',
          allOf(contains('Nome Popular'), contains('Observação')),
        ),
      ),
    );
  });

  test('planilha sem coluna Produto avisa que o cabeçalho não foi achado',
      () async {
    final f = await planilha([
      ['Coluna A', 'Coluna B'],
      ['1', '2'],
    ]);

    await expectLater(
      ExcelParserService.parseFile(file: f),
      throwsA(
        isA<Exception>().having(
          (e) => e.toString(),
          'mensagem',
          contains('Cabeçalho não encontrado'),
        ),
      ),
    );
  });
}
