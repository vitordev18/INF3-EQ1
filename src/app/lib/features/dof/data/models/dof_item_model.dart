import 'package:app/features/dof/domain/entities/dof_item.dart';

class DofItemModel extends DofItem {
  DofItemModel({
    required String id,
    required String numero,
    required String produto,
    required String especieCientifico,
    required String nomePopular,
    required double saldoLivre,
    required double saldoTotal,
    required String unidade,
    DateTime? criadoEm,
  }) : super(
    id: id,
    numero: numero,
    produto: produto,
    especieCientifico: especieCientifico,
    nomePopular: nomePopular,
    saldoLivre: saldoLivre,
    saldoTotal: saldoTotal,
    unidade: unidade,
    criadoEm: criadoEm ?? DateTime.now(),
  );

  factory DofItemModel.fromJson(Map<String, dynamic> json) {
    return DofItemModel(
      id: json['id'] as String,
      numero: json['numero'] as String,
      produto: json['produto'] as String,
      especieCientifico: json['especieCientifico'] as String,
      nomePopular: json['nomePopular'] as String,
      saldoLivre: (json['saldoLivre'] as num).toDouble(),
      saldoTotal: (json['saldoTotal'] as num).toDouble(),
      unidade: json['unidade'] as String? ?? 'm³',
      criadoEm: json['criadoEm'] != null
        ? DateTime.parse(json['criadoEm'] as String)
        : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'numero': numero,
      'produto': produto,
      'especieCientifico': especieCientifico,
      'nomePopular': nomePopular,
      'saldoLivre': saldoLivre,
      'saldoTotal': saldoTotal,
      'unidade': unidade,
      'criadoEm': criadoEm?.toIso8601String(),
    };
  }

  factory DofItemModel.fromXmlElement(Map<String, dynamic> xmlData) {
    return DofItemModel(
      id: xmlData['id'] as String? ?? '',
      numero: xmlData['numero'] as String? ?? '',
      produto: xmlData['produto'] as String? ?? '',
      especieCientifico: xmlData['especieCientifico'] as String? ?? '',
      nomePopular: xmlData['nomePopular'] as String? ?? '',
      saldoLivre: _parseDouble(xmlData['saldoLivre']),
      saldoTotal: _parseDouble(xmlData['saldoTotal']),
      unidade: xmlData['unidade'] as String? ?? 'm³',
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value.replaceAll(',', '.')) ?? 0.0;
    }
    return 0.0;
  }

  DofItemModel copyWith({
    String? id,
    String? numero,
    String? produto,
    String? especieCientifico,
    String? nomePopular,
    double? saldoLivre,
    double? saldoTotal,
    String? unidade,
    DateTime? criadoEm,
  }) {
    return DofItemModel(
      id: id ?? this.id,
      numero: numero ?? this.numero,
      produto: produto ?? this.produto,
      especieCientifico: especieCientifico ?? this.especieCientifico,
      nomePopular: nomePopular ?? this.nomePopular,
      saldoLivre: saldoLivre ?? this.saldoLivre,
      saldoTotal: saldoTotal ?? this.saldoTotal,
      unidade: unidade ?? this.unidade,
      criadoEm: criadoEm ?? this.criadoEm,
    );
  }
}
