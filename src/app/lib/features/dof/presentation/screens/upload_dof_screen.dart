import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/widgets/app_scaffold.dart';
import 'package:app/core/widgets/action_bottom_bar.dart';
import 'package:app/features/fiscalizacao/data/models/fiscalizacao_sessao_model.dart';
import 'package:app/features/dof/presentation/viewmodels/upload_dof_viewmodel.dart';

class UploadDofScreen extends ConsumerWidget {
  const UploadDofScreen({super.key});

  /// Fiscalização anterior ainda em andamento: pergunta se o usuário quer
  /// encerrá-la (com os itens não terminados registrados como pendentes no
  /// histórico) antes de abrir a nova a partir desta planilha.
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
          icon: const Icon(Icons.chevron_left, color: AppColors.black),
          onPressed: () => context.go('/home'),
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
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            state.parsedItems.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                      child: Text(
                        'Nenhum dado para exibir.\nFaça o upload da planilha.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Color(0xFF9E9E9E)),
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(
                        AppColors.lightGrey,
                      ),
                      columns: const [
                        DataColumn(label: Text('Número')),
                        DataColumn(label: Text('Produto')),
                        DataColumn(label: Text('Espécie')),
                        DataColumn(label: Text('Saldo Total')),
                        DataColumn(label: Text('Unid.')),
                      ],
                      rows: state.parsedItems.map((item) {
                        return DataRow(
                          cells: [
                            DataCell(Text(item.numero)),
                            DataCell(Text(item.produto)),
                            DataCell(Text(item.especieCientifico)),
                            DataCell(Text(item.saldoTotal.toString())),
                            DataCell(Text(item.unidade)),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
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
              context.go('/fiscalizacao');
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
                context.go('/fiscalizacao');
              }
            case ErroAoSalvar():
              break; // mensagem já exibida via state.statusMessage
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
