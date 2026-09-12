import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:fiscaliza/design_system/theme/app_colors.dart';
import 'package:fiscaliza/design_system/theme/app_spacing.dart';
import 'package:fiscaliza/design_system/components/app_scaffold.dart';

class CadastroScreen extends StatelessWidget {
  const CadastroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppScaffold(
      appBar: AppBar(
        title: const Text('Produto Extra'),
        leading: IconButton(
          tooltip: 'Voltar',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.inventory_2_outlined,
                  size: 56, color: AppColors.grey),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Cadastro de produto extra',
                style: theme.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Aqui o fiscal registra um item encontrado no pátio que não '
                'consta no DOF. Funcionalidade prevista para a próxima etapa.',
                style: theme.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
