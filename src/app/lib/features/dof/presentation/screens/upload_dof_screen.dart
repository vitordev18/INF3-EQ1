import 'dart:typed_data'; // Necessário para converter a string em bytes
import 'package:app/core/theme/app_colors.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart'; // Pacote de download
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
  
  // Nova variável para guardar o XML gerado
  String? _xmlContent; 

  Future<void> _pickAndConvertExcelFile() async {
    setState(() {
      _isImporting = true;
      _statusMessage = 'Aguardando seleção do arquivo...';
      _isError = false;
      _xmlContent = null; // Reseta o XML anterior, se houver
    });

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
        dialogTitle: 'Selecione a planilha DOF',
        withData: true,
      );
      
      if (result != null) {
        setState(() => _statusMessage = 'Lendo e convertendo arquivo...');
        
        final fileBytes = result.files.single.bytes;
        if (fileBytes == null) {
          throw Exception('Não foi possível ler os bytes do arquivo.');
        }
        
        var excel = Excel.decodeBytes(fileBytes);
        int numLinhas = 0;

        
        String xmlString = '<?xml version="1.0" encoding="UTF-8"?>\n<Planilhas>\n';
        
        for (var table in excel.tables.keys) {
          xmlString += '  <Aba nome="$table">\n';
          for (var row in excel.tables[table]!.rows) {
            numLinhas++;
            xmlString += '    <Linha>\n';
            for (var i = 0; i < row.length; i++) {
              var cellValue = row[i]?.value?.toString() ?? '';
              xmlString += '      <Coluna$i>$cellValue</Coluna$i>\n';
            }
            xmlString += '    </Linha>\n';
          }
          xmlString += '  </Aba>\n';
        }
        xmlString += '</Planilhas>';
        // --- FIM DA CONVERSÃO ---

        setState(() {
          _statusMessage = 'Conversão concluída!\n($numLinhas linhas processadas)';
          _xmlContent = xmlString;
          _isError = false;
        });

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
      Uint8List bytes = Uint8List.fromList(_xmlContent!.codeUnits);
      
      await FileSaver.instance.saveFile(
        name: "Planilha_DOF_Convertida.xml", 
        bytes: bytes,
        
        mimeType: MimeType.xml,
      );

      setState(() {
        _statusMessage = 'Download iniciado com sucesso!';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Erro ao baixar: ${e.toString()}';
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
          icon: const Icon(Icons.arrow_back), 
          onPressed: () => context.go('/')
        ),
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
                    icon: const Icon(Icons.download, color: Colors.white),
                    label: const Text('Baixar Arquivo XML', style: TextStyle(color: Colors.white)),
                  ),
                )
              else
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.green),
                    onPressed: _isImporting ? null : _pickAndConvertExcelFile,
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
                TextButton(
                  onPressed: () {
                    setState(() {
                      _xmlContent = null;
                      _statusMessage = null;
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