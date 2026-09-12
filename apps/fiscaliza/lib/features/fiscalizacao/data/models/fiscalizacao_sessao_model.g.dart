// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fiscalizacao_sessao_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetFiscalizacaoSessaoModelCollection on Isar {
  IsarCollection<FiscalizacaoSessaoModel> get fiscalizacaoSessaoModels =>
      this.collection();
}

const FiscalizacaoSessaoModelSchema = CollectionSchema(
  name: r'FiscalizacaoSessaoModel',
  id: 2653236339081060015,
  properties: {
    r'ativa': PropertySchema(
      id: 0,
      name: r'ativa',
      type: IsarType.bool,
    ),
    r'concluidaEm': PropertySchema(
      id: 1,
      name: r'concluidaEm',
      type: IsarType.dateTime,
    ),
    r'id': PropertySchema(
      id: 2,
      name: r'id',
      type: IsarType.string,
    ),
    r'iniciadaEm': PropertySchema(
      id: 3,
      name: r'iniciadaEm',
      type: IsarType.dateTime,
    ),
    r'itensConcluidosSnapshot': PropertySchema(
      id: 4,
      name: r'itensConcluidosSnapshot',
      type: IsarType.long,
    ),
    r'itensExcedentesSnapshot': PropertySchema(
      id: 5,
      name: r'itensExcedentesSnapshot',
      type: IsarType.long,
    ),
    r'itensPendentesSnapshot': PropertySchema(
      id: 6,
      name: r'itensPendentesSnapshot',
      type: IsarType.long,
    ),
    r'itensTotalSnapshot': PropertySchema(
      id: 7,
      name: r'itensTotalSnapshot',
      type: IsarType.long,
    ),
    r'madeireiraNome': PropertySchema(
      id: 8,
      name: r'madeireiraNome',
      type: IsarType.string,
    ),
    r'volumeTotalSnapshot': PropertySchema(
      id: 9,
      name: r'volumeTotalSnapshot',
      type: IsarType.double,
    )
  },
  estimateSize: _fiscalizacaoSessaoModelEstimateSize,
  serialize: _fiscalizacaoSessaoModelSerialize,
  deserialize: _fiscalizacaoSessaoModelDeserialize,
  deserializeProp: _fiscalizacaoSessaoModelDeserializeProp,
  idName: r'isarId',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _fiscalizacaoSessaoModelGetId,
  getLinks: _fiscalizacaoSessaoModelGetLinks,
  attach: _fiscalizacaoSessaoModelAttach,
  version: '3.1.0+1',
);

int _fiscalizacaoSessaoModelEstimateSize(
  FiscalizacaoSessaoModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.id.length * 3;
  bytesCount += 3 + object.madeireiraNome.length * 3;
  return bytesCount;
}

void _fiscalizacaoSessaoModelSerialize(
  FiscalizacaoSessaoModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.ativa);
  writer.writeDateTime(offsets[1], object.concluidaEm);
  writer.writeString(offsets[2], object.id);
  writer.writeDateTime(offsets[3], object.iniciadaEm);
  writer.writeLong(offsets[4], object.itensConcluidosSnapshot);
  writer.writeLong(offsets[5], object.itensExcedentesSnapshot);
  writer.writeLong(offsets[6], object.itensPendentesSnapshot);
  writer.writeLong(offsets[7], object.itensTotalSnapshot);
  writer.writeString(offsets[8], object.madeireiraNome);
  writer.writeDouble(offsets[9], object.volumeTotalSnapshot);
}

FiscalizacaoSessaoModel _fiscalizacaoSessaoModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = FiscalizacaoSessaoModel(
    ativa: reader.readBoolOrNull(offsets[0]) ?? true,
    concluidaEm: reader.readDateTimeOrNull(offsets[1]),
    id: reader.readString(offsets[2]),
    iniciadaEm: reader.readDateTime(offsets[3]),
    itensConcluidosSnapshot: reader.readLongOrNull(offsets[4]),
    itensExcedentesSnapshot: reader.readLongOrNull(offsets[5]),
    itensPendentesSnapshot: reader.readLongOrNull(offsets[6]),
    itensTotalSnapshot: reader.readLongOrNull(offsets[7]),
    madeireiraNome: reader.readString(offsets[8]),
    volumeTotalSnapshot: reader.readDoubleOrNull(offsets[9]),
  );
  object.isarId = id;
  return object;
}

P _fiscalizacaoSessaoModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBoolOrNull(offset) ?? true) as P;
    case 1:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readDateTime(offset)) as P;
    case 4:
      return (reader.readLongOrNull(offset)) as P;
    case 5:
      return (reader.readLongOrNull(offset)) as P;
    case 6:
      return (reader.readLongOrNull(offset)) as P;
    case 7:
      return (reader.readLongOrNull(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readDoubleOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _fiscalizacaoSessaoModelGetId(FiscalizacaoSessaoModel object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _fiscalizacaoSessaoModelGetLinks(
    FiscalizacaoSessaoModel object) {
  return [];
}

void _fiscalizacaoSessaoModelAttach(
    IsarCollection<dynamic> col, Id id, FiscalizacaoSessaoModel object) {
  object.isarId = id;
}

extension FiscalizacaoSessaoModelQueryWhereSort
    on QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel, QWhere> {
  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel, QAfterWhere>
      anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension FiscalizacaoSessaoModelQueryWhere on QueryBuilder<
    FiscalizacaoSessaoModel, FiscalizacaoSessaoModel, QWhereClause> {
  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel,
      QAfterWhereClause> isarIdEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: isarId,
        upper: isarId,
      ));
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel,
      QAfterWhereClause> isarIdNotEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel,
      QAfterWhereClause> isarIdGreaterThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel,
      QAfterWhereClause> isarIdLessThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel,
      QAfterWhereClause> isarIdBetween(
    Id lowerIsarId,
    Id upperIsarId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerIsarId,
        includeLower: includeLower,
        upper: upperIsarId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension FiscalizacaoSessaoModelQueryFilter on QueryBuilder<
    FiscalizacaoSessaoModel, FiscalizacaoSessaoModel, QFilterCondition> {
  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel,
      QAfterFilterCondition> ativaEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ativa',
        value: value,
      ));
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel,
      QAfterFilterCondition> concluidaEmIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'concluidaEm',
      ));
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel,
      QAfterFilterCondition> concluidaEmIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'concluidaEm',
      ));
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel,
      QAfterFilterCondition> concluidaEmEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'concluidaEm',
        value: value,
      ));
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel,
      QAfterFilterCondition> concluidaEmGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'concluidaEm',
        value: value,
      ));
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel,
      QAfterFilterCondition> concluidaEmLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'concluidaEm',
        value: value,
      ));
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel,
      QAfterFilterCondition> concluidaEmBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'concluidaEm',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel,
      QAfterFilterCondition> idEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel,
      QAfterFilterCondition> idGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel,
      QAfterFilterCondition> idLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel,
      QAfterFilterCondition> idBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel,
      QAfterFilterCondition> idStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel,
      QAfterFilterCondition> idEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel,
          QAfterFilterCondition>
      idContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel,
          QAfterFilterCondition>
      idMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'id',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel,
      QAfterFilterCondition> idIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel,
      QAfterFilterCondition> idIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel,
      QAfterFilterCondition> iniciadaEmEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'iniciadaEm',
        value: value,
      ));
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel,
      QAfterFilterCondition> iniciadaEmGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'iniciadaEm',
        value: value,
      ));
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel,
      QAfterFilterCondition> iniciadaEmLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'iniciadaEm',
        value: value,
      ));
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel,
      QAfterFilterCondition> iniciadaEmBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'iniciadaEm',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel,
      QAfterFilterCondition> isarIdEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel,
      QAfterFilterCondition> isarIdGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel,
      QAfterFilterCondition> isarIdLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel,
      QAfterFilterCondition> isarIdBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'isarId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel,
      QAfterFilterCondition> itensConcluidosSnapshotIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'itensConcluidosSnapshot',
      ));
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel,
      QAfterFilterCondition> itensConcluidosSnapshotIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'itensConcluidosSnapshot',
      ));
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel,
      QAfterFilterCondition> itensConcluidosSnapshotEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'itensConcluidosSnapshot',
        value: value,
      ));
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel,
      QAfterFilterCondition> itensConcluidosSnapshotGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'itensConcluidosSnapshot',
        value: value,
      ));
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel,
      QAfterFilterCondition> itensConcluidosSnapshotLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'itensConcluidosSnapshot',
        value: value,
      ));
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel,
      QAfterFilterCondition> itensConcluidosSnapshotBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'itensConcluidosSnapshot',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel,
      QAfterFilterCondition> itensExcedentesSnapshotIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'itensExcedentesSnapshot',
      ));
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel,
      QAfterFilterCondition> itensExcedentesSnapshotIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'itensExcedentesSnapshot',
      ));
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel,
      QAfterFilterCondition> itensExcedentesSnapshotEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'itensExcedentesSnapshot',
        value: value,
      ));
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel,
      QAfterFilterCondition> itensExcedentesSnapshotGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'itensExcedentesSnapshot',
        value: value,
      ));
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel,
      QAfterFilterCondition> itensExcedentesSnapshotLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'itensExcedentesSnapshot',
        value: value,
      ));
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel,
      QAfterFilterCondition> itensExcedentesSnapshotBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'itensExcedentesSnapshot',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel,
      QAfterFilterCondition> itensPendentesSnapshotIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'itensPendentesSnapshot',
      ));
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel,
      QAfterFilterCondition> itensPendentesSnapshotIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'itensPendentesSnapshot',
      ));
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel,
      QAfterFilterCondition> itensPendentesSnapshotEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'itensPendentesSnapshot',
        value: value,
      ));
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel,
      QAfterFilterCondition> itensPendentesSnapshotGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'itensPendentesSnapshot',
        value: value,
      ));
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel,
      QAfterFilterCondition> itensPendentesSnapshotLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'itensPendentesSnapshot',
        value: value,
      ));
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel,
      QAfterFilterCondition> itensPendentesSnapshotBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'itensPendentesSnapshot',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel,
      QAfterFilterCondition> itensTotalSnapshotIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'itensTotalSnapshot',
      ));
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel,
      QAfterFilterCondition> itensTotalSnapshotIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'itensTotalSnapshot',
      ));
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel,
      QAfterFilterCondition> itensTotalSnapshotEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'itensTotalSnapshot',
        value: value,
      ));
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel,
      QAfterFilterCondition> itensTotalSnapshotGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'itensTotalSnapshot',
        value: value,
      ));
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel,
      QAfterFilterCondition> itensTotalSnapshotLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'itensTotalSnapshot',
        value: value,
      ));
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel,
      QAfterFilterCondition> itensTotalSnapshotBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'itensTotalSnapshot',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel,
      QAfterFilterCondition> madeireiraNomeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'madeireiraNome',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel,
      QAfterFilterCondition> madeireiraNomeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'madeireiraNome',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel,
      QAfterFilterCondition> madeireiraNomeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'madeireiraNome',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel,
      QAfterFilterCondition> madeireiraNomeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'madeireiraNome',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel,
      QAfterFilterCondition> madeireiraNomeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'madeireiraNome',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel,
      QAfterFilterCondition> madeireiraNomeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'madeireiraNome',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel,
          QAfterFilterCondition>
      madeireiraNomeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'madeireiraNome',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel,
          QAfterFilterCondition>
      madeireiraNomeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'madeireiraNome',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel,
      QAfterFilterCondition> madeireiraNomeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'madeireiraNome',
        value: '',
      ));
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel,
      QAfterFilterCondition> madeireiraNomeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'madeireiraNome',
        value: '',
      ));
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel,
      QAfterFilterCondition> volumeTotalSnapshotIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'volumeTotalSnapshot',
      ));
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel,
      QAfterFilterCondition> volumeTotalSnapshotIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'volumeTotalSnapshot',
      ));
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel,
      QAfterFilterCondition> volumeTotalSnapshotEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'volumeTotalSnapshot',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel,
      QAfterFilterCondition> volumeTotalSnapshotGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'volumeTotalSnapshot',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel,
      QAfterFilterCondition> volumeTotalSnapshotLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'volumeTotalSnapshot',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel,
      QAfterFilterCondition> volumeTotalSnapshotBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'volumeTotalSnapshot',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }
}

