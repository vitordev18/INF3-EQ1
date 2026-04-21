import 'package:app/core/theme/app_colors.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class UploadDofScreen extends StatefulWidget {
  const UploadDofScreen({super.key});

  @override
  State<UploadDofScreen> createState() => _UploadDofScreenState();
}

class _UploadDofScreenState extends State<UploadDofScreen> {
  bool _isImporting = false;
  String? _statusMessage;
  bool _isError = false;

  Future<void> _pickExcelFile() async {
    setState(() {
      _isImporting = true;
      _statusMessage = 'Aguardando seleção do arquivo...';
      _isError = false;
    });

    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls', 'csv'],
        dialogTitle: 'Selecione a planilha DOF',
        withData: true,
      );
      if (result != null) {
        setState(() => _statusMessage = 'Lendo arquivo...');
        final fileBytes = result.files.single.bytes;
        if (fileBytes == null) {
          throw Exception('Não foi possível ler os bytes do arquivo.');
        }
        var excel = Excel.decodeBytes(fileBytes);

        int numLinhas = 0;
        for (var table in excel.tables.keys) {
          numLinhas += excel.tables[table]?.maxRows ?? 0;
        }

        setState(() {
          _statusMessage = 'Planilha lida com sucesso!\n($numLinhas linhas encontradas)';
          _isError = false;
        });

        await Future.delayed(const Duration(seconds: 5));
        if (mounted) context.go('/');
      } else {
        setState(() {
          _statusMessage = 'Nenhum arquivo selecionado.';
          _isError = false;
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Erro ao ler planilha: ${e.toString()}';
        _isError = true;
      });
    } finally {
      if (mounted) setState(() => _isImporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Upload do DOF',
          style: TextStyle(color: AppColors.black, fontWeight: FontWeight.w800),
        ),
        backgroundColor: AppColors.green,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/')),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.upload_file_rounded, size: 80, color: AppColors.green),
              const SizedBox(height: 24),
              Text('Importar Planilha DOF', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              if (_statusMessage != null)
                Text(
                  _statusMessage!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _isError ? Colors.red : Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.green),
                  onPressed: _isImporting ? null : _pickExcelFile,
                  child: _isImporting
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Selecionar Planilha', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
