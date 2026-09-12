import 'dart:io';
import 'package:csv/csv.dart';
import 'package:fiscaliza/core/logging/app_logger.dart';
import 'package:fiscaliza/features/dof/data/models/dof_item_model.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';

class CsvParserService {
  static const _uuid = Uuid();

  static Future<List<DofItemModel>> parseFile({required File file}) async {
    try {
      final content = await file.readAsString(
        encoding: Encoding.getByName('utf-8') ?? const Utf8Codec(),
      );
      return _parseContent(content);
    } catch (e) {
      throw Exception('Erro ao ler arquivo CSV: $e');
    }
  }

  static List<DofItemModel> _parseContent(String csvContent) {
    try {
      final normalizado = csvContent
          .replaceAll('\r\n', '\n')
          .replaceAll('\r', '\n');

      // O número do item é preservado como texto: é por ele que o fiscal casa
      // o item com o DOF em papel, e "001" não pode virar 1.
      final List<List<dynamic>> rows = const CsvDecoder(
        dynamicTyping: false,
      ).convert(normalizado);
      if (rows.isEmpty) {
        throw Exception('Arquivo CSV vazio');
      }

      while (rows.isNotEmpty &&
          !rows[0].join().toLowerCase().contains('produto')) {
        rows.removeAt(0);
      }

      if (rows.isEmpty) {
        throw Exception('Cabeçalho não encontrado no arquivo CSV');
      }

      final headers = _normalizeHeaders(
        rows[0].map((h) => h.toString()).toList(),
      );
      AppLogger.info('[FISCALIZA] ├─ Detectando cabeçalhos...');
      for (int i = 0; i < headers.length; i++) {
        AppLogger.info('[FISCALIZA] │  ✓ "${rows[0][i]}" → "${headers[i]}"');
      }

      final bool hasRequiredColumns = _validateRequiredColumns(headers);
      if (!hasRequiredColumns) {
        throw Exception('Colunas obrigatórias não encontradas');
      }

      final items = <DofItemModel>[];

      for (int i = 1; i < rows.length; i++) {
        try {
          final row = rows[i];
          if (row.isEmpty || row.every((cell) => cell.toString().isEmpty)) {
            continue;
          }

          final item = _rowToItem(row, headers, i + 1);
          items.add(item);
        } catch (e) {
          continue;
        }
      }

      return items;
    } catch (e) {
      throw Exception('Erro ao fazer parse CSV: $e');
    }
  }

  static DofItemModel _rowToItem(
    List<dynamic> row,
    List<String> headers,
    int lineNumber,
  ) {
    final data = _mapRowToData(row, headers);

    return DofItemModel(
      id: _uuid.v4(),
      numero: _getString(data['numero']),
      produto: _getString(data['produto']),
      especieCientifico: _getString(data['especieCientifico']),
      nomePopular: _getString(data['nomePopular']),
      saldoLivre: _parseDouble(data['saldoLivre']),
      saldoTotal: _parseDouble(data['saldoTotal']),
      unidade: _getString(data['unidade'], defaultValue: 'm³'),
    );
  }

  static Map<String, dynamic> _mapRowToData(
    List<dynamic> row,
    List<String> headers,
  ) {
    final data = <String, dynamic>{};

    for (int i = 0; i < headers.length && i < row.length; i++) {
      data[headers[i]] = row[i];
    }

    return data;
  }

  static List<String> _normalizeHeaders(List<String> headers) {
    return headers.map((header) {
      final normalized = header.toLowerCase().trim();

      if (normalized.contains('número') ||
          normalized.contains('num') ||
          normalized == 'id' ||
          normalized == 'nº') {
        return 'numero';
      } else if (normalized.contains('produto') ||
          normalized.contains('product')) {
        return 'produto';
      } else if (normalized.contains('especie') ||
          normalized.contains('científico') ||
          normalized.contains('scientific')) {
        return 'especieCientifico';
      } else if (normalized.contains('popular') ||
          normalized.contains('common')) {
        return 'nomePopular';
      } else if (normalized.contains('saldo livre') ||
          normalized.contains('free') ||
          normalized.contains('disponível')) {
        return 'saldoLivre';
      } else if (normalized.contains('saldo total') ||
          normalized.contains('total')) {
        return 'saldoTotal';
      } else if (normalized.contains('unidade') ||
          normalized.contains('unit')) {
        return 'unidade';
      }
      return normalized;
    }).toList();
  }

  static bool _validateRequiredColumns(List<String> headers) {
    const required = [
      'numero',
      'produto',
      'especieCientifico',
      'nomePopular',
      'saldoLivre',
      'saldoTotal',
    ];
    return required.every((field) => headers.contains(field));
  }

  static String _getString(dynamic value, {String defaultValue = ''}) {
    if (value == null) return defaultValue;
    return value.toString().trim();
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