extension FiscalizacaoSessaoModelQueryObject on QueryBuilder<
    FiscalizacaoSessaoModel, FiscalizacaoSessaoModel, QFilterCondition> {}

extension FiscalizacaoSessaoModelQueryLinks on QueryBuilder<
    FiscalizacaoSessaoModel, FiscalizacaoSessaoModel, QFilterCondition> {}

extension FiscalizacaoSessaoModelQuerySortBy
    on QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel, QSortBy> {
  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel, QAfterSortBy>
      sortByAtiva() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ativa', Sort.asc);
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel, QAfterSortBy>
      sortByAtivaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ativa', Sort.desc);
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel, QAfterSortBy>
      sortByConcluidaEm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'concluidaEm', Sort.asc);
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel, QAfterSortBy>
      sortByConcluidaEmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'concluidaEm', Sort.desc);
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel, QAfterSortBy>
      sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel, QAfterSortBy>
      sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel, QAfterSortBy>
      sortByIniciadaEm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'iniciadaEm', Sort.asc);
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel, QAfterSortBy>
      sortByIniciadaEmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'iniciadaEm', Sort.desc);
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel, QAfterSortBy>
      sortByItensConcluidosSnapshot() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itensConcluidosSnapshot', Sort.asc);
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel, QAfterSortBy>
      sortByItensConcluidosSnapshotDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itensConcluidosSnapshot', Sort.desc);
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel, QAfterSortBy>
      sortByItensExcedentesSnapshot() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itensExcedentesSnapshot', Sort.asc);
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel, QAfterSortBy>
      sortByItensExcedentesSnapshotDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itensExcedentesSnapshot', Sort.desc);
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel, QAfterSortBy>
      sortByItensPendentesSnapshot() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itensPendentesSnapshot', Sort.asc);
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel, QAfterSortBy>
      sortByItensPendentesSnapshotDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itensPendentesSnapshot', Sort.desc);
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel, QAfterSortBy>
      sortByItensTotalSnapshot() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itensTotalSnapshot', Sort.asc);
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel, QAfterSortBy>
      sortByItensTotalSnapshotDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itensTotalSnapshot', Sort.desc);
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel, QAfterSortBy>
      sortByMadeireiraNome() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'madeireiraNome', Sort.asc);
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel, QAfterSortBy>
      sortByMadeireiraNomeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'madeireiraNome', Sort.desc);
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel, QAfterSortBy>
      sortByVolumeTotalSnapshot() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'volumeTotalSnapshot', Sort.asc);
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel, QAfterSortBy>
      sortByVolumeTotalSnapshotDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'volumeTotalSnapshot', Sort.desc);
    });
  }
}

