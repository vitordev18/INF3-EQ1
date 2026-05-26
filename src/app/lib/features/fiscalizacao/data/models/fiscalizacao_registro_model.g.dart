// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fiscalizacao_registro_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetFiscalizacaoRegistroModelCollection on Isar {
  IsarCollection<FiscalizacaoRegistroModel> get fiscalizacaoRegistroModels =>
      this.collection();
}

const FiscalizacaoRegistroModelSchema = CollectionSchema(
  name: r'FiscalizacaoRegistroModel',
  id: 4932112321466110376,
  properties: {
    r'contagemTotal': PropertySchema(
      id: 0,
      name: r'contagemTotal',
      type: IsarType.long,
    ),
    r'dataCaptura': PropertySchema(
      id: 1,
      name: r'dataCaptura',
      type: IsarType.dateTime,
    ),
    r'detecoesPorFoto': PropertySchema(
      id: 2,
      name: r'detecoesPorFoto',
      type: IsarType.stringList,
    ),
    r'dofItemId': PropertySchema(
      id: 3,
      name: r'dofItemId',
      type: IsarType.string,
    ),
    r'fotoPaths': PropertySchema(
      id: 4,
      name: r'fotoPaths',
      type: IsarType.stringList,
    ),
    r'id': PropertySchema(
      id: 5,
      name: r'id',
      type: IsarType.string,
    ),
    r'status': PropertySchema(
      id: 6,
      name: r'status',
      type: IsarType.byte,
      enumMap: _FiscalizacaoRegistroModelstatusEnumValueMap,
    )
  },
  estimateSize: _fiscalizacaoRegistroModelEstimateSize,
  serialize: _fiscalizacaoRegistroModelSerialize,
  deserialize: _fiscalizacaoRegistroModelDeserialize,
  deserializeProp: _fiscalizacaoRegistroModelDeserializeProp,
  idName: r'isarId',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _fiscalizacaoRegistroModelGetId,
  getLinks: _fiscalizacaoRegistroModelGetLinks,
  attach: _fiscalizacaoRegistroModelAttach,
  version: '3.1.0+1',
);

