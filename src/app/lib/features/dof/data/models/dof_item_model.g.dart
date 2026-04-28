part of 'dof_item_model.dart';

extension GetDofItemModelCollection on Isar {
  IsarCollection<DofItemModel> get dofItemModels => this.collection();
}

const DofItemModelSchema = CollectionSchema(
  name: r'DofItemModel',
  id: 7384308643107393409,
  properties: {
    r'criadoEm': PropertySchema(
      id: 0,
      name: r'criadoEm',
      type: IsarType.dateTime,
    ),
    r'especieCientifico': PropertySchema(
      id: 1,
      name: r'especieCientifico',
      type: IsarType.string,
    ),
    r'id': PropertySchema(
      id: 2,
      name: r'id',
      type: IsarType.string,
    ),
    r'nomePopular': PropertySchema(
      id: 3,
      name: r'nomePopular',
      type: IsarType.string,
    ),
    r'numero': PropertySchema(
      id: 4,
      name: r'numero',
      type: IsarType.string,
    ),
    r'produto': PropertySchema(
      id: 5,
      name: r'produto',
      type: IsarType.string,
    ),
    r'saldoLivre': PropertySchema(
      id: 6,
      name: r'saldoLivre',
      type: IsarType.double,
    ),
    r'saldoTotal': PropertySchema(
      id: 7,
      name: r'saldoTotal',
      type: IsarType.double,
    ),
    r'unidade': PropertySchema(
      id: 8,
      name: r'unidade',
      type: IsarType.string,
    )
  },
  estimateSize: _dofItemModelEstimateSize,
  serialize: _dofItemModelSerialize,
  deserialize: _dofItemModelDeserialize,
  deserializeProp: _dofItemModelDeserializeProp,
  idName: r'isarId',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _dofItemModelGetId,
  getLinks: _dofItemModelGetLinks,
  attach: _dofItemModelAttach,
  version: '3.1.0+1',
);

int _dofItemModelEstimateSize(
  DofItemModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.especieCientifico.length * 3;
  bytesCount += 3 + object.id.length * 3;
  bytesCount += 3 + object.nomePopular.length * 3;
  bytesCount += 3 + object.numero.length * 3;
  bytesCount += 3 + object.produto.length * 3;
  bytesCount += 3 + object.unidade.length * 3;
  return bytesCount;
}

void _dofItemModelSerialize(
  DofItemModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.criadoEm);
  writer.writeString(offsets[1], object.especieCientifico);
  writer.writeString(offsets[2], object.id);
  writer.writeString(offsets[3], object.nomePopular);
  writer.writeString(offsets[4], object.numero);
  writer.writeString(offsets[5], object.produto);
  writer.writeDouble(offsets[6], object.saldoLivre);
  writer.writeDouble(offsets[7], object.saldoTotal);
  writer.writeString(offsets[8], object.unidade);
}

DofItemModel _dofItemModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = DofItemModel(
    criadoEm: reader.readDateTimeOrNull(offsets[0]),
    especieCientifico: reader.readString(offsets[1]),
    id: reader.readString(offsets[2]),
    nomePopular: reader.readString(offsets[3]),
    numero: reader.readString(offsets[4]),
    produto: reader.readString(offsets[5]),
    saldoLivre: reader.readDouble(offsets[6]),
    saldoTotal: reader.readDouble(offsets[7]),
    unidade: reader.readString(offsets[8]),
  );
  object.isarId = id;
  return object;
}

