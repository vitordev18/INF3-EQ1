import 'package:fiscaliza/core/utils/formatting_converter.dart';
import 'package:fiscaliza/features/dof/data/models/dof_item_model.dart';
import 'package:fiscaliza/features/fiscalizacao/data/models/medicao_grupo_model.dart';
import 'package:fiscaliza/features/relatorio/domain/linha_relatorio.dart';

/// Monta as linhas do relatório de fiscalização.
///
/// Cada linha é uma espécie numa dimensão específica: a mesma espécie medida em
/// duas bitolas diferentes ocupa duas linhas. O Total DOF aparece só na primeira
/// linha da espécie e é a soma dos saldos declarados de todos os itens daquela
/// espécie no DOF.
///
/// A Diferença é um saldo restante, consumido linha a linha: na primeira é o
/// Total DOF menos o volume físico apurado, e nas seguintes é a Diferença
/// anterior menos o volume daquela linha. Negativa significa volume físico
/// acima do declarado — o indício de irregularidade que o laudo precisa apontar.
///
/// Espécie sem nenhuma medida gera uma linha com quantidade 0 e Diferença igual
/// ao Total DOF, para o fiscal enxergar o que ainda não foi medido.
///
/// **Para a exportação em PDF:** esta lista plana já é a tabela do laudo, na
/// ordem final de exibição e com uma linha por registro. Cada [LinhaRelatorio]
/// carrega exatamente as colunas previstas — `numeroOrdem`, `especieCientifico`,
/// `larguraCm`, `alturaCm`, `comprimentoM`, `quantidade`, `totalFisicoM3`,
/// `totalDofM3` e `diferencaM3`. `totalDofM3` é nulo fora da primeira linha da
/// espécie, e é assim que a célula deve sair no PDF: vazia. Use
/// `Relatorio.linhas` direto, sem reagrupar; `Relatorio.blocos` existe apenas
/// para a leitura em cards na tela e não deve ser usado no laudo.
List<LinhaRelatorio> montarRelatorio({
  required List<DofItemModel> itens,
  required Map<String, List<MedicaoGrupoModel>> medicoesPorItemId,
}) {
  final especies = _agruparPorEspecie(itens);
  final linhas = <LinhaRelatorio>[];
  var numeroOrdem = 1;

  for (final especie in especies) {
    final medicoes = especie.itens
        .expand((item) => medicoesPorItemId[item.id] ?? const <MedicaoGrupoModel>[])
        .toList();

    final dimensoes = _agruparPorDimensao(medicoes);

    if (dimensoes.isEmpty) {
      linhas.add(
        LinhaRelatorio(
          numeroOrdem: numeroOrdem++,
          especieCientifico: especie.especieCientifico,
          nomePopular: especie.nomePopular,
          larguraCm: 0,
          alturaCm: 0,
          comprimentoM: 0,
          quantidade: 0,
          totalFisicoM3: 0,
          totalDofM3: especie.totalDofM3,
          diferencaM3: especie.totalDofM3,
          isPrimeiraDaEspecie: true,
        ),
      );
      continue;
    }

    var saldo = especie.totalDofM3;

    for (var i = 0; i < dimensoes.length; i++) {
      final dimensao = dimensoes[i];
      final isPrimeira = i == 0;

      final totalFisico = FormattingConverter.calcularVolume(
        larguraCm: dimensao.larguraCm,
        alturaCm: dimensao.alturaCm,
        comprimentoM: dimensao.comprimentoM,
        quantidade: dimensao.quantidade,
      );

      saldo = saldo - totalFisico;

      linhas.add(
        LinhaRelatorio(
          numeroOrdem: numeroOrdem++,
          especieCientifico: especie.especieCientifico,
          nomePopular: especie.nomePopular,
          larguraCm: dimensao.larguraCm,
          alturaCm: dimensao.alturaCm,
          comprimentoM: dimensao.comprimentoM,
          quantidade: dimensao.quantidade,
          totalFisicoM3: totalFisico,
          totalDofM3: isPrimeira ? especie.totalDofM3 : null,
          diferencaM3: saldo,
          isPrimeiraDaEspecie: isPrimeira,
        ),
      );
    }
  }

  return linhas;
}

class _Especie {
  final String especieCientifico;
  final String nomePopular;
  final double totalDofM3;
  final List<DofItemModel> itens;

  const _Especie({
    required this.especieCientifico,
    required this.nomePopular,
    required this.totalDofM3,
    required this.itens,
  });
}

List<_Especie> _agruparPorEspecie(List<DofItemModel> itens) {
  final porEspecie = <String, List<DofItemModel>>{};

  for (final item in itens) {
    porEspecie.putIfAbsent(item.especieCientifico, () => []).add(item);
  }

  final especies = porEspecie.entries.map((entrada) {
    final doGrupo = entrada.value;
    return _Especie(
      especieCientifico: entrada.key,
      nomePopular: doGrupo.first.nomePopular,
      totalDofM3: doGrupo.fold(0.0, (soma, item) => soma + item.saldoTotal),
      itens: doGrupo,
    );
  }).toList();

  especies.sort((a, b) => a.especieCientifico.compareTo(b.especieCientifico));
  return especies;
}

class _Dimensao {
  final double comprimentoM;
  final double larguraCm;
  final double alturaCm;
  final int quantidade;

  const _Dimensao({
    required this.comprimentoM,
    required this.larguraCm,
    required this.alturaCm,
    required this.quantidade,
  });
}

List<_Dimensao> _agruparPorDimensao(List<MedicaoGrupoModel> medicoes) {
  final porChave = <String, _Dimensao>{};

  for (final medicao in medicoes) {
    final chave = '${medicao.comprimentoM}|${medicao.larguraCm}|${medicao.alturaCm}';
    final existente = porChave[chave];

    porChave[chave] = _Dimensao(
      comprimentoM: medicao.comprimentoM,
      larguraCm: medicao.larguraCm,
      alturaCm: medicao.alturaCm,
      quantidade: (existente?.quantidade ?? 0) + medicao.quantidade,
    );
  }

  final dimensoes = porChave.values.toList();
  dimensoes.sort((a, b) {
    final porComprimento = a.comprimentoM.compareTo(b.comprimentoM);
    if (porComprimento != 0) return porComprimento;
    final porLargura = a.larguraCm.compareTo(b.larguraCm);
    if (porLargura != 0) return porLargura;
    return a.alturaCm.compareTo(b.alturaCm);
  });

  return dimensoes;
}