int _fiscalizacaoRegistroModelEstimateSize(
  FiscalizacaoRegistroModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.detecoesPorFoto.length * 3;
  {
    for (var i = 0; i < object.detecoesPorFoto.length; i++) {
      final value = object.detecoesPorFoto[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.dofItemId.length * 3;
  bytesCount += 3 + object.fotoPaths.length * 3;
  {
    for (var i = 0; i < object.fotoPaths.length; i++) {
      final value = object.fotoPaths[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.id.length * 3;
  return bytesCount;
}

void _fiscalizacaoRegistroModelSerialize(
  FiscalizacaoRegistroModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.contagemTotal);
  writer.writeDateTime(offsets[1], object.dataCaptura);
  writer.writeStringList(offsets[2], object.detecoesPorFoto);
  writer.writeString(offsets[3], object.dofItemId);
  writer.writeStringList(offsets[4], object.fotoPaths);
  writer.writeString(offsets[5], object.id);
  writer.writeByte(offsets[6], object.status.index);
}

FiscalizacaoRegistroModel _fiscalizacaoRegistroModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = FiscalizacaoRegistroModel(
    contagemTotal: reader.readLong(offsets[0]),
    dataCaptura: reader.readDateTime(offsets[1]),
    detecoesPorFoto: reader.readStringList(offsets[2]) ?? const [],
    dofItemId: reader.readString(offsets[3]),
    fotoPaths: reader.readStringList(offsets[4]) ?? [],
    id: reader.readString(offsets[5]),
    status: _FiscalizacaoRegistroModelstatusValueEnumMap[
            reader.readByteOrNull(offsets[6])] ??
        StatusFiscalizacao.pendente,
  );
  object.isarId = id;
  return object;
}

P _fiscalizacaoRegistroModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readStringList(offset) ?? const []) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readStringList(offset) ?? []) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (_FiscalizacaoRegistroModelstatusValueEnumMap[
              reader.readByteOrNull(offset)] ??
          StatusFiscalizacao.pendente) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _FiscalizacaoRegistroModelstatusEnumValueMap = {
  'pendente': 0,
  'emAndamento': 1,
  'concluido': 2,
  'excedente': 3,
};
const _FiscalizacaoRegistroModelstatusValueEnumMap = {
  0: StatusFiscalizacao.pendente,
  1: StatusFiscalizacao.emAndamento,
  2: StatusFiscalizacao.concluido,
  3: StatusFiscalizacao.excedente,
};

Id _fiscalizacaoRegistroModelGetId(FiscalizacaoRegistroModel object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _fiscalizacaoRegistroModelGetLinks(
    FiscalizacaoRegistroModel object) {
  return [];
}

void _fiscalizacaoRegistroModelAttach(
    IsarCollection<dynamic> col, Id id, FiscalizacaoRegistroModel object) {
  object.isarId = id;
}

extension FiscalizacaoRegistroModelQueryWhereSort on QueryBuilder<
    FiscalizacaoRegistroModel, FiscalizacaoRegistroModel, QWhere> {
  QueryBuilder<FiscalizacaoRegistroModel, FiscalizacaoRegistroModel,
      QAfterWhere> anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension FiscalizacaoRegistroModelQueryWhere on QueryBuilder<
    FiscalizacaoRegistroModel, FiscalizacaoRegistroModel, QWhereClause> {
  QueryBuilder<FiscalizacaoRegistroModel, FiscalizacaoRegistroModel,
      QAfterWhereClause> isarIdEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: isarId,
        upper: isarId,
      ));
    });
  }

  QueryBuilder<FiscalizacaoRegistroModel, FiscalizacaoRegistroModel,
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

  QueryBuilder<FiscalizacaoRegistroModel, FiscalizacaoRegistroModel,
      QAfterWhereClause> isarIdGreaterThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<FiscalizacaoRegistroModel, FiscalizacaoRegistroModel,
      QAfterWhereClause> isarIdLessThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<FiscalizacaoRegistroModel, FiscalizacaoRegistroModel,
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

