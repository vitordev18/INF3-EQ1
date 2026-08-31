import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/widgets/app_scaffold.dart';
import 'package:app/features/dof/presentation/viewmodels/upload_dof_viewmodel.dart';

class UploadDofScreen extends ConsumerWidget {
  const UploadDofScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(uploadDofViewModelProvider);
    final vm = ref.read(uploadDofViewModelProvider.notifier);

    return AppScaffold(
      appBar: AppBar(
        title: const Text(
          'Upload do DOF',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800),
        ),
        backgroundColor: AppColors.green,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () => context.go('/'),
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
                      style: Theme.of(context).textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
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
                            borderRadius: BorderRadius.all(
                              Radius.circular(12),
                            ),
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
      bottomBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          border: const Border(
            top: BorderSide(color: AppColors.lightGrey),
          ),
        ),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              backgroundColor: AppColors.green,
              disabledBackgroundColor: Colors.grey[300],
            ),
            onPressed: state.canConfirm
                ? () async {
                    final ok = await vm.confirmarESalvar();
                    if (ok && context.mounted) {
                      context.go('/fiscalizacao');
                    }
                  }
                : null,
            child: state.isSaving
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Confirmar e Prosseguir',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
