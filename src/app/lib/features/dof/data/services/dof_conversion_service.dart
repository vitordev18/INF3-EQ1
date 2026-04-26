import 'dart:io';
import 'package:app/features/dof/data/models/dof_item_model.dart';
import 'package:app/features/dof/data/services/csv_parser_service.dart';
import 'package:app/features/dof/data/services/excel_parser_service.dart';
import 'package:app/features/dof/data/services/xml_generator_service.dart';
import 'package:app/features/dof/data/services/dof_validator_service.dart';

class DofConversionService {
  /// Realiza conversão completa: arquivo → parsing → validação → XML
  static Future<DofConversionResult> convertFile({
    required File file,
    String? customFileName,
  }) async {
    final startTime = DateTime.now();

    try {
      print('[FISCALIZA] 🚀 Iniciando conversão DOF...');
      print('[FISCALIZA] 📁 Arquivo selecionado: ${file.path}');
      print('[FISCALIZA] 📏 Tamanho: ${await _getFileSizeInKb(file)} KB');
      print('[FISCALIZA]');

      final fileName = customFileName ?? file.path.split('/').last;
      final extension = fileName.split('.').last.toLowerCase();

      List<DofItemModel> items;

      // Seleciona parser baseado na extensão
      if (extension == 'csv') {
        items = await CsvParserService.parseFile(file: file);
      } else if (extension == 'xlsx' || extension == 'xls') {
        items = await ExcelParserService.parseFile(file: file);
      } else {
        throw Exception('Formato não suportado: $extension');
      }

      // Fase de validação
      print('[FISCALIZA]');
      print('[FISCALIZA] ⚙️ FASE 3: VALIDAÇÃO');

      final validation = DofValidatorService.validateBatch(items);

      for (int i = 0; i < items.length; i++) {
        final itemValidation = DofValidatorService.validateItem(items[i]);
        if (itemValidation.isValid) {
          print('[FISCALIZA] ├─ Validando item ${items[i].numero} (${items[i].nomePopular})...');
          print('[FISCALIZA] │  ✓ Campos obrigatórios preenchidos');
          print('[FISCALIZA] │  ✓ Saldo Livre (${items[i].saldoLivre}) ≤ Saldo Total (${items[i].saldoTotal})');
        }
      }

      print('[FISCALIZA] └─ ✅ ${validation.validItems}/${validation.totalItems} itens válidos (${validation.successRate.toStringAsFixed(2)}%)');

      // Se houver itens inválidos, listar erros
      if (validation.invalidItems.isNotEmpty) {
        print('[FISCALIZA]');
        print('[FISCALIZA] ⚠️ ITENS COM ERRO:');
        validation.invalidItems.forEach((index, result) {
          print('[FISCALIZA] ├─ Item ${index + 2}: ${result.errors.join(", ")}');
        });
      }

      // Fase de geração XML
      print('[FISCALIZA]');
      print('[FISCALIZA] ⚙️ FASE 4: GERAÇÃO DE XML');
      print('[FISCALIZA] ├─ Criando documento XML...');
      print('[FISCALIZA] ├─ Adicionando metadata...');
      print('[FISCALIZA] │  • dataImportacao: ${DateTime.now().toIso8601String()}');
      print('[FISCALIZA] │  • totalItens: ${items.length}');
      print('[FISCALIZA] │  • nomeArquivoOrigem: $fileName');
      print('[FISCALIZA] ├─ Adicionando itens...');

      for (int i = 0; i < items.length; i++) {
        print('[FISCALIZA] │  • [${i + 1}/${items.length}] Item ${items[i].numero} - ${items[i].nomePopular}');
      }

      final xmlContent = XmlGeneratorService.generateDofXml(
        items: items,
        originalFileName: fileName,
        importDate: DateTime.now(),
      );

      print('[FISCALIZA] ├─ Formatando XML (pretty print)...');
      print('[FISCALIZA] ├─ Tamanho do XML: ${(xmlContent.length / 1024).toStringAsFixed(2)} KB');
      print('[FISCALIZA] └─ ✅ XML gerado com sucesso');

      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);

      print('[FISCALIZA]');
      print('[FISCALIZA] ⚙️ FASE 5: PERSISTÊNCIA');
      print('[FISCALIZA] ├─ Arquivo XML pronto para persistência');
      print('[FISCALIZA] ├─ Banco de dados pronto para sincronização');
      print('[FISCALIZA] └─ ✅ Dados prontos para persistência');

      XmlGeneratorService.logConversionSummary(
        totalItems: items.length,
        validItems: validation.validItems,
        invalidItems: validation.invalidItems.length,
        processingTime: duration,
      );

      return DofConversionResult(
        success: true,
        items: items,
        xmlContent: xmlContent,
        duration: duration,
        validationResult: validation,
      );
    } catch (e) {
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);

      print('[FISCALIZA] ❌ ERRO NA CONVERSÃO');
      print('[FISCALIZA] ${e.toString()}');

      return DofConversionResult(
        success: false,
        items: [],
        xmlContent: '',
        duration: duration,
        errorMessage: e.toString(),
      );
    }
  }

  static Future<double> _getFileSizeInKb(File file) async {
    final bytes = await file.length();
    return bytes / 1024;
  }
}

class DofConversionResult {
  final bool success;
  final List<DofItemModel> items;
  final String xmlContent;
  final Duration duration;
  final ValidationBatchResult? validationResult;
  final String? errorMessage;

  DofConversionResult({
    required this.success,
    required this.items,
    required this.xmlContent,
    required this.duration,
    this.validationResult,
    this.errorMessage,
  });
}
