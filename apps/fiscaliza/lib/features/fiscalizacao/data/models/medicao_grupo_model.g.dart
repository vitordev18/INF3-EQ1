// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medicao_grupo_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetMedicaoGrupoModelCollection on Isar {
  IsarCollection<MedicaoGrupoModel> get medicaoGrupoModels => this.collection();
}

const MedicaoGrupoModelSchema = CollectionSchema(
  name: r'MedicaoGrupoModel',
  id: -4020026485922423763,
  properties: {
    r'alturaCm': PropertySchema(
      id: 0,
      name: r'alturaCm',
      type: IsarType.double,
    ),
    r'comprimentoM': PropertySchema(
      id: 1,
      name: r'comprimentoM',
      type: IsarType.double,
    ),
    r'dofItemId': PropertySchema(
      id: 2,
      name: r'dofItemId',
      type: IsarType.string,
    ),
    r'fotoIndex': PropertySchema(
      id: 3,
      name: r'fotoIndex',
      type: IsarType.long,
    ),
    r'id': PropertySchema(
      id: 4,
      name: r'id',
      type: IsarType.string,
    ),
    r'isPrincipal': PropertySchema(
      id: 5,
      name: r'isPrincipal',
      type: IsarType.bool,
    ),
    r'larguraCm': PropertySchema(
      id: 6,
      name: r'larguraCm',
      type: IsarType.double,
    ),
    r'quantidade': PropertySchema(
      id: 7,
      name: r'quantidade',
      type: IsarType.long,
    )
  },
  estimateSize: _medicaoGrupoModelEstimateSize,
  serialize: _medicaoGrupoModelSerialize,
  deserialize: _medicaoGrupoModelDeserialize,
  deserializeProp: _medicaoGrupoModelDeserializeProp,
  idName: r'isarId',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _medicaoGrupoModelGetId,
  getLinks: _medicaoGrupoModelGetLinks,
  attach: _medicaoGrupoModelAttach,
  version: '3.1.0+1',
);

int _medicaoGrupoModelEstimateSize(
  MedicaoGrupoModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.dofItemId.length * 3;
  bytesCount += 3 + object.id.length * 3;
  return bytesCount;
}

void _medicaoGrupoModelSerialize(
  MedicaoGrupoModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.alturaCm);
  writer.writeDouble(offsets[1], object.comprimentoM);
  writer.writeString(offsets[2], object.dofItemId);
  writer.writeLong(offsets[3], object.fotoIndex);
  writer.writeString(offsets[4], object.id);
  writer.writeBool(offsets[5], object.isPrincipal);
  writer.writeDouble(offsets[6], object.larguraCm);
  writer.writeLong(offsets[7], object.quantidade);
}

MedicaoGrupoModel _medicaoGrupoModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = MedicaoGrupoModel(
    alturaCm: reader.readDouble(offsets[0]),
    comprimentoM: reader.readDouble(offsets[1]),
    dofItemId: reader.readString(offsets[2]),
    fotoIndex: reader.readLong(offsets[3]),
    id: reader.readString(offsets[4]),
    isPrincipal: reader.readBool(offsets[5]),
    larguraCm: reader.readDouble(offsets[6]),
    quantidade: reader.readLong(offsets[7]),
  );
  object.isarId = id;
  return object;
}

