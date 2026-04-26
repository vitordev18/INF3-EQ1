import 'package:isar/isar.dart';
import 'package:app/features/dof/domain/entities/dof_item.dart';

part 'dof_item_model.g.dart';

@Collection()
class DofItemModel implements DofItem {
  // ID numérico obrigatório para o funcionamento interno do Isar
  Id isarId = Isar.autoIncrement;

  // Declaramos os campos com @override para respeitar o DofItem,
  // mas agora eles estão visíveis para o gerador do Isar!
  @override
  String id;

  @override
  String numero;

  @override
  String produto;

  @override
  String especieCientifico;

  @override
  String nomePopular;

  @override
  double saldoLivre;

  @override
  double saldoTotal;

  @override
  String unidade;

  @override
  DateTime? criadoEm;

  DofItemModel({
    required this.id,
    required this.numero,
    required this.produto,
    required this.especieCientifico,
    required this.nomePopular,
    required this.saldoLivre,
    required this.saldoTotal,
    required this.unidade,
    DateTime? criadoEm,
  }) : criadoEm = criadoEm ?? DateTime.now();

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
