import 'package:isar/isar.dart';
import 'package:fiscaliza/features/dof/domain/entities/dof_item.dart';

part 'dof_item_model.g.dart';

@Collection()
class DofItemModel implements DofItem {
  Id isarId = Isar.autoIncrement;

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

  /// Vincula o item ao lote de fiscalização em que foi importado.
  String sessaoId;

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
    this.sessaoId = '',
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
      sessaoId: json['sessaoId'] as String? ?? '',
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
      'sessaoId': sessaoId,
    };
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
    String? sessaoId,
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
      sessaoId: sessaoId ?? this.sessaoId,
    );
  }
}
