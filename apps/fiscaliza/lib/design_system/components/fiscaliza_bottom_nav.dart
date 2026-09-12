import 'package:fiscaliza/app/router/app_routes.dart';
import 'package:fiscaliza/design_system/theme/app_colors.dart';
import 'package:fiscaliza/design_system/components/app_icon.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

enum FiscalizaNavTab { inicio, historico }

class FiscalizaBottomNav extends StatelessWidget {
  final FiscalizaNavTab active;

  const FiscalizaBottomNav({super.key, required this.active});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.18), blurRadius: 18, offset: const Offset(0, 6)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _navItem(
            context,
            icon: AppIcon.home,
            label: 'Início',
            active: active == FiscalizaNavTab.inicio,
            onTap: () {
              if (active != FiscalizaNavTab.inicio) context.go(AppRoutes.home);
            },
          ),
          const SizedBox(width: 30),
          _navItem(
            context,
            icon: AppIcon.history,
            label: 'Histórico',
            active: active == FiscalizaNavTab.historico,
            onTap: () {
              if (active != FiscalizaNavTab.historico) context.go(AppRoutes.historico);
            },
          ),         
        ],
      ),
    );
  }

  Widget _navItem(
    BuildContext context, {
    required AppIcon icon,
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    final color = active ? AppColors.green : const Color(0xFF9E9E9E);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
        decoration: BoxDecoration(
          color: active ? AppColors.green.withValues(alpha: 0.12) : null,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppSvgIcon(icon, size: 30, color: color),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: active ? FontWeight.bold : FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
