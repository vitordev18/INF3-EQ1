import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:fiscaliza/design_system/theme/app_colors.dart';
import 'package:fiscaliza/design_system/theme/app_spacing.dart';
import 'package:fiscaliza/design_system/components/app_scaffold.dart';

class ValidacaoScreen extends StatelessWidget {
  const ValidacaoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppScaffold(
      appBar: AppBar(
        title: const Text('Validação'),
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
              const Icon(Icons.fact_check_outlined,
                  size: 56, color: AppColors.grey),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Validação da fiscalização',
                style: theme.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Revisão item a item do declarado contra o medido, antes de '
                'fechar a fiscalização. Funcionalidade prevista para a próxima etapa.',
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
