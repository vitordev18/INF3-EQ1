import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;
import 'package:app/core/theme/app_colors.dart';
import 'package:app/features/dof/data/models/dof_item_model.dart';
import 'package:app/features/dof/data/services/excel_parser_service.dart';
import 'package:app/features/dof/data/services/csv_parser_service.dart';
import 'package:app/features/dof/presentation/providers/dof_providers.dart';

class ParsedDofItemsNotifier extends Notifier<List<DofItemModel>> {
  @override
  List<DofItemModel> build() => [];

  void updateItems(List<DofItemModel> items) {
    state = items;
  }
}

final parsedDofItemsProvider = NotifierProvider<ParsedDofItemsNotifier, List<DofItemModel>>(
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

  List<DofItemModel> _parsedItems = [];

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
      );

      if (result != null && result.files.single.path != null) {
        setState(() => _statusMessage = 'Fazendo parsing do arquivo...');

        File file = File(result.files.single.path!);
        final extension = p.extension(file.path).toLowerCase();
        List<DofItemModel> tempItems = [];

        if (extension == '.xlsx' || extension == '.xls') {
          tempItems = await ExcelParserService.parseFile(file: file);
        } else if (extension == '.csv') {
          tempItems = await CsvParserService.parseFile(file: file);
        } else {
          throw Exception('Formato de arquivo não suportado: $extension');
        }

        if (tempItems.isEmpty) {
          throw Exception('A planilha está vazia ou não contém dados válidos.');
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
        _statusMessage = 'Erro ao ler arquivo: ${e.toString()}';
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
      final datasource = ref.read(dofLocalDatasourceProvider);

      await datasource.clearAll();
      await datasource.saveDofItems(_parsedItems);

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
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800),
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
                          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
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
                                DataCell(Text(item.especieCientifico)),
                                DataCell(Text(item.saldoTotal.toString())),
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
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
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
