import 'package:fiscaliza/app/router/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:fiscaliza/design_system/theme/app_colors.dart';
import 'package:fiscaliza/design_system/components/app_scaffold.dart';
import 'package:fiscaliza/design_system/components/action_bottom_bar.dart';
import 'package:fiscaliza/design_system/components/app_icon.dart';
import 'package:fiscaliza/design_system/components/fiscaliza_list_tile.dart';
import 'package:fiscaliza/features/dof/data/models/dof_item_model.dart';
import 'package:fiscaliza/features/fiscalizacao/data/models/fiscalizacao_sessao_model.dart';
import 'package:fiscaliza/features/dof/presentation/upload/upload_dof_view_model.dart';

class _ItensLidos extends StatelessWidget {
  final List<DofItemModel> itens;

  const _ItensLidos({required this.itens});

  static const _subtitleColor = Color(0xFF6B6B6B);
  static const _saldoTextColor = Color(0xFF1A1A1A);

  String _numero(double valor) {
    var texto = valor.toStringAsFixed(3);
    if (!texto.contains('.')) return texto;
    texto = texto.replaceFirst(RegExp(r'0+$'), '');
    return texto.endsWith('.')
        ? texto.substring(0, texto.length - 1)
        : texto;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
          child: Text(
            '${itens.length} ${itens.length == 1 ? 'item lido' : 'itens lidos'}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _subtitleColor,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.lightGrey),
          ),
          child: Column(
            children: [
              for (int i = 0; i < itens.length; i++)
                FiscalizaListTile(
                  title: itens[i].produto,
                  pill: _NumeroPill(itens[i].numero),
                  showDivider: i < itens.length - 1,
                  metaRows: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Espécie: ${itens[i].especieCientifico}'
                          '${itens[i].nomePopular.trim().isEmpty ? '' : ' (${itens[i].nomePopular})'}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: _subtitleColor,
                          ),
                        ),
                        const SizedBox(height: 6),
                        FiscalizaMetaChip(
                          icon: AppIcon.box,
                          text:
                              'Saldo Declarado: ${_numero(itens[i].saldoTotal)} '
                              '${itens[i].unidade}',
                          color: _saldoTextColor,
                          iconColor: AppColors.green,
                          iconSize: 12,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          gap: 5,
                        ),
                      ],
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NumeroPill extends StatelessWidget {
  final String numero;

  const _NumeroPill(this.numero);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'N° $numero',
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppColors.grey,
        ),
      ),
    );
  }
}

class UploadDofScreen extends ConsumerWidget {
  const UploadDofScreen({super.key});

  Future<bool> _confirmarEncerramentoAnterior(
    BuildContext context,
    FiscalizacaoSessaoModel sessaoAtiva,
  ) async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Fiscalização em andamento'),
        content: Text(
          'A fiscalização de "${sessaoAtiva.madeireiraNome}" ainda não foi '
          'concluída. Ao importar esta nova planilha, ela será encerrada e '
          'os itens não fiscalizados ficarão registrados como pendentes no '
          'histórico.\n\nDeseja continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.green,
              foregroundColor: AppColors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Encerrar e continuar'),
          ),
        ],
      ),
    );
    return confirmou ?? false;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(uploadDofViewModelProvider);
    final vm = ref.read(uploadDofViewModelProvider.notifier);

    return AppScaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Upload do DOF',
          style: TextStyle(
            color: Colors.black,
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppColors.lightGrey),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const Icon(
                      Icons.upload_file_rounded,
                      size: 60,
                      color: AppColors.green,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Importar Planilha DOF',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (state.statusMessage != null)
                      Text(
                        state.statusMessage!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: state.isError ? Colors.red : Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          backgroundColor: AppColors.green,
                          foregroundColor: AppColors.white,
                        ),
                        onPressed: state.isImporting || state.isSaving
                            ? null
                            : vm.pickAndParseFile,
                        child: state.isImporting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: AppColors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Selecionar Planilha'),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      onChanged: vm.setMadeireiraNome,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        labelText: 'Nome da Madeireira *',
                        hintText: 'Ex: Madeireira Rio Verde Ltda',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.green,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      onChanged: vm.setMadeireiraCnpj,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'CNPJ',
                        hintText: 'Ex: 12.345.678/0001-90',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.green,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      onChanged: vm.setMadeireiraEndereco,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        labelText: 'Endereço',
                        hintText: 'Ex: Rod. BR-163, km 42 — Sinop/MT',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.green,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (state.parsedItems.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: Text(
                    'Nenhum dado para exibir.\nFaça o upload da planilha.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF9E9E9E)),
                  ),
                ),
              )
            else
              _ItensLidos(itens: state.parsedItems),
          ],
        ),
      ),
      bottomBar: ActionBottomBar(
        isDisabled: !state.canConfirm,
        isLoading: state.isSaving,
        onPressed: () async {
          final resultado = await vm.confirmarESalvar();
          if (!context.mounted) return;

          switch (resultado) {
            case SalvouComSucesso():
              context.go(AppRoutes.hub);
            case PrecisaConfirmarEncerramento(:final sessaoAtiva):
              final confirmou = await _confirmarEncerramentoAnterior(
                context,
                sessaoAtiva,
              );
              if (!confirmou) return;
              final segundoResultado = await vm.confirmarESalvar(
                encerrarAnterior: true,
              );
              if (context.mounted && segundoResultado is SalvouComSucesso) {
                context.go(AppRoutes.hub);
              }
            case ErroAoSalvar():
              break;
          }
        },
        child: const Text(
          'Confirmar e Prosseguir',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
