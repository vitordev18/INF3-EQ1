import 'package:flutter_test/flutter_test.dart';

import 'package:fiscaliza/features/dof/data/models/dof_item_model.dart';
import 'package:fiscaliza/features/dof/domain/dof_validator.dart';

DofItemModel item({
  String numero = '001',
  String produto = 'Madeira serrada',
  String especie = 'Goupia glabra',
  String popular = 'Cupiúba',
  double saldoLivre = 5,
  double saldoTotal = 10,
  String unidade = 'm³',
}) => DofItemModel(
  id: 'id-$numero',
  numero: numero,
  produto: produto,
  especieCientifico: especie,
  nomePopular: popular,
  saldoLivre: saldoLivre,
  saldoTotal: saldoTotal,
  unidade: unidade,
);

void main() {
  group('DofValidator.validateItem', () {
    test('item completo e coerente é válido', () {
      final r = DofValidator.validateItem(item());
      expect(r.isValid, isTrue);
      expect(r.errors, isEmpty);
    });

    test('campos de texto obrigatórios vazios são acusados', () {
      final r = DofValidator.validateItem(
        item(numero: '', produto: '', especie: '', popular: ''),
      );
      expect(r.isValid, isFalse);
      expect(r.errors.length, 4);
    });

    test('saldo livre maior que o total é rejeitado', () {
      final r = DofValidator.validateItem(
        item(saldoLivre: 20, saldoTotal: 10),
      );
      expect(r.isValid, isFalse);
      expect(
        r.errors,
        contains('Saldo Livre não pode ser maior que Saldo Total'),
      );
    });

    test('saldos negativos são rejeitados', () {
      final r = DofValidator.validateItem(
        item(saldoLivre: -1, saldoTotal: -2),
      );
      expect(r.isValid, isFalse);
      expect(r.errors.any((e) => e.contains('Saldo Livre')), isTrue);
      expect(r.errors.any((e) => e.contains('Saldo Total')), isTrue);
    });

    test('unidade vazia é rejeitada', () {
      final r = DofValidator.validateItem(item(unidade: ''));
      expect(r.isValid, isFalse);
    });

    test('saldo livre igual ao total é válido (fronteira)', () {
      final r = DofValidator.validateItem(
        item(saldoLivre: 10, saldoTotal: 10),
      );
      expect(r.isValid, isTrue);
    });
  });

  group('DofValidator.validateBatch', () {
    test('relata taxa de sucesso e índices inválidos', () {
      final r = DofValidator.validateBatch([
        item(numero: '001'),
        item(numero: '002', saldoLivre: 99, saldoTotal: 1),
        item(numero: '003'),
        item(numero: ''),
      ]);

      expect(r.totalItems, 4);
      expect(r.validItems, 2);
      expect(r.invalidItems.keys, containsAll(<int>[1, 3]));
      expect(r.successRate, 50);
    });

    test('lista vazia não divide por zero', () {
      final r = DofValidator.validateBatch([]);
      expect(r.totalItems, 0);
      expect(r.successRate, 0);
    });
  });
}