P _medicaoGrupoModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readDouble(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readBool(offset)) as P;
    case 6:
      return (reader.readDouble(offset)) as P;
    case 7:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _medicaoGrupoModelGetId(MedicaoGrupoModel object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _medicaoGrupoModelGetLinks(
    MedicaoGrupoModel object) {
  return [];
}

void _medicaoGrupoModelAttach(
    IsarCollection<dynamic> col, Id id, MedicaoGrupoModel object) {
  object.isarId = id;
}

extension MedicaoGrupoModelQueryWhereSort
    on QueryBuilder<MedicaoGrupoModel, MedicaoGrupoModel, QWhere> {
  QueryBuilder<MedicaoGrupoModel, MedicaoGrupoModel, QAfterWhere> anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension MedicaoGrupoModelQueryWhere
    on QueryBuilder<MedicaoGrupoModel, MedicaoGrupoModel, QWhereClause> {
  QueryBuilder<MedicaoGrupoModel, MedicaoGrupoModel, QAfterWhereClause>
      isarIdEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: isarId,
        upper: isarId,
      ));
    });
  }

  QueryBuilder<MedicaoGrupoModel, MedicaoGrupoModel, QAfterWhereClause>
      isarIdNotEqualTo(Id isarId) {
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

  QueryBuilder<MedicaoGrupoModel, MedicaoGrupoModel, QAfterWhereClause>
      isarIdGreaterThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<MedicaoGrupoModel, MedicaoGrupoModel, QAfterWhereClause>
      isarIdLessThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<MedicaoGrupoModel, MedicaoGrupoModel, QAfterWhereClause>
      isarIdBetween(
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

extension MedicaoGrupoModelQueryFilter
    on QueryBuilder<MedicaoGrupoModel, MedicaoGrupoModel, QFilterCondition> {
  QueryBuilder<MedicaoGrupoModel, MedicaoGrupoModel, QAfterFilterCondition>
      alturaCmEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'alturaCm',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MedicaoGrupoModel, MedicaoGrupoModel, QAfterFilterCondition>
      alturaCmGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'alturaCm',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MedicaoGrupoModel, MedicaoGrupoModel, QAfterFilterCondition>
      alturaCmLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'alturaCm',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MedicaoGrupoModel, MedicaoGrupoModel, QAfterFilterCondition>
      alturaCmBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'alturaCm',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MedicaoGrupoModel, MedicaoGrupoModel, QAfterFilterCondition>
      comprimentoMEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'comprimentoM',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MedicaoGrupoModel, MedicaoGrupoModel, QAfterFilterCondition>
      comprimentoMGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'comprimentoM',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MedicaoGrupoModel, MedicaoGrupoModel, QAfterFilterCondition>
      comprimentoMLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'comprimentoM',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MedicaoGrupoModel, MedicaoGrupoModel, QAfterFilterCondition>
      comprimentoMBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'comprimentoM',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MedicaoGrupoModel, MedicaoGrupoModel, QAfterFilterCondition>
      dofItemIdEqualTo(
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

  QueryBuilder<MedicaoGrupoModel, MedicaoGrupoModel, QAfterFilterCondition>
      dofItemIdGreaterThan(
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

  QueryBuilder<MedicaoGrupoModel, MedicaoGrupoModel, QAfterFilterCondition>
      dofItemIdLessThan(
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

  QueryBuilder<MedicaoGrupoModel, MedicaoGrupoModel, QAfterFilterCondition>
      dofItemIdBetween(
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

  QueryBuilder<MedicaoGrupoModel, MedicaoGrupoModel, QAfterFilterCondition>
      dofItemIdStartsWith(
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

  QueryBuilder<MedicaoGrupoModel, MedicaoGrupoModel, QAfterFilterCondition>
      dofItemIdEndsWith(
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

  QueryBuilder<MedicaoGrupoModel, MedicaoGrupoModel, QAfterFilterCondition>
      dofItemIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'dofItemId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicaoGrupoModel, MedicaoGrupoModel, QAfterFilterCondition>
      dofItemIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'dofItemId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicaoGrupoModel, MedicaoGrupoModel, QAfterFilterCondition>
      dofItemIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dofItemId',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicaoGrupoModel, MedicaoGrupoModel, QAfterFilterCondition>
      dofItemIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'dofItemId',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicaoGrupoModel, MedicaoGrupoModel, QAfterFilterCondition>
      fotoIndexEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fotoIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicaoGrupoModel, MedicaoGrupoModel, QAfterFilterCondition>
      fotoIndexGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fotoIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicaoGrupoModel, MedicaoGrupoModel, QAfterFilterCondition>
      fotoIndexLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fotoIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicaoGrupoModel, MedicaoGrupoModel, QAfterFilterCondition>
      fotoIndexBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fotoIndex',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MedicaoGrupoModel, MedicaoGrupoModel, QAfterFilterCondition>
      idEqualTo(
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

  QueryBuilder<MedicaoGrupoModel, MedicaoGrupoModel, QAfterFilterCondition>
      idGreaterThan(
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

  QueryBuilder<MedicaoGrupoModel, MedicaoGrupoModel, QAfterFilterCondition>
      idLessThan(
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

  QueryBuilder<MedicaoGrupoModel, MedicaoGrupoModel, QAfterFilterCondition>
      idBetween(
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

  QueryBuilder<MedicaoGrupoModel, MedicaoGrupoModel, QAfterFilterCondition>
      idStartsWith(
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

  QueryBuilder<MedicaoGrupoModel, MedicaoGrupoModel, QAfterFilterCondition>
      idEndsWith(
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

  QueryBuilder<MedicaoGrupoModel, MedicaoGrupoModel, QAfterFilterCondition>
      idContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicaoGrupoModel, MedicaoGrupoModel, QAfterFilterCondition>
      idMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'id',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MedicaoGrupoModel, MedicaoGrupoModel, QAfterFilterCondition>
      idIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicaoGrupoModel, MedicaoGrupoModel, QAfterFilterCondition>
      idIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<MedicaoGrupoModel, MedicaoGrupoModel, QAfterFilterCondition>
      isPrincipalEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isPrincipal',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicaoGrupoModel, MedicaoGrupoModel, QAfterFilterCondition>
      isarIdEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicaoGrupoModel, MedicaoGrupoModel, QAfterFilterCondition>
      isarIdGreaterThan(
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

  QueryBuilder<MedicaoGrupoModel, MedicaoGrupoModel, QAfterFilterCondition>
      isarIdLessThan(
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

  QueryBuilder<MedicaoGrupoModel, MedicaoGrupoModel, QAfterFilterCondition>
      isarIdBetween(
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

  QueryBuilder<MedicaoGrupoModel, MedicaoGrupoModel, QAfterFilterCondition>
      larguraCmEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'larguraCm',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MedicaoGrupoModel, MedicaoGrupoModel, QAfterFilterCondition>
      larguraCmGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'larguraCm',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MedicaoGrupoModel, MedicaoGrupoModel, QAfterFilterCondition>
      larguraCmLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'larguraCm',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MedicaoGrupoModel, MedicaoGrupoModel, QAfterFilterCondition>
      larguraCmBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'larguraCm',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MedicaoGrupoModel, MedicaoGrupoModel, QAfterFilterCondition>
      quantidadeEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'quantidade',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicaoGrupoModel, MedicaoGrupoModel, QAfterFilterCondition>
      quantidadeGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'quantidade',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicaoGrupoModel, MedicaoGrupoModel, QAfterFilterCondition>
      quantidadeLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'quantidade',
        value: value,
      ));
    });
  }

  QueryBuilder<MedicaoGrupoModel, MedicaoGrupoModel, QAfterFilterCondition>
      quantidadeBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'quantidade',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension MedicaoGrupoModelQueryObject
    on QueryBuilder<MedicaoGrupoModel, MedicaoGrupoModel, QFilterCondition> {}

extension MedicaoGrupoModelQueryLinks
    on QueryBuilder<MedicaoGrupoModel, MedicaoGrupoModel, QFilterCondition> {}

extension MedicaoGrupoModelQuerySortBy
    on QueryBuilder<MedicaoGrupoModel, MedicaoGrupoModel, QSortBy> {
  QueryBuilder<MedicaoGrupoModel, MedicaoGrupoModel, QAfterSortBy>
      sortByAlturaCm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'alturaCm', Sort.asc);
    });
  }

  QueryBuilder<MedicaoGrupoModel, MedicaoGrupoModel, QAfterSortBy>
      sortByAlturaCmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'alturaCm', Sort.desc);
    });
  }

  QueryBuilder<MedicaoGrupoModel, MedicaoGrupoModel, QAfterSortBy>
      sortByComprimentoM() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'comprimentoM', Sort.asc);
    });
  }

  QueryBuilder<MedicaoGrupoModel, MedicaoGrupoModel, QAfterSortBy>
      sortByComprimentoMDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'comprimentoM', Sort.desc);
    });
  }

  QueryBuilder<MedicaoGrupoModel, MedicaoGrupoModel, QAfterSortBy>
      sortByDofItemId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dofItemId', Sort.asc);
    });
  }

  QueryBuilder<MedicaoGrupoModel, MedicaoGrupoModel, QAfterSortBy>
      sortByDofItemIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dofItemId', Sort.desc);
    });
  }

  QueryBuilder<MedicaoGrupoModel, MedicaoGrupoModel, QAfterSortBy>
      sortByFotoIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fotoIndex', Sort.asc);
    });
  }

  QueryBuilder<MedicaoGrupoModel, MedicaoGrupoModel, QAfterSortBy>
      sortByFotoIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fotoIndex', Sort.desc);
    });
  }

  QueryBuilder<MedicaoGrupoModel, MedicaoGrupoModel, QAfterSortBy> sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<MedicaoGrupoModel, MedicaoGrupoModel, QAfterSortBy>
      sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<MedicaoGrupoModel, MedicaoGrupoModel, QAfterSortBy>
      sortByIsPrincipal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPrincipal', Sort.asc);
    });
  }

  QueryBuilder<MedicaoGrupoModel, MedicaoGrupoModel, QAfterSortBy>
      sortByIsPrincipalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPrincipal', Sort.desc);
    });
  }

  QueryBuilder<MedicaoGrupoModel, MedicaoGrupoModel, QAfterSortBy>
      sortByLarguraCm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'larguraCm', Sort.asc);
    });
  }

  QueryBuilder<MedicaoGrupoModel, MedicaoGrupoModel, QAfterSortBy>
      sortByLarguraCmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'larguraCm', Sort.desc);
    });
  }

  QueryBuilder<MedicaoGrupoModel, MedicaoGrupoModel, QAfterSortBy>
      sortByQuantidade() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantidade', Sort.asc);
    });
  }

  QueryBuilder<MedicaoGrupoModel, MedicaoGrupoModel, QAfterSortBy>
      sortByQuantidadeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantidade', Sort.desc);
    });
  }
}