P _dofItemModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readDouble(offset)) as P;
    case 7:
      return (reader.readDouble(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _dofItemModelGetId(DofItemModel object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _dofItemModelGetLinks(DofItemModel object) {
  return [];
}

void _dofItemModelAttach(
    IsarCollection<dynamic> col, Id id, DofItemModel object) {
  object.isarId = id;
}

extension DofItemModelQueryWhereSort
    on QueryBuilder<DofItemModel, DofItemModel, QWhere> {
  QueryBuilder<DofItemModel, DofItemModel, QAfterWhere> anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension DofItemModelQueryWhere
    on QueryBuilder<DofItemModel, DofItemModel, QWhereClause> {
  QueryBuilder<DofItemModel, DofItemModel, QAfterWhereClause> isarIdEqualTo(
      Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: isarId,
        upper: isarId,
      ));
    });
  }

  QueryBuilder<DofItemModel, DofItemModel, QAfterWhereClause> isarIdNotEqualTo(
      Id isarId) {
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

  QueryBuilder<DofItemModel, DofItemModel, QAfterWhereClause> isarIdGreaterThan(
      Id isarId,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<DofItemModel, DofItemModel, QAfterWhereClause> isarIdLessThan(
      Id isarId,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<DofItemModel, DofItemModel, QAfterWhereClause> isarIdBetween(
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

extension DofItemModelQueryFilter
    on QueryBuilder<DofItemModel, DofItemModel, QFilterCondition> {
  QueryBuilder<DofItemModel, DofItemModel, QAfterFilterCondition>
      criadoEmIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'criadoEm',
      ));
    });
  }

  QueryBuilder<DofItemModel, DofItemModel, QAfterFilterCondition>
      criadoEmIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'criadoEm',
      ));
    });
  }

  QueryBuilder<DofItemModel, DofItemModel, QAfterFilterCondition>
      criadoEmEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'criadoEm',
        value: value,
      ));
    });
  }

  QueryBuilder<DofItemModel, DofItemModel, QAfterFilterCondition>
      criadoEmGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'criadoEm',
        value: value,
      ));
    });
  }

  QueryBuilder<DofItemModel, DofItemModel, QAfterFilterCondition>
      criadoEmLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'criadoEm',
        value: value,
      ));
    });
  }

  QueryBuilder<DofItemModel, DofItemModel, QAfterFilterCondition>
      criadoEmBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'criadoEm',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DofItemModel, DofItemModel, QAfterFilterCondition>
      especieCientificoEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'especieCientifico',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DofItemModel, DofItemModel, QAfterFilterCondition>
      especieCientificoGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'especieCientifico',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DofItemModel, DofItemModel, QAfterFilterCondition>
      especieCientificoLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'especieCientifico',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DofItemModel, DofItemModel, QAfterFilterCondition>
      especieCientificoBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'especieCientifico',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DofItemModel, DofItemModel, QAfterFilterCondition>
      especieCientificoStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'especieCientifico',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DofItemModel, DofItemModel, QAfterFilterCondition>
      especieCientificoEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'especieCientifico',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DofItemModel, DofItemModel, QAfterFilterCondition>
      especieCientificoContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'especieCientifico',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DofItemModel, DofItemModel, QAfterFilterCondition>
      especieCientificoMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'especieCientifico',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DofItemModel, DofItemModel, QAfterFilterCondition>
      especieCientificoIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'especieCientifico',
        value: '',
      ));
    });
  }

  QueryBuilder<DofItemModel, DofItemModel, QAfterFilterCondition>
      especieCientificoIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'especieCientifico',
        value: '',
      ));
    });
  }

  QueryBuilder<DofItemModel, DofItemModel, QAfterFilterCondition> idEqualTo(
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

  QueryBuilder<DofItemModel, DofItemModel, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<DofItemModel, DofItemModel, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<DofItemModel, DofItemModel, QAfterFilterCondition> idBetween(
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

  QueryBuilder<DofItemModel, DofItemModel, QAfterFilterCondition> idStartsWith(
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

  QueryBuilder<DofItemModel, DofItemModel, QAfterFilterCondition> idEndsWith(
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

  QueryBuilder<DofItemModel, DofItemModel, QAfterFilterCondition> idContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DofItemModel, DofItemModel, QAfterFilterCondition> idMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'id',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DofItemModel, DofItemModel, QAfterFilterCondition> idIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<DofItemModel, DofItemModel, QAfterFilterCondition>
      idIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<DofItemModel, DofItemModel, QAfterFilterCondition> isarIdEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<DofItemModel, DofItemModel, QAfterFilterCondition>
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

  QueryBuilder<DofItemModel, DofItemModel, QAfterFilterCondition>
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

  QueryBuilder<DofItemModel, DofItemModel, QAfterFilterCondition> isarIdBetween(
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

  QueryBuilder<DofItemModel, DofItemModel, QAfterFilterCondition>
      nomePopularEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nomePopular',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DofItemModel, DofItemModel, QAfterFilterCondition>
      nomePopularGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'nomePopular',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DofItemModel, DofItemModel, QAfterFilterCondition>
      nomePopularLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'nomePopular',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DofItemModel, DofItemModel, QAfterFilterCondition>
      nomePopularBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'nomePopular',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DofItemModel, DofItemModel, QAfterFilterCondition>
      nomePopularStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'nomePopular',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DofItemModel, DofItemModel, QAfterFilterCondition>
      nomePopularEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'nomePopular',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DofItemModel, DofItemModel, QAfterFilterCondition>
      nomePopularContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'nomePopular',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DofItemModel, DofItemModel, QAfterFilterCondition>
      nomePopularMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'nomePopular',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DofItemModel, DofItemModel, QAfterFilterCondition>
      nomePopularIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nomePopular',
        value: '',
      ));
    });
  }

  QueryBuilder<DofItemModel, DofItemModel, QAfterFilterCondition>
      nomePopularIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'nomePopular',
        value: '',
      ));
    });
  }

  QueryBuilder<DofItemModel, DofItemModel, QAfterFilterCondition> numeroEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'numero',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DofItemModel, DofItemModel, QAfterFilterCondition>
      numeroGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'numero',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DofItemModel, DofItemModel, QAfterFilterCondition>
      numeroLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'numero',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DofItemModel, DofItemModel, QAfterFilterCondition> numeroBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'numero',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DofItemModel, DofItemModel, QAfterFilterCondition>
      numeroStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'numero',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DofItemModel, DofItemModel, QAfterFilterCondition>
      numeroEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'numero',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DofItemModel, DofItemModel, QAfterFilterCondition>
      numeroContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'numero',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DofItemModel, DofItemModel, QAfterFilterCondition> numeroMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'numero',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DofItemModel, DofItemModel, QAfterFilterCondition>
      numeroIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'numero',
        value: '',
      ));
    });
  }

  QueryBuilder<DofItemModel, DofItemModel, QAfterFilterCondition>
      numeroIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'numero',
        value: '',
      ));
    });
  }

  QueryBuilder<DofItemModel, DofItemModel, QAfterFilterCondition>
      produtoEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'produto',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DofItemModel, DofItemModel, QAfterFilterCondition>
      produtoGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'produto',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DofItemModel, DofItemModel, QAfterFilterCondition>
      produtoLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'produto',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DofItemModel, DofItemModel, QAfterFilterCondition>
      produtoBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'produto',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DofItemModel, DofItemModel, QAfterFilterCondition>
      produtoStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'produto',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DofItemModel, DofItemModel, QAfterFilterCondition>
      produtoEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'produto',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DofItemModel, DofItemModel, QAfterFilterCondition>
      produtoContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'produto',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DofItemModel, DofItemModel, QAfterFilterCondition>
      produtoMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'produto',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DofItemModel, DofItemModel, QAfterFilterCondition>
      produtoIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'produto',
        value: '',
      ));
    });
  }

  QueryBuilder<DofItemModel, DofItemModel, QAfterFilterCondition>
      produtoIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'produto',
        value: '',
      ));
    });
  }

  QueryBuilder<DofItemModel, DofItemModel, QAfterFilterCondition>
      saldoLivreEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'saldoLivre',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DofItemModel, DofItemModel, QAfterFilterCondition>
      saldoLivreGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'saldoLivre',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DofItemModel, DofItemModel, QAfterFilterCondition>
      saldoLivreLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'saldoLivre',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DofItemModel, DofItemModel, QAfterFilterCondition>
      saldoLivreBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'saldoLivre',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DofItemModel, DofItemModel, QAfterFilterCondition>
      saldoTotalEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'saldoTotal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DofItemModel, DofItemModel, QAfterFilterCondition>
      saldoTotalGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'saldoTotal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DofItemModel, DofItemModel, QAfterFilterCondition>
      saldoTotalLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'saldoTotal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DofItemModel, DofItemModel, QAfterFilterCondition>
      saldoTotalBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'saldoTotal',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DofItemModel, DofItemModel, QAfterFilterCondition>
      unidadeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'unidade',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DofItemModel, DofItemModel, QAfterFilterCondition>
      unidadeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'unidade',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DofItemModel, DofItemModel, QAfterFilterCondition>
      unidadeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'unidade',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DofItemModel, DofItemModel, QAfterFilterCondition>
      unidadeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'unidade',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DofItemModel, DofItemModel, QAfterFilterCondition>
      unidadeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'unidade',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DofItemModel, DofItemModel, QAfterFilterCondition>
      unidadeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'unidade',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DofItemModel, DofItemModel, QAfterFilterCondition>
      unidadeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'unidade',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DofItemModel, DofItemModel, QAfterFilterCondition>
      unidadeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'unidade',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DofItemModel, DofItemModel, QAfterFilterCondition>
      unidadeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'unidade',
        value: '',
      ));
    });
  }

  QueryBuilder<DofItemModel, DofItemModel, QAfterFilterCondition>
      unidadeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'unidade',
        value: '',
      ));
    });
  }
}

