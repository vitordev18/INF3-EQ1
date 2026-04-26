class DofItem {
  final String id;
  final String numero;
  final String produto;
  final String especieCientifico;
  final String nomePopular;
  final double saldoLivre;
  final double saldoTotal;
  final String unidade;
  final DateTime? criadoEm;

  DofItem({
    required this.id,
    required this.numero,
    required this.produto,
    required this.especieCientifico,
    required this.nomePopular,
    required this.saldoLivre,
    required this.saldoTotal,
    required this.unidade,
    this.criadoEm,
  });

  @override
  String toString() => 'DofItem(numero: $numero, nomePopular: $nomePopular)';
}
