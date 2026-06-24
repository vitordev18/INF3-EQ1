import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

enum ConfirmDialogVariant { warning, danger, info }

Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Confirmar',
  String cancelLabel = 'Cancelar',
  ConfirmDialogVariant variant = ConfirmDialogVariant.warning,
  IconData? icon,
}) async {
  final colors = _variantColors(variant);
  final resolvedIcon = icon ?? _variantIcon(variant);

  final result = await showDialog<bool>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.4),
    builder: (ctx) => Dialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colors.iconBackground,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(resolvedIcon, color: colors.iconForeground, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.black,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: AppColors.grey,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.grey,
                      side: const BorderSide(color: AppColors.lightGrey, width: 1.5),
                      minimumSize: const Size(0, 48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      textStyle: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    child: Text(cancelLabel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.buttonBackground,
                      foregroundColor: AppColors.white,
                      minimumSize: const Size(0, 48),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      textStyle: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    child: Text(confirmLabel),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
  return result == true;
}

// ---------------------------------------------------------------------------
// Internals
// ---------------------------------------------------------------------------

class _VariantColors {
  final Color iconBackground;
  final Color iconForeground;
  final Color buttonBackground;

  const _VariantColors({
    required this.iconBackground,
    required this.iconForeground,
    required this.buttonBackground,
  });
}

_VariantColors _variantColors(ConfirmDialogVariant variant) {
  switch (variant) {
    case ConfirmDialogVariant.danger:
      return _VariantColors(
        iconBackground: const Color(0xFFFFEBEB),
        iconForeground: const Color(0xFFE24B4A),
        buttonBackground: const Color(0xFFE24B4A),
      );
    case ConfirmDialogVariant.warning:
      return _VariantColors(
        iconBackground: const Color(0xFFFFF3E0),
        iconForeground: const Color(0xFFF57C00),
        buttonBackground: const Color(0xFFF57C00),
      );
    case ConfirmDialogVariant.info:
      return _VariantColors(
        iconBackground: const Color(0xFFE8F5E9),
        iconForeground: AppColors.green,
        buttonBackground: AppColors.green,
      );
  }
}

IconData _variantIcon(ConfirmDialogVariant variant) {
  switch (variant) {
    case ConfirmDialogVariant.danger:
      return Icons.warning_amber_rounded;
    case ConfirmDialogVariant.warning:
      return Icons.info_outline_rounded;
    case ConfirmDialogVariant.info:
      return Icons.check_circle_outline_rounded;
  }
}
