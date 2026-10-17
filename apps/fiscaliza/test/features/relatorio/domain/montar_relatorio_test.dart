import 'package:flutter_test/flutter_test.dart';

import 'package:fiscaliza/features/dof/data/models/dof_item_model.dart';
import 'package:fiscaliza/features/fiscalizacao/data/models/medicao_grupo_model.dart';
import 'package:fiscaliza/features/relatorio/domain/montar_relatorio.dart';

void main() {
  DofItemModel item({
    required String id,
    required String especie,
    String popular = 'Cupiúba',
    required double saldoTotal,
  }) => DofItemModel(
    id: id,
    numero: id,
    produto: 'Madeira serrada',
    especieCientifico: especie,
    nomePopular: popular,
    saldoLivre: saldoTotal,
    saldoTotal: saldoTotal,
    unidade: 'm³',
  );

  MedicaoGrupoModel medicao({
    required String dofItemId,
    int fotoIndex = 0,
    double comprimentoM = 3.0,
    double larguraCm = 30.0,
    double alturaCm = 5.0,
    int quantidade = 1,
  }) => MedicaoGrupoModel(
    id: '$dofItemId-$fotoIndex-$comprimentoM-$larguraCm-$alturaCm',
    dofItemId: dofItemId,
    fotoIndex: fotoIndex,
    comprimentoM: comprimentoM,
    larguraCm: larguraCm,
    alturaCm: alturaCm,
    quantidade: quantidade,
    isPrincipal: false,
  );

  group('montarRelatorio — uma espécie', () {
    test('uma dimensão: diferença é o saldo do DOF menos o volume físico', () {
      final linhas = montarRelatorio(
        itens: [item(id: 'a', especie: 'Goupia glabra', saldoTotal: 10)],
        medicoesPorItemId: {
          'a': [medicao(dofItemId: 'a', quantidade: 10)],
        },
      );

      expect(linhas, hasLength(1));
      final linha = linhas.single;
      expect(linha.numeroOrdem, 1);
      expect(linha.quantidade, 10);
      expect(linha.totalFisicoM3, closeTo(0.45, 1e-9));
      expect(linha.totalDofM3, 10);
      expect(linha.diferencaM3, closeTo(9.55, 1e-9));
      expect(linha.isPrimeiraDaEspecie, isTrue);
    });

    test('dimensões diferentes geram linhas separadas em cascata', () {
      final linhas = montarRelatorio(
        itens: [item(id: 'a', especie: 'Goupia glabra', saldoTotal: 10)],
        medicoesPorItemId: {
          'a': [
            medicao(dofItemId: 'a', comprimentoM: 2.0, quantidade: 10),
            medicao(dofItemId: 'a', comprimentoM: 3.0, quantidade: 10),
            medicao(dofItemId: 'a', comprimentoM: 4.0, quantidade: 10),
          ],
        },
      );

      expect(linhas, hasLength(3));

      expect(linhas[0].totalFisicoM3, closeTo(0.30, 1e-9));
      expect(linhas[0].totalDofM3, 10);
      expect(linhas[0].diferencaM3, closeTo(9.70, 1e-9));

      expect(linhas[1].totalFisicoM3, closeTo(0.45, 1e-9));
      expect(linhas[1].totalDofM3, isNull);
      expect(linhas[1].diferencaM3, closeTo(9.25, 1e-9));

      expect(linhas[2].totalFisicoM3, closeTo(0.60, 1e-9));
      expect(linhas[2].totalDofM3, isNull);
      expect(linhas[2].diferencaM3, closeTo(8.65, 1e-9));

      expect(linhas[0].isPrimeiraDaEspecie, isTrue);
      expect(linhas[1].isPrimeiraDaEspecie, isFalse);
      expect(linhas[2].isPrimeiraDaEspecie, isFalse);
    });

    test('mesma dimensão em fotos diferentes soma numa linha só', () {
      final linhas = montarRelatorio(
        itens: [item(id: 'a', especie: 'Goupia glabra', saldoTotal: 10)],
        medicoesPorItemId: {
          'a': [
            medicao(dofItemId: 'a', fotoIndex: 0, quantidade: 4),
            medicao(dofItemId: 'a', fotoIndex: 1, quantidade: 6),
          ],
        },
      );

      expect(linhas, hasLength(1));
      expect(linhas.single.quantidade, 10);
      expect(linhas.single.totalFisicoM3, closeTo(0.45, 1e-9));
    });

    test('volume acima do declarado deixa a diferença negativa', () {
      final linhas = montarRelatorio(
        itens: [item(id: 'a', especie: 'Goupia glabra', saldoTotal: 0.20)],
        medicoesPorItemId: {
          'a': [medicao(dofItemId: 'a', quantidade: 10)],
        },
      );

      expect(linhas.single.diferencaM3, closeTo(-0.25, 1e-9));
      expect(linhas.single.excedente, isTrue);
    });

    test('espécie sem medição aparece com quantidade zero', () {
      final linhas = montarRelatorio(
        itens: [item(id: 'a', especie: 'Goupia glabra', saldoTotal: 7.5)],
        medicoesPorItemId: const {},
      );

      expect(linhas, hasLength(1));
      final linha = linhas.single;
      expect(linha.quantidade, 0);
      expect(linha.semMedicao, isTrue);
      expect(linha.totalFisicoM3, 0);
      expect(linha.totalDofM3, 7.5);
      expect(linha.diferencaM3, 7.5);
    });
  });

  group('montarRelatorio — várias espécies', () {
    test('espécie repetida no DOF soma os saldos num bloco só', () {
      final linhas = montarRelatorio(
        itens: [
          item(id: 'a', especie: 'Goupia glabra', saldoTotal: 32.13),
          item(id: 'b', especie: 'Goupia glabra', saldoTotal: 6.57),
        ],
        medicoesPorItemId: {
          'a': [medicao(dofItemId: 'a', quantidade: 10)],
          'b': [medicao(dofItemId: 'b', comprimentoM: 4.0, quantidade: 10)],
        },
      );

      expect(linhas, hasLength(2));
      expect(linhas[0].totalDofM3, closeTo(38.70, 1e-9));
      expect(linhas[1].totalDofM3, isNull);
      expect(linhas.every((l) => l.especieCientifico == 'Goupia glabra'), isTrue);
    });

    test('cada espécie reinicia o saldo e o Total DOF', () {
      final linhas = montarRelatorio(
        itens: [
          item(id: 'a', especie: 'Dipteryx odorata', saldoTotal: 5),
          item(id: 'b', especie: 'Goupia glabra', saldoTotal: 8),
        ],
        medicoesPorItemId: {
          'a': [medicao(dofItemId: 'a', quantidade: 10)],
          'b': [medicao(dofItemId: 'b', quantidade: 10)],
        },
      );

      expect(linhas, hasLength(2));
      expect(linhas[0].especieCientifico, 'Dipteryx odorata');
      expect(linhas[0].totalDofM3, 5);
      expect(linhas[0].diferencaM3, closeTo(4.55, 1e-9));

      expect(linhas[1].especieCientifico, 'Goupia glabra');
      expect(linhas[1].totalDofM3, 8);
      expect(linhas[1].diferencaM3, closeTo(7.55, 1e-9));
      expect(linhas[1].isPrimeiraDaEspecie, isTrue);
    });

    test('numero de ordem é sequencial e sem furos', () {
      final linhas = montarRelatorio(
        itens: [
          item(id: 'a', especie: 'Dipteryx odorata', saldoTotal: 5),
          item(id: 'b', especie: 'Goupia glabra', saldoTotal: 8),
        ],
        medicoesPorItemId: {
          'a': [
            medicao(dofItemId: 'a', comprimentoM: 2.0),
            medicao(dofItemId: 'a', comprimentoM: 3.0),
          ],
          'b': [medicao(dofItemId: 'b')],
        },
      );

      expect(linhas.map((l) => l.numeroOrdem), [1, 2, 3]);
    });
  });

  group('montarRelatorio — bordas', () {
    test('sem itens devolve relatório vazio', () {
      expect(
        montarRelatorio(itens: const [], medicoesPorItemId: const {}),
        isEmpty,
      );
    });

    test('medição de item que não está na lista é ignorada', () {
      final linhas = montarRelatorio(
        itens: [item(id: 'a', especie: 'Goupia glabra', saldoTotal: 10)],
        medicoesPorItemId: {
          'a': [medicao(dofItemId: 'a', quantidade: 10)],
          'orfao': [medicao(dofItemId: 'orfao', quantidade: 99)],
        },
      );

      expect(linhas, hasLength(1));
      expect(linhas.single.quantidade, 10);
    });
  });
}