extension MedicaoGrupoModelQuerySortThenBy
    on QueryBuilder<MedicaoGrupoModel, MedicaoGrupoModel, QSortThenBy> {
  QueryBuilder<MedicaoGrupoModel, MedicaoGrupoModel, QAfterSortBy>
      thenByAlturaCm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'alturaCm', Sort.asc);
    });
  }

  QueryBuilder<MedicaoGrupoModel, MedicaoGrupoModel, QAfterSortBy>
      thenByAlturaCmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'alturaCm', Sort.desc);
    });
  }

  QueryBuilder<MedicaoGrupoModel, MedicaoGrupoModel, QAfterSortBy>
      thenByComprimentoM() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'comprimentoM', Sort.asc);
    });
  }

  QueryBuilder<MedicaoGrupoModel, MedicaoGrupoModel, QAfterSortBy>
      thenByComprimentoMDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'comprimentoM', Sort.desc);
    });
  }

  QueryBuilder<MedicaoGrupoModel, MedicaoGrupoModel, QAfterSortBy>
      thenByDofItemId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dofItemId', Sort.asc);
    });
  }

  QueryBuilder<MedicaoGrupoModel, MedicaoGrupoModel, QAfterSortBy>
      thenByDofItemIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dofItemId', Sort.desc);
    });
  }

  QueryBuilder<MedicaoGrupoModel, MedicaoGrupoModel, QAfterSortBy>
      thenByFotoIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fotoIndex', Sort.asc);
    });
  }

  QueryBuilder<MedicaoGrupoModel, MedicaoGrupoModel, QAfterSortBy>
      thenByFotoIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fotoIndex', Sort.desc);
    });
  }

  QueryBuilder<MedicaoGrupoModel, MedicaoGrupoModel, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<MedicaoGrupoModel, MedicaoGrupoModel, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<MedicaoGrupoModel, MedicaoGrupoModel, QAfterSortBy>
      thenByIsPrincipal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPrincipal', Sort.asc);
    });
  }

  QueryBuilder<MedicaoGrupoModel, MedicaoGrupoModel, QAfterSortBy>
      thenByIsPrincipalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPrincipal', Sort.desc);
    });
  }

  QueryBuilder<MedicaoGrupoModel, MedicaoGrupoModel, QAfterSortBy>
      thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<MedicaoGrupoModel, MedicaoGrupoModel, QAfterSortBy>
      thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<MedicaoGrupoModel, MedicaoGrupoModel, QAfterSortBy>
      thenByLarguraCm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'larguraCm', Sort.asc);
    });
  }

  QueryBuilder<MedicaoGrupoModel, MedicaoGrupoModel, QAfterSortBy>
      thenByLarguraCmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'larguraCm', Sort.desc);
    });
  }

  QueryBuilder<MedicaoGrupoModel, MedicaoGrupoModel, QAfterSortBy>
      thenByQuantidade() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantidade', Sort.asc);
    });
  }

  QueryBuilder<MedicaoGrupoModel, MedicaoGrupoModel, QAfterSortBy>
      thenByQuantidadeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantidade', Sort.desc);
    });
  }
}

