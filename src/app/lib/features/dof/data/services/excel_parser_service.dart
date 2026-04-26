import 'dart:io';
import 'package:excel/excel.dart';
import 'package:app/features/dof/data/models/dof_item_model.dart';
import 'package:uuid/uuid.dart';

class ExcelParserService {
  static const _uuid = Uuid();

  /// Parseia um arquivo Excel e retorna lista de DofItemModel
  static Future<List<DofItemModel>> parseFile({required File file}) async {
    try {
      final bytes = await file.readAsBytes();
      final excel = Excel.decodeBytes(bytes);

      // Usa primeira planilha
      if (excel.tables.isEmpty) {
        throw Exception('Arquivo Excel vazio');
      }

      final table = excel.tables[excel.tables.keys.first]!;
      return _parseTable(table, excel.tables.keys.first);
    } catch (e) {
      throw Exception('Erro ao ler arquivo Excel: $e');
    }
  }

  /// Parseia uma tabela do Excel
  static List<DofItemModel> _parseTable(Sheet table, String sheetName) {
    try {
      print('[FISCALIZA] ⚙️ FASE 1: PARSING - Excel Workbook');
      print('[FISCALIZA] ├─ Planilha: "$sheetName"');
      print('[FISCALIZA] ├─ Total de linhas: ${table.rows.length}');

      if (table.rows.isEmpty) {
        throw Exception('Planilha vazia');
      }

      // Extrai headers da primeira linha
      final headerRow = table.rows[0];
      final headers = _normalizeHeaders(
        headerRow.map((cell) => cell?.value?.toString() ?? '').toList()
      );

      print('[FISCALIZA] ├─ Detectando cabeçalhos...');
      for (int i = 0; i < headers.length && i < headerRow.length; i++) {
        print('[FISCALIZA] │  ✓ "${headerRow[i]?.value}" → "${headers[i]}"');
      }

      // Valida colunas obrigatórias
      bool hasRequiredColumns = _validateRequiredColumns(headers);
      if (!hasRequiredColumns) {
        throw Exception('Colunas obrigatórias não encontradas');
      }
      print('[FISCALIZA] └─ ✅ Todas as colunas obrigatórias presentes');

      final items = <DofItemModel>[];
      print('[FISCALIZA] ⚙️ FASE 2: EXTRAÇÃO DE DADOS');

      // Processa linhas de dados (a partir da linha 1)
      for (int i = 1; i < table.rows.length; i++) {
        try {
          final row = table.rows[i];

          // Pula linhas vazias
          if (row.every((cell) => cell == null || cell.value.toString().isEmpty)) {
            continue;
          }

          final item = _rowToItem(row, headers, i + 1);
          items.add(item);
          print('[FISCALIZA] ├─ Linha ${i + 1}: Processando item ${item.numero}... ✓');
        } catch (e) {
          print('[FISCALIZA] ├─ Linha ${i + 1}: Erro ao processar - $e');
          continue;
        }
      }

      print('[FISCALIZA] └─ ✅ ${items.length} itens extraídos com sucesso');
      return items;
    } catch (e) {
      throw Exception('Erro ao fazer parse da planilha: $e');
    }
  }

  /// Converte uma linha Excel para DofItemModel
  static DofItemModel _rowToItem(List<Data?> row, List<String> headers, int lineNumber) {
    final data = _mapRowToData(row, headers);

    return DofItemModel(
      id: _uuid.v4(),
      numero: _getValue(data['numero']),
      produto: _getValue(data['produto']),
      especieCientifico: _getValue(data['especieCientifico']),
      nomePopular: _getValue(data['nomePopular']),
      saldoLivre: _parseDouble(data['saldoLivre']),
      saldoTotal: _parseDouble(data['saldoTotal']),
      unidade: _getValue(data['unidade'], defaultValue: 'm³'),
    );
  }

  /// Mapeia valores da linha Excel para chaves conhecidas
  static Map<String, dynamic> _mapRowToData(List<Data?> row, List<String> headers) {
    final data = <String, dynamic>{};

    for (int i = 0; i < headers.length && i < row.length; i++) {
      final cell = row[i];
      data[headers[i]] = cell?.value;
    }

    return data;
  }

  /// Normaliza nomes de colunas
  static List<String> _normalizeHeaders(List<String> headers) {
    return headers.map((header) {
      final normalized = header.toLowerCase().trim();

      if (normalized.contains('número') || normalized.contains('num') || normalized == 'id') {
        return 'numero';
      } else if (normalized.contains('produto') || normalized.contains('product')) {
        return 'produto';
      } else if (normalized.contains('especie') || normalized.contains('científico') || normalized.contains('scientific')) {
        return 'especieCientifico';
      } else if (normalized.contains('popular') || normalized.contains('common')) {
        return 'nomePopular';
      } else if (normalized.contains('saldo livre') || normalized.contains('free') || normalized.contains('disponível')) {
        return 'saldoLivre';
      } else if (normalized.contains('saldo total') || normalized.contains('total')) {
        return 'saldoTotal';
      } else if (normalized.contains('unidade') || normalized.contains('unit')) {
        return 'unidade';
      }

      return normalized;
    }).toList();
  }

  /// Valida se as colunas obrigatórias estão presentes
  static bool _validateRequiredColumns(List<String> headers) {
    const required = ['numero', 'produto', 'especieCientifico', 'nomePopular', 'saldoLivre', 'saldoTotal'];
    return required.every((field) => headers.contains(field));
  }

  /// Extrai valor da célula Excel
  static String _getValue(dynamic value, {String defaultValue = ''}) {
    if (value == null) return defaultValue;
    return value.toString().trim();
  }

  /// Converte valor para double, tratando vírgula brasileira
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();

    String str = value.toString().trim();
    // Tratamento de vírgula brasileira
    str = str.replaceAll(',', '.');

    try {
      return double.parse(str);
    } catch (e) {
      return 0.0;
    }
  }
}