extension DofItemModelQueryObject
    on QueryBuilder<DofItemModel, DofItemModel, QFilterCondition> {}

extension DofItemModelQueryLinks
    on QueryBuilder<DofItemModel, DofItemModel, QFilterCondition> {}

extension DofItemModelQuerySortBy
    on QueryBuilder<DofItemModel, DofItemModel, QSortBy> {
  QueryBuilder<DofItemModel, DofItemModel, QAfterSortBy> sortByCriadoEm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'criadoEm', Sort.asc);
    });
  }

  QueryBuilder<DofItemModel, DofItemModel, QAfterSortBy> sortByCriadoEmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'criadoEm', Sort.desc);
    });
  }

  QueryBuilder<DofItemModel, DofItemModel, QAfterSortBy>
      sortByEspecieCientifico() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'especieCientifico', Sort.asc);
    });
  }

  QueryBuilder<DofItemModel, DofItemModel, QAfterSortBy>
      sortByEspecieCientificoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'especieCientifico', Sort.desc);
    });
  }

  QueryBuilder<DofItemModel, DofItemModel, QAfterSortBy> sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<DofItemModel, DofItemModel, QAfterSortBy> sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<DofItemModel, DofItemModel, QAfterSortBy> sortByNomePopular() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nomePopular', Sort.asc);
    });
  }

  QueryBuilder<DofItemModel, DofItemModel, QAfterSortBy>
      sortByNomePopularDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nomePopular', Sort.desc);
    });
  }

  QueryBuilder<DofItemModel, DofItemModel, QAfterSortBy> sortByNumero() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'numero', Sort.asc);
    });
  }

  QueryBuilder<DofItemModel, DofItemModel, QAfterSortBy> sortByNumeroDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'numero', Sort.desc);
    });
  }

  QueryBuilder<DofItemModel, DofItemModel, QAfterSortBy> sortByProduto() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'produto', Sort.asc);
    });
  }

  QueryBuilder<DofItemModel, DofItemModel, QAfterSortBy> sortByProdutoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'produto', Sort.desc);
    });
  }

  QueryBuilder<DofItemModel, DofItemModel, QAfterSortBy> sortBySaldoLivre() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'saldoLivre', Sort.asc);
    });
  }

  QueryBuilder<DofItemModel, DofItemModel, QAfterSortBy>
      sortBySaldoLivreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'saldoLivre', Sort.desc);
    });
  }

  QueryBuilder<DofItemModel, DofItemModel, QAfterSortBy> sortBySaldoTotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'saldoTotal', Sort.asc);
    });
  }

  QueryBuilder<DofItemModel, DofItemModel, QAfterSortBy>
      sortBySaldoTotalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'saldoTotal', Sort.desc);
    });
  }

  QueryBuilder<DofItemModel, DofItemModel, QAfterSortBy> sortByUnidade() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unidade', Sort.asc);
    });
  }

  QueryBuilder<DofItemModel, DofItemModel, QAfterSortBy> sortByUnidadeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unidade', Sort.desc);
    });
  }
}