extension FiscalizacaoSessaoModelQuerySortThenBy on QueryBuilder<
    FiscalizacaoSessaoModel, FiscalizacaoSessaoModel, QSortThenBy> {
  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel, QAfterSortBy>
      thenByAtiva() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ativa', Sort.asc);
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel, QAfterSortBy>
      thenByAtivaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ativa', Sort.desc);
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel, QAfterSortBy>
      thenByConcluidaEm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'concluidaEm', Sort.asc);
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel, QAfterSortBy>
      thenByConcluidaEmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'concluidaEm', Sort.desc);
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel, QAfterSortBy>
      thenByIniciadaEm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'iniciadaEm', Sort.asc);
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel, QAfterSortBy>
      thenByIniciadaEmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'iniciadaEm', Sort.desc);
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel, QAfterSortBy>
      thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel, QAfterSortBy>
      thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel, QAfterSortBy>
      thenByItensConcluidosSnapshot() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itensConcluidosSnapshot', Sort.asc);
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel, QAfterSortBy>
      thenByItensConcluidosSnapshotDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itensConcluidosSnapshot', Sort.desc);
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel, QAfterSortBy>
      thenByItensExcedentesSnapshot() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itensExcedentesSnapshot', Sort.asc);
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel, QAfterSortBy>
      thenByItensExcedentesSnapshotDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itensExcedentesSnapshot', Sort.desc);
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel, QAfterSortBy>
      thenByItensPendentesSnapshot() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itensPendentesSnapshot', Sort.asc);
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel, QAfterSortBy>
      thenByItensPendentesSnapshotDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itensPendentesSnapshot', Sort.desc);
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel, QAfterSortBy>
      thenByItensTotalSnapshot() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itensTotalSnapshot', Sort.asc);
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel, QAfterSortBy>
      thenByItensTotalSnapshotDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itensTotalSnapshot', Sort.desc);
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel, QAfterSortBy>
      thenByMadeireiraNome() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'madeireiraNome', Sort.asc);
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel, QAfterSortBy>
      thenByMadeireiraNomeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'madeireiraNome', Sort.desc);
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel, QAfterSortBy>
      thenByVolumeTotalSnapshot() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'volumeTotalSnapshot', Sort.asc);
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel, QAfterSortBy>
      thenByVolumeTotalSnapshotDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'volumeTotalSnapshot', Sort.desc);
    });
  }
}

