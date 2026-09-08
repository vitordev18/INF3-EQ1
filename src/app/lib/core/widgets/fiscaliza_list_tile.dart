import 'package:flutter/material.dart';
import 'package:app/core/theme/app_colors.dart';

import 'app_icon.dart';

/// Item de lista full-bleed reutilizado tanto no Hub de Início ("Últimas
/// Fiscalizações") quanto na FiscalizacaoHubScreen (lista de produtos) —
/// as duas listas do mockup `fiscaliza-plano-historico` que compartilham a
/// mesma anatomia visual: título + pill de status, 0-2 linhas de
/// meta-informação, uma linha de destaque opcional, chevron à direita e um
/// divisor fino entre itens.
///
/// Este widget é deliberadamente "burro" sobre o que aparece dentro de cada
/// linha — título, pill, meta-linhas e linha de destaque são todos widgets
/// passados pelo chamador, porque o conteúdo real difere bastante entre as
/// duas telas (datas + contagem de produtos vs. espécie + saldo + volume) e
/// depende do status de cada item. O que ele padroniza (e evita duplicar
/// tela a tela) é exatamente o que é idêntico nas duas: espaçamento,
/// alinhamento do chevron, área de toque e divisor. Use [FiscalizaMetaChip]
/// para montar as meta-linhas / linha de destaque mais comuns (ícone +
/// texto).
class FiscalizaListTile extends StatelessWidget {
  /// Título principal (nome da madeireira ou nome do produto).
  final String title;
  final double titleFontSize;
  final Color titleColor;

  /// Pill de status (ex.: `StatusPill` construído pela tela chamadora, que
  /// conhece o enum `StatusFiscalizacao` e suas cores/textos).
  final Widget? pill;

  /// Linhas exibidas entre o título e a linha de destaque, uma abaixo da
  /// outra (ex.: "Espécie: ...", ou uma `Wrap`/`Row` com dois
  /// [FiscalizaMetaChip] lado a lado como data + contagem de produtos).
  final List<Widget> metaRows;

  /// Última linha, opcionalmente destacada (ex.: "Volume Total: ..." ou
  /// "84,2 m³ fiscalizados").
  final Widget? highlightRow;

  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  /// `false` no último item de uma lista (o mockup só desenha o divisor
  /// *entre* itens, nunca depois do último).
  final bool showDivider;

  const FiscalizaListTile({
    super.key,
    required this.title,
    this.titleFontSize = 12.5,
    this.titleColor = const Color(0xFF000000),
    this.pill,
    this.metaRows = const [],
    this.highlightRow,
    this.onTap,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: padding,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: titleFontSize,
                                color: titleColor,
                              ),
                            ),
                          ),
                          if (pill != null) ...[
                            const SizedBox(width: 8),
                            pill!,
                          ],
                        ],
                      ),
                      for (final row in metaRows) ...[
                        const SizedBox(height: 4),
                        row,
                      ],
                      if (highlightRow != null) ...[
                        const SizedBox(height: 4),
                        highlightRow!,
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const AppSvgIcon(
                  AppIcon.chevronRight,
                  size: 12,
                  color: Color(0xFFBDBDBD),
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          const Divider(height: 1, thickness: 1, color: AppColors.lightGrey),
      ],
    );
  }
}

/// Chip "ícone + texto" para montar [FiscalizaListTile.metaRows] /
/// [FiscalizaListTile.highlightRow] (ex.: data, contagem de produtos, saldo
/// declarado, volume total). Ícone e texto podem ter cores diferentes (o
/// mockup usa isso na linha de "Saldo Declarado": ícone cinza, texto preto).
class FiscalizaMetaChip extends StatelessWidget {
  final AppIcon icon;
  final String text;
  final Color color;
  final Color? iconColor;
  final double iconSize;
  final double fontSize;
  final FontWeight fontWeight;

  /// Espaço entre ícone e texto. O Hub de Início usa o padrão (4px, igual
  /// ao mockup); a FiscalizacaoHubScreen usa 5px para as linhas "Saldo
  /// Declarado" / "Volume Total" — os dois valores vêm de gaps diferentes
  /// no CSS original, não é um descuido.
  final double gap;

  const FiscalizaMetaChip({
    super.key,
    required this.icon,
    required this.text,
    this.color = const Color(0xFF757575),
    this.iconColor,
    this.iconSize = 11,
    this.fontSize = 9.5,
    this.fontWeight = FontWeight.normal,
    this.gap = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppSvgIcon(icon, size: iconSize, color: iconColor ?? color),
        SizedBox(width: gap),
        Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: color,
          ),
        ),
      ],
    );
  }
}
