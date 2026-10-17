import 'dart:io';
import 'package:excel/excel.dart';
import 'package:fiscaliza/core/logging/app_logger.dart';
import 'package:fiscaliza/core/utils/text_encoding.dart';
import 'package:fiscaliza/features/dof/data/models/dof_item_model.dart';
import 'package:uuid/uuid.dart';

class ExcelParserService {
  static const _uuid = Uuid();

  static Future<List<DofItemModel>> parseFile({required File file}) async {
    try {
      final bytes = await file.readAsBytes();
      final excel = Excel.decodeBytes(bytes);

      if (excel.tables.isEmpty) {
        throw Exception('Arquivo Excel vazio');
      }

      final table = excel.tables[excel.tables.keys.first]!;
      return _parseTable(table, excel.tables.keys.first);
    } catch (e) {
      throw Exception('Erro ao ler arquivo Excel: $e');
    }
  }

  static List<DofItemModel> _parseTable(Sheet table, String sheetName) {
    try {
      AppLogger.info('⚙️ FASE 1: PARSING - Excel Workbook');
      AppLogger.info('├─ Planilha: "$sheetName"');
      AppLogger.info('├─ Total de linhas: ${table.rows.length}');

      if (table.rows.isEmpty) {
        throw Exception('Planilha vazia');
      }

      final headerIndex = _encontrarLinhaDoCabecalho(table.rows);
      if (headerIndex == -1) {
        throw Exception(
          'Cabeçalho não encontrado: nenhuma linha da planilha contém a '
          'coluna "Produto". Confira se a aba selecionada é a da tabela '
          'de produtos do DOF.',
        );
      }

      final headerRow = table.rows[headerIndex];
      final rotulosLidos = headerRow
          .map((cell) => repararEncoding(cell?.value?.toString().trim() ?? ''))
          .toList();
      final headers = _normalizeHeaders(rotulosLidos);

      AppLogger.info('├─ Cabeçalho na linha ${headerIndex + 1}');
      AppLogger.info('├─ Detectando cabeçalhos...');
      for (int i = 0; i < headers.length && i < headerRow.length; i++) {
        AppLogger.info('│  ✓ "${headerRow[i]?.value}" → "${headers[i]}"');
      }

      final faltantes = _colunasFaltantes(headers);
      if (faltantes.isNotEmpty) {
        final encontradas = rotulosLidos.where((h) => h.isNotEmpty).join(', ');
        throw Exception(
          'Colunas obrigatórias não encontradas: ${faltantes.join(', ')}. '
          'Colunas lidas na planilha: $encontradas',
        );
      }
      AppLogger.info('└─ ✅ Todas as colunas obrigatórias presentes');

      final items = <DofItemModel>[];
      AppLogger.info('⚙️ FASE 2: EXTRAÇÃO DE DADOS');

      for (int i = headerIndex + 1; i < table.rows.length; i++) {
        try {
          final row = table.rows[i];

          if (row.every((cell) => cell == null || cell.value.toString().isEmpty)) {
            continue;
          }

          final item = _rowToItem(row, headers, i + 1);
          items.add(item);
          AppLogger.info('├─ Linha ${i + 1}: Processando item ${item.numero}... ✓');
        } catch (e) {
          AppLogger.warn('├─ Linha ${i + 1}: Erro ao processar - $e');
          continue;
        }
      }

      AppLogger.info('└─ ✅ ${items.length} itens extraídos com sucesso');
      return items;
    } catch (e) {
      throw Exception('Erro ao fazer parse da planilha: $e');
    }
  }

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

  static Map<String, dynamic> _mapRowToData(List<Data?> row, List<String> headers) {
    final data = <String, dynamic>{};

    for (int i = 0; i < headers.length && i < row.length; i++) {
      final cell = row[i];
      data[headers[i]] = cell?.value;
    }

    return data;
  }

  static String _semAcento(String texto) {
    const de = 'áàâãäéèêëíìîïóòôõöúùûüçÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇ';
    const para = 'aaaaaeeeeiiiiooooouuuucAAAAAEEEEIIIIOOOOOUUUUC';
    final buffer = StringBuffer();
    for (final char in texto.split('')) {
      final i = de.indexOf(char);
      buffer.write(i == -1 ? char : para[i]);
    }
    return buffer.toString();
  }

  static String _compactar(String texto) =>
      texto.replaceAll(RegExp('[^a-z0-9]'), '');

  static List<String> _normalizeHeaders(List<String> headers) {
    return headers.map((header) {
      final bruto = header.toLowerCase().trim();
      final normalized = _semAcento(bruto);
      final compacto = _compactar(normalized);
      final compactoBruto = _compactar(bruto);

      if (normalized.contains('saldo livre') ||
          compacto.contains('saldolivre') ||
          normalized.contains('free') ||
          normalized.contains('disponivel')) {
        return 'saldoLivre';
      }
      if (normalized.contains('saldo total') ||
          compacto.contains('saldototal') ||
          normalized.contains('total')) {
        return 'saldoTotal';
      }
      if (normalized.contains('popular') || normalized.contains('common')) {
        return 'nomePopular';
      }
      if (normalized.contains('especie') ||
          normalized.contains('cientifico') ||
          normalized.contains('scientific')) {
        return 'especieCientifico';
      }
      if (normalized.contains('produto') || normalized.contains('product')) {
        return 'produto';
      }
      if (normalized.contains('unidade') || normalized.contains('unit')) {
        return 'unidade';
      }
      if (compacto.contains('numero') ||
          compacto.contains('num') ||
          compacto == 'id' ||
          compacto == 'ordem' ||
          compactoBruto == 'n' ||
          compactoBruto == 'no' ||
          compactoBruto == 'num') {
        return 'numero';
      }

      return normalized;
    }).toList();
  }

  static const _rotulosObrigatorios = <String, String>{
    'numero': 'Número',
    'produto': 'Produto',
    'especieCientifico': 'Espécie (Científico)',
    'nomePopular': 'Nome Popular',
    'saldoLivre': 'Saldo Livre',
    'saldoTotal': 'Saldo Total',
  };

  static int _encontrarLinhaDoCabecalho(List<List<Data?>> rows) {
    for (int i = 0; i < rows.length; i++) {
      final conteudo = rows[i]
          .map((cell) => cell?.value?.toString() ?? '')
          .join(' ')
          .toLowerCase();
      if (conteudo.contains('produto')) return i;
    }
    return -1;
  }

  static List<String> _colunasFaltantes(List<String> headers) {
    return _rotulosObrigatorios.entries
        .where((e) => !headers.contains(e.key))
        .map((e) => e.value)
        .toList();
  }

  static String _getValue(dynamic value, {String defaultValue = ''}) {
    if (value == null) return defaultValue;
    final texto = repararEncoding(value.toString().trim());
    return texto.isEmpty ? defaultValue : texto;
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();

    String str = value.toString().trim();
    str = str.replaceAll(',', '.');

    try {
      return double.parse(str);
    } catch (e) {
      return 0.0;
    }
  }
}
