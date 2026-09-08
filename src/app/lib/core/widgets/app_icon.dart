import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Ícones em traço (estilo Lucide/Feather) extraídos 1:1 do mockup
/// `fiscaliza-plano-historico`, como assets SVG locais em `assets/icons/`.
///
/// Use [AppSvgIcon] em vez de `Icon(Icons.*)` em qualquer tela que precise
/// bater visualmente com o mockup — os `Icons.*` do Material são preenchidos
/// e não reproduzem o traço fino do design de referência.
enum AppIcon {
  back('assets/icons/back.svg'),
  chevronRight('assets/icons/chevron_right.svg'),
  history('assets/icons/history.svg'),
  upload('assets/icons/upload.svg'),
  box('assets/icons/box.svg'),
  home('assets/icons/home.svg'),
  checkCircle('assets/icons/check_circle.svg'),
  plus('assets/icons/plus.svg'),
  info('assets/icons/info.svg');

  final String assetPath;
  const AppIcon(this.assetPath);
}

/// Renderiza um [AppIcon] com tamanho e cor consistentes.
///
/// O SVG de origem é traçado em preto (#000000); a cor real é aplicada em
/// runtime via [ColorFilter] (BlendMode.srcIn), então qualquer [color] pode
/// ser usada sem precisar de uma variante de arquivo por cor.
class AppSvgIcon extends StatelessWidget {
  final AppIcon icon;
  final double size;
  final Color color;

  const AppSvgIcon(
    this.icon, {
    super.key,
    this.size = 18,
    this.color = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      icon.assetPath,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}