extension FiscalizacaoRegistroModelQueryFilter on QueryBuilder<
    FiscalizacaoRegistroModel, FiscalizacaoRegistroModel, QFilterCondition> {
  QueryBuilder<FiscalizacaoRegistroModel, FiscalizacaoRegistroModel,
      QAfterFilterCondition> contagemTotalEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'contagemTotal',
        value: value,
      ));
    });
  }

  QueryBuilder<FiscalizacaoRegistroModel, FiscalizacaoRegistroModel,
      QAfterFilterCondition> contagemTotalGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'contagemTotal',
        value: value,
      ));
    });
  }

  QueryBuilder<FiscalizacaoRegistroModel, FiscalizacaoRegistroModel,
      QAfterFilterCondition> contagemTotalLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'contagemTotal',
        value: value,
      ));
    });
  }

  QueryBuilder<FiscalizacaoRegistroModel, FiscalizacaoRegistroModel,
      QAfterFilterCondition> contagemTotalBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'contagemTotal',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FiscalizacaoRegistroModel, FiscalizacaoRegistroModel,
      QAfterFilterCondition> dataCapturaEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dataCaptura',
        value: value,
      ));
    });
  }

  QueryBuilder<FiscalizacaoRegistroModel, FiscalizacaoRegistroModel,
      QAfterFilterCondition> dataCapturaGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dataCaptura',
        value: value,
      ));
    });
  }

  QueryBuilder<FiscalizacaoRegistroModel, FiscalizacaoRegistroModel,
      QAfterFilterCondition> dataCapturaLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dataCaptura',
        value: value,
      ));
    });
  }

  QueryBuilder<FiscalizacaoRegistroModel, FiscalizacaoRegistroModel,
      QAfterFilterCondition> dataCapturaBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dataCaptura',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FiscalizacaoRegistroModel, FiscalizacaoRegistroModel,
      QAfterFilterCondition> detecoesPorFotoElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'detecoesPorFoto',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FiscalizacaoRegistroModel, FiscalizacaoRegistroModel,
      QAfterFilterCondition> detecoesPorFotoElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'detecoesPorFoto',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FiscalizacaoRegistroModel, FiscalizacaoRegistroModel,
      QAfterFilterCondition> detecoesPorFotoElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'detecoesPorFoto',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FiscalizacaoRegistroModel, FiscalizacaoRegistroModel,
      QAfterFilterCondition> detecoesPorFotoElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'detecoesPorFoto',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FiscalizacaoRegistroModel, FiscalizacaoRegistroModel,
      QAfterFilterCondition> detecoesPorFotoElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'detecoesPorFoto',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FiscalizacaoRegistroModel, FiscalizacaoRegistroModel,
      QAfterFilterCondition> detecoesPorFotoElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'detecoesPorFoto',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FiscalizacaoRegistroModel, FiscalizacaoRegistroModel,
          QAfterFilterCondition>
      detecoesPorFotoElementContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'detecoesPorFoto',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FiscalizacaoRegistroModel, FiscalizacaoRegistroModel,
          QAfterFilterCondition>
      detecoesPorFotoElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'detecoesPorFoto',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FiscalizacaoRegistroModel, FiscalizacaoRegistroModel,
      QAfterFilterCondition> detecoesPorFotoElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'detecoesPorFoto',
        value: '',
      ));
    });
  }

  QueryBuilder<FiscalizacaoRegistroModel, FiscalizacaoRegistroModel,
      QAfterFilterCondition> detecoesPorFotoElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'detecoesPorFoto',
        value: '',
      ));
    });
  }

  QueryBuilder<FiscalizacaoRegistroModel, FiscalizacaoRegistroModel,
      QAfterFilterCondition> detecoesPorFotoLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'detecoesPorFoto',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<FiscalizacaoRegistroModel, FiscalizacaoRegistroModel,
      QAfterFilterCondition> detecoesPorFotoIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'detecoesPorFoto',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<FiscalizacaoRegistroModel, FiscalizacaoRegistroModel,
      QAfterFilterCondition> detecoesPorFotoIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'detecoesPorFoto',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<FiscalizacaoRegistroModel, FiscalizacaoRegistroModel,
      QAfterFilterCondition> detecoesPorFotoLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'detecoesPorFoto',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<FiscalizacaoRegistroModel, FiscalizacaoRegistroModel,
      QAfterFilterCondition> detecoesPorFotoLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'detecoesPorFoto',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<FiscalizacaoRegistroModel, FiscalizacaoRegistroModel,
      QAfterFilterCondition> detecoesPorFotoLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'detecoesPorFoto',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<FiscalizacaoRegistroModel, FiscalizacaoRegistroModel,
      QAfterFilterCondition> dofItemIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dofItemId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FiscalizacaoRegistroModel, FiscalizacaoRegistroModel,
      QAfterFilterCondition> dofItemIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dofItemId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FiscalizacaoRegistroModel, FiscalizacaoRegistroModel,
      QAfterFilterCondition> dofItemIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dofItemId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FiscalizacaoRegistroModel, FiscalizacaoRegistroModel,
      QAfterFilterCondition> dofItemIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dofItemId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FiscalizacaoRegistroModel, FiscalizacaoRegistroModel,
      QAfterFilterCondition> dofItemIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'dofItemId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FiscalizacaoRegistroModel, FiscalizacaoRegistroModel,
      QAfterFilterCondition> dofItemIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'dofItemId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FiscalizacaoRegistroModel, FiscalizacaoRegistroModel,
          QAfterFilterCondition>
      dofItemIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'dofItemId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FiscalizacaoRegistroModel, FiscalizacaoRegistroModel,
          QAfterFilterCondition>
      dofItemIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'dofItemId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FiscalizacaoRegistroModel, FiscalizacaoRegistroModel,
      QAfterFilterCondition> dofItemIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dofItemId',
        value: '',
      ));
    });
  }

  QueryBuilder<FiscalizacaoRegistroModel, FiscalizacaoRegistroModel,
      QAfterFilterCondition> dofItemIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'dofItemId',
        value: '',
      ));
    });
  }

  QueryBuilder<FiscalizacaoRegistroModel, FiscalizacaoRegistroModel,
      QAfterFilterCondition> fotoPathsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fotoPaths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FiscalizacaoRegistroModel, FiscalizacaoRegistroModel,
      QAfterFilterCondition> fotoPathsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fotoPaths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FiscalizacaoRegistroModel, FiscalizacaoRegistroModel,
      QAfterFilterCondition> fotoPathsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fotoPaths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FiscalizacaoRegistroModel, FiscalizacaoRegistroModel,
      QAfterFilterCondition> fotoPathsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fotoPaths',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FiscalizacaoRegistroModel, FiscalizacaoRegistroModel,
      QAfterFilterCondition> fotoPathsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'fotoPaths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FiscalizacaoRegistroModel, FiscalizacaoRegistroModel,
      QAfterFilterCondition> fotoPathsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'fotoPaths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FiscalizacaoRegistroModel, FiscalizacaoRegistroModel,
          QAfterFilterCondition>
      fotoPathsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'fotoPaths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FiscalizacaoRegistroModel, FiscalizacaoRegistroModel,
          QAfterFilterCondition>
      fotoPathsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'fotoPaths',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FiscalizacaoRegistroModel, FiscalizacaoRegistroModel,
      QAfterFilterCondition> fotoPathsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fotoPaths',
        value: '',
      ));
    });
  }

  QueryBuilder<FiscalizacaoRegistroModel, FiscalizacaoRegistroModel,
      QAfterFilterCondition> fotoPathsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'fotoPaths',
        value: '',
      ));
    });
  }

  QueryBuilder<FiscalizacaoRegistroModel, FiscalizacaoRegistroModel,
      QAfterFilterCondition> fotoPathsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'fotoPaths',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<FiscalizacaoRegistroModel, FiscalizacaoRegistroModel,
      QAfterFilterCondition> fotoPathsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'fotoPaths',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<FiscalizacaoRegistroModel, FiscalizacaoRegistroModel,
      QAfterFilterCondition> fotoPathsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'fotoPaths',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<FiscalizacaoRegistroModel, FiscalizacaoRegistroModel,
      QAfterFilterCondition> fotoPathsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'fotoPaths',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<FiscalizacaoRegistroModel, FiscalizacaoRegistroModel,
      QAfterFilterCondition> fotoPathsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'fotoPaths',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<FiscalizacaoRegistroModel, FiscalizacaoRegistroModel,
      QAfterFilterCondition> fotoPathsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'fotoPaths',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<FiscalizacaoRegistroModel, FiscalizacaoRegistroModel,
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

  QueryBuilder<FiscalizacaoRegistroModel, FiscalizacaoRegistroModel,
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

  QueryBuilder<FiscalizacaoRegistroModel, FiscalizacaoRegistroModel,
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

  QueryBuilder<FiscalizacaoRegistroModel, FiscalizacaoRegistroModel,
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

  QueryBuilder<FiscalizacaoRegistroModel, FiscalizacaoRegistroModel,
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

  QueryBuilder<FiscalizacaoRegistroModel, FiscalizacaoRegistroModel,
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

  QueryBuilder<FiscalizacaoRegistroModel, FiscalizacaoRegistroModel,
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

  QueryBuilder<FiscalizacaoRegistroModel, FiscalizacaoRegistroModel,
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

  QueryBuilder<FiscalizacaoRegistroModel, FiscalizacaoRegistroModel,
      QAfterFilterCondition> idIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<FiscalizacaoRegistroModel, FiscalizacaoRegistroModel,
      QAfterFilterCondition> idIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<FiscalizacaoRegistroModel, FiscalizacaoRegistroModel,
      QAfterFilterCondition> isarIdEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<FiscalizacaoRegistroModel, FiscalizacaoRegistroModel,
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

  QueryBuilder<FiscalizacaoRegistroModel, FiscalizacaoRegistroModel,
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

  QueryBuilder<FiscalizacaoRegistroModel, FiscalizacaoRegistroModel,
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

  QueryBuilder<FiscalizacaoRegistroModel, FiscalizacaoRegistroModel,
      QAfterFilterCondition> statusEqualTo(StatusFiscalizacao value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: value,
      ));
    });
  }

  QueryBuilder<FiscalizacaoRegistroModel, FiscalizacaoRegistroModel,
      QAfterFilterCondition> statusGreaterThan(
    StatusFiscalizacao value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'status',
        value: value,
      ));
    });
  }

  QueryBuilder<FiscalizacaoRegistroModel, FiscalizacaoRegistroModel,
      QAfterFilterCondition> statusLessThan(
    StatusFiscalizacao value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'status',
        value: value,
      ));
    });
  }

  QueryBuilder<FiscalizacaoRegistroModel, FiscalizacaoRegistroModel,
      QAfterFilterCondition> statusBetween(
    StatusFiscalizacao lower,
    StatusFiscalizacao upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'status',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension FiscalizacaoRegistroModelQueryObject on QueryBuilder<
    FiscalizacaoRegistroModel, FiscalizacaoRegistroModel, QFilterCondition> {}

extension FiscalizacaoRegistroModelQueryLinks on QueryBuilder<
    FiscalizacaoRegistroModel, FiscalizacaoRegistroModel, QFilterCondition> {}

extension FiscalizacaoRegistroModelQuerySortBy on QueryBuilder<
    FiscalizacaoRegistroModel, FiscalizacaoRegistroModel, QSortBy> {
  QueryBuilder<FiscalizacaoRegistroModel, FiscalizacaoRegistroModel,
      QAfterSortBy> sortByContagemTotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contagemTotal', Sort.asc);
    });
  }

  QueryBuilder<FiscalizacaoRegistroModel, FiscalizacaoRegistroModel,
      QAfterSortBy> sortByContagemTotalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contagemTotal', Sort.desc);
    });
  }

  QueryBuilder<FiscalizacaoRegistroModel, FiscalizacaoRegistroModel,
      QAfterSortBy> sortByDataCaptura() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataCaptura', Sort.asc);
    });
  }

  QueryBuilder<FiscalizacaoRegistroModel, FiscalizacaoRegistroModel,
      QAfterSortBy> sortByDataCapturaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataCaptura', Sort.desc);
    });
  }

  QueryBuilder<FiscalizacaoRegistroModel, FiscalizacaoRegistroModel,
      QAfterSortBy> sortByDofItemId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dofItemId', Sort.asc);
    });
  }

  QueryBuilder<FiscalizacaoRegistroModel, FiscalizacaoRegistroModel,
      QAfterSortBy> sortByDofItemIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dofItemId', Sort.desc);
    });
  }

  QueryBuilder<FiscalizacaoRegistroModel, FiscalizacaoRegistroModel,
      QAfterSortBy> sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<FiscalizacaoRegistroModel, FiscalizacaoRegistroModel,
      QAfterSortBy> sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<FiscalizacaoRegistroModel, FiscalizacaoRegistroModel,
      QAfterSortBy> sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<FiscalizacaoRegistroModel, FiscalizacaoRegistroModel,
      QAfterSortBy> sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }
}

