import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/widgets/app_icon.dart';
import 'package:app/core/widgets/app_scaffold.dart';
import 'package:app/core/widgets/action_bottom_bar.dart';
import 'package:app/core/widgets/fiscaliza_list_tile.dart';
import 'package:app/features/dof/data/models/dof_item_model.dart';
import 'package:app/features/fiscalizacao/domain/entities/status_fiscalizacao.dart';
import 'package:app/features/fiscalizacao/presentation/providers/fiscalizacao_providers.dart';
import 'package:app/features/fiscalizacao/presentation/widgets/status_pill.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Hub de Fiscalização: lista os produtos (`DofItemModel`) da sessão ativa
/// (ver [itensDaSessaoAtivaProvider]) para o fiscal escolher qual fotografar
/// a seguir, com atalhos para adicionar um produto extra e para concluir a
/// fiscalização inteira. Réplica fiel de `FiscalizacaoHubScreen` em
/// `fiscaliza-plano-historico/index.html`.
class FiscalizacaoHubScreen extends ConsumerWidget {
  const FiscalizacaoHubScreen({super.key});

  static const _subtitleColor = Color(0xFF616161);
  static const _saldoIconColor = Color(0xFF757575);
  static const _saldoTextColor = Color(0xFF000000);

  String _formatNum3(double v) => v.toStringAsFixed(3).replaceAll('.', ',');

  void _iniciarFiscalizacao(BuildContext context, DofItemModel dofItem) {
    context.push('/fiscalizacao/captura', extra: dofItem);
  }

  void _adicionarProdutoExtra(BuildContext context) {
    context.push('/fiscalizacao/cadastro');
  }

  void _concluirFiscalizacao(BuildContext context) {
    context.push('/fiscalizacao/concluir');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itens = ref.watch(itensDaSessaoAtivaProvider);

    return AppScaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Hub de Fiscalização',
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
      body: itens.isEmpty
          ? const Center(
              child: Text(
                'Nenhum produto lido da planilha.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            )
          : Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 90),
                  child: Column(
                    children: [
                      for (int i = 0; i < itens.length; i++)
                        _buildItemTile(
                          context,
                          ref,
                          itens[i],
                          showDivider: i != itens.length - 1,
                        ),
                    ],
                  ),
                ),
                Positioned(
                  right: 14,
                  bottom: 66,
                  child: _buildProdutoExtraPill(context),
                ),
              ],
            ),
      bottomBar: ActionBottomBar(
        onPressed: () => _concluirFiscalizacao(context),
        child: const Text(
          'Concluir Fiscalização',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildItemTile(
    BuildContext context,
    WidgetRef ref,
    DofItemModel item, {
    required bool showDivider,
  }) {
    final registroAsync = ref.watch(registroPorItemProvider(item.id));
    final status =
        registroAsync.whenOrNull(data: (r) => r?.status) ??
        StatusFiscalizacao.pendente;
    final volumeTotalM3 = registroAsync.value?.volumeTotalM3 ?? 0.0;
    final corStatus = StatusPill.colorFor(status);
    final temVolume = volumeTotalM3 != 0.0;

    return FiscalizaListTile(
      title: item.produto,
      onTap: () => _iniciarFiscalizacao(context, item),
      pill: StatusPill(status),
      metaRows: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Espécie: ${item.especieCientifico} (${item.nomePopular})',
              style: const TextStyle(fontSize: 10, color: _subtitleColor),
            ),
            const SizedBox(height: 6),
            FiscalizaMetaChip(
              icon: AppIcon.box,
              text:
                  'Saldo Declarado: ${_formatNum3(item.saldoTotal)} '
                  '${item.unidade}',
              color: _saldoTextColor,
              iconColor: _saldoIconColor,
              iconSize: 12,
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              gap: 5,
            ),
          ],
        ),
      ],
      highlightRow: temVolume
          ? FiscalizaMetaChip(
              icon: AppIcon.checkCircle,
              text: 'Volume Total: ${_formatNum3(volumeTotalM3)} m³',
              color: corStatus,
              iconSize: 12,
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              gap: 5,
            )
          : null,
      showDivider: showDivider,
    );
  }

  Widget _buildProdutoExtraPill(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => _adicionarProdutoExtra(context),
      backgroundColor: AppColors.green,
      icon: const Icon(Icons.add, color: AppColors.white, size: 20),
      label: const Text(
        'Produto Extra',
        style: TextStyle(
          color: AppColors.white,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}