extension FiscalizacaoSessaoModelQueryWhereDistinct on QueryBuilder<
    FiscalizacaoSessaoModel, FiscalizacaoSessaoModel, QDistinct> {
  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel, QDistinct>
      distinctByAtiva() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ativa');
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel, QDistinct>
      distinctByConcluidaEm() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'concluidaEm');
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel, QDistinct>
      distinctById({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'id', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel, QDistinct>
      distinctByIniciadaEm() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'iniciadaEm');
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel, QDistinct>
      distinctByItensConcluidosSnapshot() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'itensConcluidosSnapshot');
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel, QDistinct>
      distinctByItensExcedentesSnapshot() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'itensExcedentesSnapshot');
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel, QDistinct>
      distinctByItensPendentesSnapshot() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'itensPendentesSnapshot');
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel, QDistinct>
      distinctByItensTotalSnapshot() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'itensTotalSnapshot');
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel, QDistinct>
      distinctByMadeireiraNome({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'madeireiraNome',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, FiscalizacaoSessaoModel, QDistinct>
      distinctByVolumeTotalSnapshot() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'volumeTotalSnapshot');
    });
  }
}

extension FiscalizacaoSessaoModelQueryProperty on QueryBuilder<
    FiscalizacaoSessaoModel, FiscalizacaoSessaoModel, QQueryProperty> {
  QueryBuilder<FiscalizacaoSessaoModel, int, QQueryOperations>
      isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, bool, QQueryOperations>
      ativaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ativa');
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, DateTime?, QQueryOperations>
      concluidaEmProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'concluidaEm');
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, String, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, DateTime, QQueryOperations>
      iniciadaEmProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'iniciadaEm');
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, int?, QQueryOperations>
      itensConcluidosSnapshotProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'itensConcluidosSnapshot');
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, int?, QQueryOperations>
      itensExcedentesSnapshotProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'itensExcedentesSnapshot');
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, int?, QQueryOperations>
      itensPendentesSnapshotProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'itensPendentesSnapshot');
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, int?, QQueryOperations>
      itensTotalSnapshotProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'itensTotalSnapshot');
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, String, QQueryOperations>
      madeireiraNomeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'madeireiraNome');
    });
  }

  QueryBuilder<FiscalizacaoSessaoModel, double?, QQueryOperations>
      volumeTotalSnapshotProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'volumeTotalSnapshot');
    });
  }
}
