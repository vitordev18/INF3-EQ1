import 'package:xml/xml.dart' as xml;
import 'package:app/features/dof/data/models/dof_item_model.dart';

class XmlGeneratorService {
  /// Gera XML a partir de uma lista de itens DOF
  static String generateDofXml({
    required List<DofItemModel> items,
    required String originalFileName,
    DateTime? importDate,
  }) {
    importDate ??= DateTime.now();

    final builder = xml.XmlBuilder();

    builder.processing('xml', 'version="1.0" encoding="UTF-8"');

    builder.element('dof', nest: () {
      // Metadata
      builder.element('metadata', nest: () {
        builder.element('dataImportacao', nest: importDate!.toIso8601String());
        builder.element('totalItens', nest: items.length.toString());
        builder.element('nomeArquivoOrigem', nest: originalFileName);
        builder.element('versaoSchema', nest: '1.0');
      });

      // Itens
      builder.element('itens', nest: () {
        for (final item in items) {
          builder.element('item', nest: () {
            builder.element('id', nest: item.id);
            builder.element('numero', nest: item.numero);
            builder.element('produto', nest: _escapeXml(item.produto));
            builder.element('especieCientifico', nest: _escapeXml(item.especieCientifico));
            builder.element('nomePopular', nest: _escapeXml(item.nomePopular));
            builder.element('saldoLivre', nest: item.saldoLivre.toStringAsFixed(2));
            builder.element('saldoTotal', nest: item.saldoTotal.toStringAsFixed(2));
            builder.element('unidade', nest: _normalizeUnidade(item.unidade));
          });
        }
      });
    });

    final document = builder.buildDocument();
    return document.toXmlString(pretty: true, indent: '  ');
  }

  /// Escapa caracteres especiais para XML
  static String _escapeXml(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&apos;');
  }

  /// Normaliza unidade (m³ → m3)
  static String _normalizeUnidade(String unidade) {
    if (unidade.isEmpty) return 'm3';
    return unidade.replaceAll('³', '3').replaceAll('³', '3');
  }

  /// Formata um valor decimal com 2 casas
  static String formatDecimal(double value) {
    return value.toStringAsFixed(2);
  }

  /// Cria um resumo de log para console
  static void logConversionSummary({
    required int totalItems,
    required int validItems,
    required int invalidItems,
    required Duration processingTime,
  }) {
    print('[FISCALIZA] ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('[FISCALIZA] ✅ CONVERSÃO CONCLUÍDA COM SUCESSO');
    print('[FISCALIZA] ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('[FISCALIZA] 📊 Resumo:');
    print('[FISCALIZA]    • Itens processados: $totalItems');
    print('[FISCALIZA]    • Itens válidos: $validItems');
    print('[FISCALIZA]    • Itens inválidos: $invalidItems');
    print('[FISCALIZA]    • Taxa de sucesso: ${(validItems / totalItems * 100).toStringAsFixed(2)}%');
    print('[FISCALIZA]    • Tempo total: ${processingTime.inMilliseconds}ms');
    print('[FISCALIZA] 🎉 O DOF está pronto para ser usado!');
  }
}
