import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
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
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {                                                                                        
    isLoading = value;
    if (value) {
      errorMessage = null;
      convertedXml = null;
    }
    notifyListeners();
  }
}