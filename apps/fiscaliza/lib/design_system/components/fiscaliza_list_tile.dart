import 'package:flutter/material.dart';
import 'package:fiscaliza/design_system/theme/app_colors.dart';

import 'app_icon.dart';

class FiscalizaListTile extends StatelessWidget {
  final String title;
  final double titleFontSize;
  final Color titleColor;

  final Widget? pill;

  final List<Widget> metaRows;

  final Widget? highlightRow;

  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

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

class FiscalizaMetaChip extends StatelessWidget {
  final AppIcon icon;
  final String text;
  final Color color;
  final Color? iconColor;
  final double iconSize;
  final double fontSize;
  final FontWeight fontWeight;

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