extension MedicaoGrupoModelQueryWhereDistinct
    on QueryBuilder<MedicaoGrupoModel, MedicaoGrupoModel, QDistinct> {
  QueryBuilder<MedicaoGrupoModel, MedicaoGrupoModel, QDistinct>
      distinctByAlturaCm() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'alturaCm');
    });
  }

  QueryBuilder<MedicaoGrupoModel, MedicaoGrupoModel, QDistinct>
      distinctByComprimentoM() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'comprimentoM');
    });
  }

  QueryBuilder<MedicaoGrupoModel, MedicaoGrupoModel, QDistinct>
      distinctByDofItemId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dofItemId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MedicaoGrupoModel, MedicaoGrupoModel, QDistinct>
      distinctByFotoIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fotoIndex');
    });
  }

  QueryBuilder<MedicaoGrupoModel, MedicaoGrupoModel, QDistinct> distinctById(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'id', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MedicaoGrupoModel, MedicaoGrupoModel, QDistinct>
      distinctByIsPrincipal() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isPrincipal');
    });
  }

  QueryBuilder<MedicaoGrupoModel, MedicaoGrupoModel, QDistinct>
      distinctByLarguraCm() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'larguraCm');
    });
  }

  QueryBuilder<MedicaoGrupoModel, MedicaoGrupoModel, QDistinct>
      distinctByQuantidade() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'quantidade');
    });
  }
}

extension MedicaoGrupoModelQueryProperty
    on QueryBuilder<MedicaoGrupoModel, MedicaoGrupoModel, QQueryProperty> {
  QueryBuilder<MedicaoGrupoModel, int, QQueryOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<MedicaoGrupoModel, double, QQueryOperations> alturaCmProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'alturaCm');
    });
  }

  QueryBuilder<MedicaoGrupoModel, double, QQueryOperations>
      comprimentoMProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'comprimentoM');
    });
  }

  QueryBuilder<MedicaoGrupoModel, String, QQueryOperations>
      dofItemIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dofItemId');
    });
  }

  QueryBuilder<MedicaoGrupoModel, int, QQueryOperations> fotoIndexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fotoIndex');
    });
  }

  QueryBuilder<MedicaoGrupoModel, String, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<MedicaoGrupoModel, bool, QQueryOperations>
      isPrincipalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isPrincipal');
    });
  }

  QueryBuilder<MedicaoGrupoModel, double, QQueryOperations>
      larguraCmProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'larguraCm');
    });
  }

  QueryBuilder<MedicaoGrupoModel, int, QQueryOperations> quantidadeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'quantidade');
    });
  }
}
