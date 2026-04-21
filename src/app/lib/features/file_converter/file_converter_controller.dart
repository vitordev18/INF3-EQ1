import 'dart:io';
import 'dart:typed_data'; // Movido para o topo
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart'; // Movido para o topo
import '../utils/file_converter_util.dart';

class FileConverterController extends ChangeNotifier {
  bool isLoading = false;
  String? convertedXml;
  String? errorMessage;

  Future<void> pickAndConvertFile() async {
    try {
      _setLoading(true);

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv', 'xls', 'xlsx'],
      );

      if (result != null && result.files.single.path != null) {
        File file = File(result.files.single.path!);
        String extension = result.files.single.extension?.toLowerCase() ?? '';

        if (extension == 'csv') {
          convertedXml = await FileConverterUtil.convertCsvToXml(file);
        } else if (extension == 'xls' || extension == 'xlsx') {
          convertedXml = await FileConverterUtil.convertExcelToXml(file);
        } else {
          errorMessage = 'Formato não suportado.';
        }
      } else {
        errorMessage = 'Nenhum arquivo selecionado.';
      }
    } catch (e) {
      errorMessage = 'Erro ao converter o arquivo: $e';
    } finally {
      _setLoading(false); // Isso garante que o carregamento pare!
    }
  }

  void _setLoading(bool value) {
    isLoading = value;
    if (value) {
      errorMessage = null;
      convertedXml = null;
    }
    notifyListeners(); // Avisa a tela para se redesenhar
  }

  Future<void> downloadConvertedFile() async {
    if (convertedXml == null) {
      errorMessage = 'Não há nenhum arquivo convertido para baixar.';
      notifyListeners();
      return;
    }

    try {
      _setLoading(true);

      // Transforma a string XML em bytes
      Uint8List bytes = Uint8List.fromList(convertedXml!.codeUnits);

      // Abre a janela de salvar arquivo no dispositivo
      await FileSaver.instance.saveFile(
        name: "arquivo_convertido", // Nome do arquivo gerado
        bytes: bytes,
        ext: "xml", // Extensão
        mimeType: MimeType.xml,
      );

    } catch (e) {
      errorMessage = 'Erro ao salvar o arquivo: $e';
    } finally {
      _setLoading(false);
    }
  }
}