extension FiscalizacaoRegistroModelQuerySortThenBy on QueryBuilder<
    FiscalizacaoRegistroModel, FiscalizacaoRegistroModel, QSortThenBy> {
  QueryBuilder<FiscalizacaoRegistroModel, FiscalizacaoRegistroModel,
      QAfterSortBy> thenByContagemTotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contagemTotal', Sort.asc);
    });
  }

  QueryBuilder<FiscalizacaoRegistroModel, FiscalizacaoRegistroModel,
      QAfterSortBy> thenByContagemTotalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contagemTotal', Sort.desc);
    });
  }

  QueryBuilder<FiscalizacaoRegistroModel, FiscalizacaoRegistroModel,
      QAfterSortBy> thenByDataCaptura() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataCaptura', Sort.asc);
    });
  }

  QueryBuilder<FiscalizacaoRegistroModel, FiscalizacaoRegistroModel,
      QAfterSortBy> thenByDataCapturaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataCaptura', Sort.desc);
    });
  }

  QueryBuilder<FiscalizacaoRegistroModel, FiscalizacaoRegistroModel,
      QAfterSortBy> thenByDofItemId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dofItemId', Sort.asc);
    });
  }

  QueryBuilder<FiscalizacaoRegistroModel, FiscalizacaoRegistroModel,
      QAfterSortBy> thenByDofItemIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dofItemId', Sort.desc);
    });
  }

  QueryBuilder<FiscalizacaoRegistroModel, FiscalizacaoRegistroModel,
      QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<FiscalizacaoRegistroModel, FiscalizacaoRegistroModel,
      QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<FiscalizacaoRegistroModel, FiscalizacaoRegistroModel,
      QAfterSortBy> thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<FiscalizacaoRegistroModel, FiscalizacaoRegistroModel,
      QAfterSortBy> thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<FiscalizacaoRegistroModel, FiscalizacaoRegistroModel,
      QAfterSortBy> thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<FiscalizacaoRegistroModel, FiscalizacaoRegistroModel,
      QAfterSortBy> thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }
}

