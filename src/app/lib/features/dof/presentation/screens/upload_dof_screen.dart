import 'dart:io';
import 'dart:typed_data';
import 'package:app/core/theme/app_colors.dart';
import 'package:app/features/dof/data/services/dof_conversion_service.dart';
import 'package:file_picker/file_picker.dart';
// MANTIDO COMENTADO: Não estamos usando o FileSaver agora para testar no celular
// import 'package:file_saver/file_saver.dart'; 
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart'; // Novo pacote para compartilhamento

class UploadDofScreen extends StatefulWidget {
  const UploadDofScreen({super.key});

  @override
  State<UploadDofScreen> createState() => _UploadDofScreenState();
}

class _UploadDofScreenState extends State<UploadDofScreen> {
  bool _isImporting = false;
  String? _statusMessage;
  bool _isError = false;
  String? _xmlContent;
  DofConversionResult? _conversionResult;

  Future<void> _pickAndConvertFile() async {
    setState(() {
      _isImporting = true;
      _statusMessage = 'Aguardando seleção do arquivo...';
      _isError = false;
      _xmlContent = null;
      _conversionResult = null;
    });

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls', 'csv'],
        dialogTitle: 'Selecione a planilha DOF',
      );

      if (result != null && result.files.single.path != null) {
        setState(() => _statusMessage = 'Lendo e convertendo arquivo...');

        final file = File(result.files.single.path!);
        final fileName = result.files.single.name;

        final conversionResult = await DofConversionService.convertFile(
          file: file,
          customFileName: fileName,
        );

        if (conversionResult.success) {
          setState(() {
            _statusMessage = 'Conversão concluída com sucesso!\n'
                '${conversionResult.items.length} itens processados\n'
                'Tempo: ${conversionResult.duration.inMilliseconds}ms';
            _xmlContent = conversionResult.xmlContent;
            _conversionResult = conversionResult;
            _isError = false;
          });
        } else {
          setState(() {
            _statusMessage = 'Erro na conversão:\n${conversionResult.errorMessage}';
            _isError = true;
          });
        }
      } else {
        setState(() {
          _statusMessage = 'Nenhum arquivo selecionado.';
          _isError = false;
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Erro ao ler/converter: ${e.toString()}';
        _isError = true;
      });
    } finally {
      if (mounted) setState(() => _isImporting = false);
    }
  }

  Future<void> _downloadXml() async {
    if (_xmlContent == null) return;

    try {
      /* --- CÓDIGO ANTIGO DO FILE SAVER (COMENTADO) ---
      Uint8List bytes = Uint8List.fromList(_xmlContent!.codeUnits);
      
      await FileSaver.instance.saveFile(
        name: "Planilha_DOF_Convertida.xml", 
        bytes: bytes,
        mimeType: MimeType.xml,
      );
      ------------------------------------------------ */

      // --- NOVO CÓDIGO DE COMPARTILHAMENTO ---
      await Share.share(
        _xmlContent!,
        subject: 'Planilha_DOF_Convertida.xml',
      );

      setState(() {
        _statusMessage = 'Arquivo aberto para compartilhamento!';
        // _statusMessage = 'Download iniciado com sucesso!'; // Antiga mensagem
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Erro ao compartilhar: ${e.toString()}';
        // _statusMessage = 'Erro ao baixar: ${e.toString()}'; // Antiga mensagem
        _isError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Upload do DOF',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800),
        ),
        backgroundColor: AppColors.green,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/')),
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
              if (_xmlContent != null)
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    onPressed: _downloadXml,
                    icon: const Icon(Icons.share, color: Colors.white), 
                    label: const Text('Compartilhar XML', style: TextStyle(color: Colors.white)),
                  ),
                )
              else
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.green),
                    onPressed: _isImporting ? null : _pickAndConvertFile,
                    child: _isImporting
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text('Selecionar Planilha', style: TextStyle(color: Colors.white)),
                  ),
                ),
              if (_xmlContent != null) ...[
                const SizedBox(height: 16),
                if (_conversionResult != null) ...[
                  Text(
                    'Itens válidos: ${_conversionResult!.validationResult?.validItems}/${_conversionResult!.validationResult?.totalItems}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                ],
                TextButton(
                  onPressed: () {
                    setState(() {
                      _xmlContent = null;
                      _statusMessage = null;
                      _conversionResult = null;
                    });
                  },
                  child: const Text('Escolher outra planilha', style: TextStyle(color: Colors.grey)),
                )
              ]
            ],
          ),
        ),
      ),
    );
  }
}