extension DofItemModelQuerySortThenBy
    on QueryBuilder<DofItemModel, DofItemModel, QSortThenBy> {
  QueryBuilder<DofItemModel, DofItemModel, QAfterSortBy> thenByCriadoEm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'criadoEm', Sort.asc);
    });
  }

  QueryBuilder<DofItemModel, DofItemModel, QAfterSortBy> thenByCriadoEmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'criadoEm', Sort.desc);
    });
  }

  QueryBuilder<DofItemModel, DofItemModel, QAfterSortBy>
      thenByEspecieCientifico() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'especieCientifico', Sort.asc);
    });
  }

  QueryBuilder<DofItemModel, DofItemModel, QAfterSortBy>
      thenByEspecieCientificoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'especieCientifico', Sort.desc);
    });
  }

  QueryBuilder<DofItemModel, DofItemModel, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<DofItemModel, DofItemModel, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<DofItemModel, DofItemModel, QAfterSortBy> thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<DofItemModel, DofItemModel, QAfterSortBy> thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<DofItemModel, DofItemModel, QAfterSortBy> thenByNomePopular() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nomePopular', Sort.asc);
    });
  }

  QueryBuilder<DofItemModel, DofItemModel, QAfterSortBy>
      thenByNomePopularDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nomePopular', Sort.desc);
    });
  }

  QueryBuilder<DofItemModel, DofItemModel, QAfterSortBy> thenByNumero() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'numero', Sort.asc);
    });
  }

  QueryBuilder<DofItemModel, DofItemModel, QAfterSortBy> thenByNumeroDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'numero', Sort.desc);
    });
  }

  QueryBuilder<DofItemModel, DofItemModel, QAfterSortBy> thenByProduto() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'produto', Sort.asc);
    });
  }

  QueryBuilder<DofItemModel, DofItemModel, QAfterSortBy> thenByProdutoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'produto', Sort.desc);
    });
  }

  QueryBuilder<DofItemModel, DofItemModel, QAfterSortBy> thenBySaldoLivre() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'saldoLivre', Sort.asc);
    });
  }

  QueryBuilder<DofItemModel, DofItemModel, QAfterSortBy>
      thenBySaldoLivreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'saldoLivre', Sort.desc);
    });
  }

  QueryBuilder<DofItemModel, DofItemModel, QAfterSortBy> thenBySaldoTotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'saldoTotal', Sort.asc);
    });
  }

  QueryBuilder<DofItemModel, DofItemModel, QAfterSortBy>
      thenBySaldoTotalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'saldoTotal', Sort.desc);
    });
  }

  QueryBuilder<DofItemModel, DofItemModel, QAfterSortBy> thenByUnidade() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unidade', Sort.asc);
    });
  }

  QueryBuilder<DofItemModel, DofItemModel, QAfterSortBy> thenByUnidadeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unidade', Sort.desc);
    });
  }
}

