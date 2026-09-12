/// Bitola comercial de peça de madeira, usada como atalho na cubagem.
class PerfilPeca {
  final String nome;

  final double comprimentoCm;

  final double larguraCm;

  final double alturaCm;

  const PerfilPeca({
    required this.nome,
    required this.comprimentoCm,
    required this.larguraCm,
    required this.alturaCm,
  });

  String get rotulo => '$nome ${larguraCm.toInt()}×$alturaCm';
}

/// Bitolas mais comuns em pátio de madeireira.
const List<PerfilPeca> perfisComuns = [
  PerfilPeca(nome: 'Prancha', comprimentoCm: 300, larguraCm: 30, alturaCm: 5),
  PerfilPeca(nome: 'Viga', comprimentoCm: 300, larguraCm: 15, alturaCm: 5),
  PerfilPeca(nome: 'Caibro', comprimentoCm: 300, larguraCm: 5, alturaCm: 5),
  PerfilPeca(nome: 'Tábua', comprimentoCm: 300, larguraCm: 30, alturaCm: 2.5),
  PerfilPeca(nome: 'Ripa', comprimentoCm: 300, larguraCm: 5, alturaCm: 1.5),
];
