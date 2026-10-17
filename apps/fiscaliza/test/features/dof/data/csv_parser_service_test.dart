import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:fiscaliza/features/dof/data/services/csv_parser_service.dart';

void main() {
  late Directory tmp;

  setUp(() async {
    tmp = await Directory.systemTemp.createTemp('dof_test');
  });

  tearDown(() async {
    if (tmp.existsSync()) await tmp.delete(recursive: true);
  });

  Future<File> csv(String conteudo) async {
    final f = File('${tmp.path}/dof.csv');
    await f.writeAsString(conteudo);
    return f;
  }

  const cabecalho =
      'Número,Produto,Espécie (Científico),Nome Popular,Saldo Livre,Saldo Total,Unidade';

  test('lê um arquivo bem formado', () async {
    final f = await csv(
      '$cabecalho\n'
      '001,Madeira serrada,Goupia glabra,Cupiúba,6.57,32.13,m³\n'
      '002,Madeira beneficiada,Dipteryx odorata,Cumaru,1.42,1.42,m³\n',
    );

    final itens = await CsvParserService.parseFile(file: f);

    expect(itens, hasLength(2));
    expect(itens.first.numero, '001');
    expect(itens.first.nomePopular, 'Cupiúba');
    expect(itens.first.saldoTotal, 32.13);
    expect(itens.last.especieCientifico, 'Dipteryx odorata');
  });

  test('converte vírgula decimal brasileira', () async {
    final f = await csv(
      '$cabecalho\n'
      '001,Tora,Swietenia macrophylla,Mogno,"45,80","100,00",m³\n',
    );

    final itens = await CsvParserService.parseFile(file: f);

    expect(itens.single.saldoLivre, 45.80);
    expect(itens.single.saldoTotal, 100.00);
  });

  test('gera um id único por item', () async {
    final f = await csv(
      '$cabecalho\n'
      '001,Tora,Especie A,Popular A,1,2,m³\n'
      '002,Tora,Especie B,Popular B,1,2,m³\n',
    );

    final itens = await CsvParserService.parseFile(file: f);

    expect(itens.map((i) => i.id).toSet(), hasLength(2));
    expect(itens.every((i) => i.id.isNotEmpty), isTrue);
  });

  test('unidade ausente assume m³', () async {
    final f = await csv(
      'Número,Produto,Espécie (Científico),Nome Popular,Saldo Livre,Saldo Total\n'
      '001,Tora,Especie A,Popular A,1,2\n',
    );

    final itens = await CsvParserService.parseFile(file: f);

    expect(itens.single.unidade, 'm³');
  });

  test('linhas em branco no meio são ignoradas', () async {
    final f = await csv(
      '$cabecalho\n'
      '001,Tora,Especie A,Popular A,1,2,m³\n'
      '\n'
      '002,Tora,Especie B,Popular B,1,2,m³\n',
    );

    final itens = await CsvParserService.parseFile(file: f);

    expect(itens, hasLength(2));
  });

  test('arquivo sem colunas obrigatórias falha com erro claro', () async {
    final f = await csv('Produto,Observação\nTora,qualquer\n');

    expect(
      () => CsvParserService.parseFile(file: f),
      throwsA(
        isA<Exception>().having(
          (e) => e.toString(),
          'mensagem',
          contains('obrigatórias'),
        ),
      ),
    );
  });

  test('arquivo vazio falha em vez de devolver lista vazia', () async {
    final f = await csv('');

    expect(() => CsvParserService.parseFile(file: f), throwsA(isA<Exception>()));
  });

  test('lê o cabeçalho real do DOF, com N° corrompido pelo encoding', () async {
    final f = await csv(
      'NÃ°,Produto,Especie,Nome Popular,Saldo livre,Saldo total,Unidade\n'
      '001,Madeira serrada,Goupia glabra,Cupiúba,6.57,32.13,m³\n',
    );

    final itens = await CsvParserService.parseFile(file: f);

    expect(itens.single.numero, '001');
    expect(itens.single.especieCientifico, 'Goupia glabra');
    expect(itens.single.saldoTotal, 32.13);
  });

  test('aceita as variações N°, Nº e N. na coluna de ordem', () async {
    for (final rotulo in ['N°', 'Nº', 'N.', 'N']) {
      final f = await csv(
        '$rotulo,Produto,Especie,Nome Popular,Saldo livre,Saldo total\n'
        '007,Madeira serrada,Goupia glabra,Cupiúba,1,2\n',
      );

      final itens = await CsvParserService.parseFile(file: f);
      expect(itens.single.numero, '007', reason: rotulo);
    }
  });

  test('coluna Nome Popular não é confundida com a de número', () async {
    final f = await csv(
      'NÃ°,Produto,Especie,Nome Popular,Saldo livre,Saldo total\n'
      '001,Madeira serrada,Goupia glabra,Cupiúba,1,2\n',
    );

    final itens = await CsvParserService.parseFile(file: f);

    expect(itens.single.numero, '001');
    expect(itens.single.nomePopular, 'Cupiúba');
  });

  test('reconhece cabeçalho de espécie sem a palavra científico', () async {
    final f = await csv(
      'Número,Produto,Espécie,Nome Popular,Saldo Livre,Saldo Total\n'
      '001,Madeira serrada,Goupia glabra,Cupiúba,1,2\n',
    );

    final itens = await CsvParserService.parseFile(file: f);

    expect(itens.single.especieCientifico, 'Goupia glabra');
  });

  test('repara o encoding dos dados, não só do cabeçalho', () async {
    final f = await csv(
      '$cabecalho\n'
      '001,Madeira beneficiada,CedrÃ£o,CupiÃºba,1,2,m³\n',
    );

    final itens = await CsvParserService.parseFile(file: f);

    expect(itens.single.especieCientifico, 'Cedrão');
    expect(itens.single.nomePopular, 'Cupiúba');
  });
}
