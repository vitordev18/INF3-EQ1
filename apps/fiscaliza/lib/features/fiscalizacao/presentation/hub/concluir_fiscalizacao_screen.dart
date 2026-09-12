import 'package:fiscaliza/app/router/app_routes.dart';
import 'package:fiscaliza/design_system/theme/app_colors.dart';
import 'package:app/core/widgets/action_bottom_bar.dart';
import 'package:fiscaliza/design_system/components/app_icon.dart';
import 'package:fiscaliza/design_system/components/app_scaffold.dart';
import 'package:fiscaliza/features/dof/data/models/dof_item_model.dart';
import 'package:fiscaliza/features/fiscalizacao/domain/entities/status_fiscalizacao.dart';
import 'package:fiscaliza/features/fiscalizacao/data/fiscalizacao_providers.dart';
import 'package:fiscaliza/design_system/components/status_pill.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ConcluirFiscalizacaoScreen extends ConsumerWidget {
  const ConcluirFiscalizacaoScreen({super.key});

  static const _warningBg = Color(0xFFFFF3E0);
  static const _warningColor = Color(0xFFF57C00);
  static const _excedenteColor = Color(0xFFD32F2F);
  static const _pendenteColor = Color(0xFF757575);
  static const _itensColor = Color(0xFF212121);
  static const _statLabelColor = Color(0x73000000);

  Future<void> _concluir(
    BuildContext context,
    WidgetRef ref,
    String sessaoId,
  ) async {
    final ds = ref.read(fiscalizacaoSessaoRepositoryProvider);
    await ds.encerrarSessao(sessaoId);
    ref.invalidate(sessaoAtivaProvider);
    ref.invalidate(sessoesRecentesProvider);
    if (context.mounted) context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessao = ref.watch(sessaoAtivaProvider).value;
    final itens = ref.watch(itensDaSessaoAtivaProvider);
    final resumo =
        ref.watch(resumoSessaoAtivaProvider).value ?? (0, 0, 0, 0);
    final pendentes = resumo.$4;

    return AppScaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Concluir Fiscalização',
          style: TextStyle(
           color: AppColors.black,
           fontWeight: FontWeight.bold,
          fontSize: 19,
         ),
        ),
        leading: IconButton(
          tooltip: 'Voltar',
          icon: const Icon(Icons.chevron_left, color: AppColors.black),
          onPressed: () => context.go(AppRoutes.hub),
          iconSize: 30,
        ),
      ),
      body: sessao == null
          ? const Center(
              child: Text(
                'Nenhuma fiscalização em andamento.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildStatsCard(resumo),
                  const SizedBox(height: 10),
                  if (pendentes > 0) ...[
                    _buildWarningBanner(pendentes),
                    const SizedBox(height: 10),
                  ],
                  _buildLista(ref, itens),
                ],
              ),
            ),
      bottomBar: sessao == null
          ? null
          : _buildBottomBar(context, ref, sessao.id),
    );
  }

  Widget _buildStatsCard((int, int, int, int) resumo) {
    final (total, concluidos, excedentes, pendentes) = resumo;
    return Container(
      padding: const EdgeInsets.all(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 9),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.lightGrey),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildStatColumn('Itens', '$total', _itensColor),
              _buildStatDivider(),
              _buildStatColumn('Concluídos', '$concluidos', AppColors.green),
              _buildStatDivider(),
              _buildStatColumn('Excedentes', '$excedentes', _excedenteColor),
              _buildStatDivider(),
              _buildStatColumn('Pendentes', '$pendentes', _pendenteColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, Color valueColor) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 8, color: _statLabelColor),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Container(width: 1, color: const Color(0xFFEEEEEE)),
    );
  }

  Widget _buildWarningBanner(int pendentes) {
    final intro = pendentes == 1
        ? '1 produto ainda não foi fiscalizado. Ao concluir, ficará '
              'registrado como '
        : '$pendentes produtos ainda não foram fiscalizados. Ao concluir, '
              'ficarão registrados como ';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
        decoration: BoxDecoration(
          color: _warningBg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 1),
              child: AppSvgIcon(AppIcon.info, size: 15, color: _warningColor),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF5F5F5F),
                    height: 1.4,
                  ),
                  children: [
                    TextSpan(text: intro),
                    const TextSpan(
                      text: 'pendentes',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const TextSpan(text: ' no histórico.'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLista(WidgetRef ref, List<DofItemModel> itens) {
    return Container(
      color: AppColors.white,
      child: Column(
        children: [
          for (int i = 0; i < itens.length; i++) ...[
            _buildItemRow(ref, itens[i]),
            if (i != itens.length - 1)
              const Divider(
                height: 1,
                thickness: 1,
                color: AppColors.lightGrey,
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildItemRow(WidgetRef ref, DofItemModel item) {
    final registroAsync = ref.watch(registroPorItemProvider(item.id));
    final status =
        registroAsync.whenOrNull(data: (r) => r?.status) ??
        StatusFiscalizacao.pendente;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              item.produto,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
            ),
          ),
          const SizedBox(width: 8),
          StatusPill(status),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, WidgetRef ref, String sessaoId) {
    return ActionBottomBar(
      onPressed: () => _concluir(context, ref, sessaoId),
      child: const Text(
        'Concluir Fiscalização',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