extension FiscalizacaoRegistroModelQueryWhereDistinct on QueryBuilder<
    FiscalizacaoRegistroModel, FiscalizacaoRegistroModel, QDistinct> {
  QueryBuilder<FiscalizacaoRegistroModel, FiscalizacaoRegistroModel, QDistinct>
      distinctByContagemTotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'contagemTotal');
    });
  }

  QueryBuilder<FiscalizacaoRegistroModel, FiscalizacaoRegistroModel, QDistinct>
      distinctByDataCaptura() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dataCaptura');
    });
  }

  QueryBuilder<FiscalizacaoRegistroModel, FiscalizacaoRegistroModel, QDistinct>
      distinctByDetecoesPorFoto() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'detecoesPorFoto');
    });
  }

  QueryBuilder<FiscalizacaoRegistroModel, FiscalizacaoRegistroModel, QDistinct>
      distinctByDofItemId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dofItemId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FiscalizacaoRegistroModel, FiscalizacaoRegistroModel, QDistinct>
      distinctByFotoPaths() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fotoPaths');
    });
  }

  QueryBuilder<FiscalizacaoRegistroModel, FiscalizacaoRegistroModel, QDistinct>
      distinctById({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'id', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FiscalizacaoRegistroModel, FiscalizacaoRegistroModel, QDistinct>
      distinctByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status');
    });
  }
}

extension FiscalizacaoRegistroModelQueryProperty on QueryBuilder<
    FiscalizacaoRegistroModel, FiscalizacaoRegistroModel, QQueryProperty> {
  QueryBuilder<FiscalizacaoRegistroModel, int, QQueryOperations>
      isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<FiscalizacaoRegistroModel, int, QQueryOperations>
      contagemTotalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'contagemTotal');
    });
  }

  QueryBuilder<FiscalizacaoRegistroModel, DateTime, QQueryOperations>
      dataCapturaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dataCaptura');
    });
  }

  QueryBuilder<FiscalizacaoRegistroModel, List<String>, QQueryOperations>
      detecoesPorFotoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'detecoesPorFoto');
    });
  }

  QueryBuilder<FiscalizacaoRegistroModel, String, QQueryOperations>
      dofItemIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dofItemId');
    });
  }

  QueryBuilder<FiscalizacaoRegistroModel, List<String>, QQueryOperations>
      fotoPathsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fotoPaths');
    });
  }

  QueryBuilder<FiscalizacaoRegistroModel, String, QQueryOperations>
      idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<FiscalizacaoRegistroModel, StatusFiscalizacao, QQueryOperations>
      statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }
}
