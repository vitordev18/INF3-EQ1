class FormattingConverter {
  FormattingConverter._();
  static double cmParaMetros(double cm) => cm / 100;

  static double calcularVolume({
    required double larguraCm,
    required double alturaCm,
    required double comprimentoM,
    required int quantidade,
  }) {
    final largura = cmParaMetros(larguraCm);
    final altura = cmParaMetros(alturaCm);
    final volumeUnitario = largura * altura * comprimentoM;
    return volumeUnitario * quantidade;
  }

  static double calcularVolumeMisto({
    required double largura1Cm,
    required double altura1Cm,
    required double comprimento1M,
    required int quantidade1,
    required double largura2Cm,
    required double altura2Cm,
    required double comprimento2M,
    required int quantidade2,
  }) {
    return calcularVolume(
          larguraCm: largura1Cm,
          alturaCm: altura1Cm,
          comprimentoM: comprimento1M,
          quantidade: quantidade1,
        ) +
        calcularVolume(
          larguraCm: largura2Cm,
          alturaCm: altura2Cm,
          comprimentoM: comprimento2M,
          quantidade: quantidade2,
        );
  }

  static String formatarVolume(double volume) {
    return '${volume.toStringAsFixed(4)} m³';
  }
}
