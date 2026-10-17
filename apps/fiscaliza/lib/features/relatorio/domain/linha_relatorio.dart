class LinhaRelatorio {
  final int numeroOrdem;
  final String especieCientifico;
  final String nomePopular;
  final double larguraCm;
  final double alturaCm;
  final double comprimentoM;
  final int quantidade;
  final double totalFisicoM3;
  final double? totalDofM3;
  final double diferencaM3;
  final bool isPrimeiraDaEspecie;

  const LinhaRelatorio({
    required this.numeroOrdem,
    required this.especieCientifico,
    required this.nomePopular,
    required this.larguraCm,
    required this.alturaCm,
    required this.comprimentoM,
    required this.quantidade,
    required this.totalFisicoM3,
    required this.totalDofM3,
    required this.diferencaM3,
    required this.isPrimeiraDaEspecie,
  });

  bool get semMedicao => quantidade == 0;

  bool get excedente => diferencaM3 < 0;
}

class CabecalhoRelatorio {
  final String madeireiraNome;
  final String cnpj;
  final String endereco;
  final DateTime dataFiscalizacao;

  const CabecalhoRelatorio({
    required this.madeireiraNome,
    required this.cnpj,
    required this.endereco,
    required this.dataFiscalizacao,
  });
}

class BlocoEspecie {
  final String especieCientifico;
  final String nomePopular;
  final double totalDofM3;
  final List<LinhaRelatorio> linhas;

  const BlocoEspecie({
    required this.especieCientifico,
    required this.nomePopular,
    required this.totalDofM3,
    required this.linhas,
  });

  double get totalFisicoM3 =>
      linhas.fold(0.0, (soma, l) => soma + l.totalFisicoM3);

  int get totalPecas => linhas.fold(0, (soma, l) => soma + l.quantidade);

  /// Sobra do saldo declarado depois de descontadas todas as medidas.
  double get saldoM3 => linhas.last.diferencaM3;

  bool get excedente => saldoM3 < 0;

  bool get semMedicao => linhas.every((l) => l.semMedicao);
}

class Relatorio {
  final CabecalhoRelatorio cabecalho;
  final List<LinhaRelatorio> linhas;

  const Relatorio({required this.cabecalho, required this.linhas});

  bool get vazio => linhas.isEmpty;

  List<BlocoEspecie> get blocos {
    final resultado = <BlocoEspecie>[];
    var atual = <LinhaRelatorio>[];

    void fechar() {
      if (atual.isEmpty) return;
      resultado.add(
        BlocoEspecie(
          especieCientifico: atual.first.especieCientifico,
          nomePopular: atual.first.nomePopular,
          totalDofM3: atual.first.totalDofM3 ?? 0,
          linhas: List.unmodifiable(atual),
        ),
      );
      atual = <LinhaRelatorio>[];
    }

    for (final linha in linhas) {
      if (linha.isPrimeiraDaEspecie) fechar();
      atual.add(linha);
    }
    fechar();

    return resultado;
  }

  double get totalFisicoGeralM3 =>
      linhas.fold(0.0, (soma, l) => soma + l.totalFisicoM3);

  double get totalDofGeralM3 =>
      linhas.fold(0.0, (soma, l) => soma + (l.totalDofM3 ?? 0));
}
