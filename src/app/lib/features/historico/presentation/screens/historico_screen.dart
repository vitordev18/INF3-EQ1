import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/widgets/app_scaffold.dart';
import 'package:app/core/widgets/fiscaliza_bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Placeholder da tela de Histórico completo — por pedido explícito, o
/// conteúdo (lista completa/filtros de fiscalizações passadas) não é
/// implementado nesta fase. A rota existe e é navegável (a partir do Hub de
/// Início e do nav inferior) para que a navegação já fique correta quando o
/// conteúdo for construído depois.
///
/// O nav inferior fica em fluxo normal, logo abaixo do placeholder central
/// (revertido 2026-09-04, 4ª vez — `bottomBar`/`Scaffold.bottomNavigationBar`
/// voltou a causar tela em branco com nav flutuando centralizado em emulador
/// real, mesmo isolando a mudança e descartando edge-to-edge como causa; ver
/// [[fiscaliza-historico-plano]]).
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
          icon: const Icon(Icons.chevron_left, color: AppColors.black),
          onPressed: () => context.go('/home'),
          iconSize: 30,
        ),
      ),
      body: Column(
        children: [
          const Expanded(
            child: Center(
              child: Text(
                'Histórico em breve',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 50, top: 6),
            child: Center(child: FiscalizaBottomNav(active: FiscalizaNavTab.historico)),
          ),
        ],
      ),
    );
  }
}
