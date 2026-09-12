import 'package:fiscaliza/app/router/app_routes.dart';
import 'package:fiscaliza/design_system/theme/app_colors.dart';
import 'package:fiscaliza/design_system/components/app_scaffold.dart';
import 'package:fiscaliza/design_system/components/fiscaliza_bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HistoricoScreen extends StatelessWidget {
  const HistoricoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Histórico',
          style: TextStyle(
            color: AppColors.black,
            fontWeight: FontWeight.bold,
            fontSize: 19,
          ),
        ),
        leading: IconButton(
          tooltip: 'Voltar',
          icon: const Icon(Icons.chevron_left, color: AppColors.black),
          onPressed: () => context.go(AppRoutes.home),
          iconSize: 30,
        ),
      ),
      body: const Column(
        children: [
          Expanded(
            child: Center(
              child: Text(
                'Histórico em breve',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 50, top: 6),
            child: Center(child: FiscalizaBottomNav(active: FiscalizaNavTab.historico)),
          ),
        ],
      ),
    );
  }
}
