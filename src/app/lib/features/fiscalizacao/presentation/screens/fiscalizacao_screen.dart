import 'package:app/core/theme/app_colors.dart';
import 'package:app/features/dof/presentation/screens/upload_dof_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

enum StatusFiscalizacao { pendente, emAndamento, concluido, excedente }

class FiscalizacaoHubScreen extends ConsumerStatefulWidget {
  const FiscalizacaoHubScreen({super.key});

  @override
  ConsumerState<FiscalizacaoHubScreen> createState() => _FiscalizacaoHubScreenState();
}

class _FiscalizacaoHubScreenState extends ConsumerState<FiscalizacaoHubScreen> {
  Color _getStatusColor(StatusFiscalizacao status) {
    switch (status) {
      case StatusFiscalizacao.pendente:
        return Colors.grey.shade600;
      case StatusFiscalizacao.emAndamento:
        return Colors.orange.shade700;
      case StatusFiscalizacao.concluido:
        return AppColors.green;
      case StatusFiscalizacao.excedente:
        return Colors.red.shade700;
    }
  }

  String _getStatusText(StatusFiscalizacao status) {
    switch (status) {
      case StatusFiscalizacao.pendente:
        return 'Pendente';
      case StatusFiscalizacao.emAndamento:
        return 'Em Andamento';
      case StatusFiscalizacao.concluido:
        return 'Concluído';
      case StatusFiscalizacao.excedente:
        return 'Excedente';
    }
  }

  void _iniciarFiscalizacao(DofItem produto) {
    context.push('/fiscalizacao/captura', extra: produto);
  }

  void _adicionarProdutoExtra() {
    context.push('/fiscalizacao/cadastro');
  }

  @override
  Widget build(BuildContext context) {
    final produtosLidos = ref.watch(parsedDofItemsProvider);

    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
        backgroundColor: AppColors.green,
        title: const Text(
          'Hub de Fiscalização',
          style: TextStyle(color: AppColors.black, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () => context.go('/upload-dof'),
        ),
      ),
      body: produtosLidos.isEmpty
          ? const Center(
              child: Text(
                'Nenhum produto lido da planilha.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16.0),
              itemCount: produtosLidos.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final produto = produtosLidos[index];

                final statusAtual = StatusFiscalizacao.pendente;
                final statusColor = _getStatusColor(statusAtual);

                final saldoFormatado = double.tryParse(produto.saldoTotal) ?? 0.0;

                return Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => _iniciarFiscalizacao(produto),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  produto.produto,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.black,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.green, width: 2),
                                ),
                                child: Text(
                                  _getStatusText(statusAtual),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: statusColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Espécie: ${produto.especie} (${produto.nomePopular})',
                            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(
                                Icons.inventory_2_outlined,
                                size: 16,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Saldo Declarado: ${saldoFormatado.toStringAsFixed(2)} ${produto.unidade}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.black,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _adicionarProdutoExtra,
        backgroundColor: AppColors.green,
        icon: const Icon(Icons.add, color: AppColors.white),
        label: const Text(
          'Produto Extra',
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
