import 'package:app/core/theme/app_colors.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class DofItem {
  final String numero;
  final String produto;
  final String especie;
  final String nomePopular;
  final String saldoLivre;
  final String saldoTotal;
  final String unidade;

  DofItem({
    required this.numero,
    required this.produto,
    required this.especie,
    required this.nomePopular,
    required this.saldoLivre,
    required this.saldoTotal,
    required this.unidade,
  });
}

class ParsedDofItemsNotifier extends Notifier<List<DofItem>> {
  @override
  List<DofItem> build() => [];

  void updateItems(List<DofItem> items) {
    state = items;
  }
}

final parsedDofItemsProvider = NotifierProvider<ParsedDofItemsNotifier, List<DofItem>>(
  ParsedDofItemsNotifier.new,
);

class UploadDofScreen extends ConsumerStatefulWidget {
  const UploadDofScreen({super.key});

  @override
  ConsumerState<UploadDofScreen> createState() => _UploadDofScreenState();
}

class _UploadDofScreenState extends ConsumerState<UploadDofScreen> {
  bool _isImporting = false;
  bool _isSaving = false;
  String? _statusMessage;
  bool _isError = false;

  List<DofItem> _parsedItems = [];

  Future<void> _pickExcelFile() async {
    setState(() {
      _isImporting = true;
      _statusMessage = 'Aguardando seleção do arquivo...';
      _isError = false;
      _parsedItems.clear();
    });

    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls', 'csv'],
        dialogTitle: 'Selecione a planilha DOF',
        withData: true,
      );

      if (result != null) {
        setState(() => _statusMessage = 'Fazendo parsing do arquivo...');

        final fileBytes = result.files.single.bytes;
        if (fileBytes == null) {
          throw Exception('Não foi possível ler os bytes do arquivo.');
        }

        var excel = Excel.decodeBytes(fileBytes);

        final sheetName = excel.tables.keys.first;
        final sheet = excel.tables[sheetName];
        if (sheet == null || sheet.maxRows == 0) {
          throw Exception('A planilha está vazia.');
        }

        List<DofItem> tempItems = [];

        for (int i = 0; i < sheet.maxRows; i++) {
          var row = sheet.rows[i];

          if (row.isEmpty || row.every((cell) => cell?.value == null)) continue;

          String numeroStr = row.elementAtOrNull(0)?.value?.toString().trim() ?? '';
          String produtoStr = row.elementAtOrNull(1)?.value?.toString().trim() ?? '';
          String especieStr = row.elementAtOrNull(2)?.value?.toString().trim() ?? '';
          String nomePopularStr = row.elementAtOrNull(3)?.value?.toString().trim() ?? '';
          String saldoLivreStr = row.elementAtOrNull(4)?.value?.toString().trim() ?? '0';
          String saldoTotalStr = row.elementAtOrNull(5)?.value?.toString().trim() ?? '0';
          String unidadeStr = row.elementAtOrNull(6)?.value?.toString().trim() ?? '';

          if (numeroStr.toLowerCase() == 'nº' ||
              numeroStr.toLowerCase() == 'numero' ||
              produtoStr.toLowerCase() == 'produto') {
            continue;
          }

          if (numeroStr.isEmpty && produtoStr.isEmpty && especieStr.isEmpty) continue;

          tempItems.add(
            DofItem(
              numero: numeroStr,
              produto: produtoStr,
              especie: especieStr,
              nomePopular: nomePopularStr,
              saldoLivre: saldoLivreStr,
              saldoTotal: saldoTotalStr,
              unidade: unidadeStr,
            ),
          );
        }

        setState(() {
          _parsedItems = tempItems;
          _statusMessage = 'Sucesso: ${_parsedItems.length} itens lidos.';
          _isError = false;
        });
      } else {
        setState(() {
          _statusMessage = 'Seleção cancelada pelo usuário.';
          _isError = false;
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Erro no formato da planilha: ${e.toString()}';
        _isError = true;
        _parsedItems.clear();
      });
    } finally {
      if (mounted) setState(() => _isImporting = false);
    }
  }

  Future<void> _confirmarESalvar() async {
    setState(() => _isSaving = true);

    try {
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        ref.read(parsedDofItemsProvider.notifier).updateItems(_parsedItems);
        context.go('/fiscalizacao');
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Erro ao salvar no banco de dados: $e';
        _isError = true;
      });
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool canConfirm = _parsedItems.isNotEmpty && !_isImporting && !_isSaving;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Upload do DOF',
          style: TextStyle(color: AppColors.black, fontWeight: FontWeight.w800),
        ),
        backgroundColor: AppColors.green,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () => context.go('/'),
        ),
      ),
      body: Padding(
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
                    const Icon(Icons.upload_file_rounded, size: 60, color: AppColors.green),
                    const SizedBox(height: 16),
                    Text(
                      'Importar Planilha DOF',
                      style: Theme.of(
                        context,
                      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    if (_statusMessage != null)
                      Text(
                        _statusMessage!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _isError ? Colors.red : Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.green,
                          foregroundColor: AppColors.white,
                        ),
                        onPressed: _isImporting || _isSaving ? null : _pickExcelFile,
                        child: _isImporting
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
            Expanded(
              child: _parsedItems.isEmpty
                  ? const Center(
                      child: Text(
                        'Nenhum dado para exibir.\nFaça o upload da planilha.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Color(0xFF9E9E9E)),
                      ),
                    )
                  : SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          headingRowColor: WidgetStateProperty.all(AppColors.lightGrey),
                          columns: const [
                            DataColumn(label: Text('Número')),
                            DataColumn(label: Text('Produto')),
                            DataColumn(label: Text('Espécie')),
                            DataColumn(label: Text('Saldo Total')),
                            DataColumn(label: Text('Unid.')),
                          ],
                          rows: _parsedItems.map((item) {
                            return DataRow(
                              cells: [
                                DataCell(Text(item.numero)),
                                DataCell(Text(item.produto)),
                                DataCell(Text(item.especie)),
                                DataCell(Text(item.saldoTotal)),
                                DataCell(Text(item.unidade)),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.green,
                  disabledBackgroundColor: Colors.grey[300],
                ),
                onPressed: canConfirm ? _confirmarESalvar : null,
                child: _isSaving
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
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
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