extension DofItemModelQueryWhereDistinct
    on QueryBuilder<DofItemModel, DofItemModel, QDistinct> {
  QueryBuilder<DofItemModel, DofItemModel, QDistinct> distinctByCriadoEm() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'criadoEm');
    });
  }

  QueryBuilder<DofItemModel, DofItemModel, QDistinct>
      distinctByEspecieCientifico({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'especieCientifico',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DofItemModel, DofItemModel, QDistinct> distinctById(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'id', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DofItemModel, DofItemModel, QDistinct> distinctByNomePopular(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nomePopular', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DofItemModel, DofItemModel, QDistinct> distinctByNumero(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'numero', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DofItemModel, DofItemModel, QDistinct> distinctByProduto(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'produto', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DofItemModel, DofItemModel, QDistinct> distinctBySaldoLivre() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'saldoLivre');
    });
  }

  QueryBuilder<DofItemModel, DofItemModel, QDistinct> distinctBySaldoTotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'saldoTotal');
    });
  }

  QueryBuilder<DofItemModel, DofItemModel, QDistinct> distinctByUnidade(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'unidade', caseSensitive: caseSensitive);
    });
  }
}

extension DofItemModelQueryProperty
    on QueryBuilder<DofItemModel, DofItemModel, QQueryProperty> {
  QueryBuilder<DofItemModel, int, QQueryOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<DofItemModel, DateTime?, QQueryOperations> criadoEmProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'criadoEm');
    });
  }

  QueryBuilder<DofItemModel, String, QQueryOperations>
      especieCientificoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'especieCientifico');
    });
  }

  QueryBuilder<DofItemModel, String, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<DofItemModel, String, QQueryOperations> nomePopularProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nomePopular');
    });
  }

  QueryBuilder<DofItemModel, String, QQueryOperations> numeroProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'numero');
    });
  }

  QueryBuilder<DofItemModel, String, QQueryOperations> produtoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'produto');
    });
  }

  QueryBuilder<DofItemModel, double, QQueryOperations> saldoLivreProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'saldoLivre');
    });
  }

  QueryBuilder<DofItemModel, double, QQueryOperations> saldoTotalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'saldoTotal');
    });
  }

  QueryBuilder<DofItemModel, String, QQueryOperations> unidadeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'unidade');
    });
  }
}
