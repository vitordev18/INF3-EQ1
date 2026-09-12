import 'package:flutter_test/flutter_test.dart';

import 'package:fiscaliza/features/dof/data/models/dof_item_model.dart';

void main() {
  DofItemModel base() => DofItemModel(
    id: 'a1',
    numero: '001',
    produto: 'Madeira serrada',
    especieCientifico: 'Goupia glabra',
    nomePopular: 'Cupiúba',
    saldoLivre: 6.57,
    saldoTotal: 32.13,
    unidade: 'm³',
    sessaoId: 's1',
  );

  group('DofItemModel — serialização', () {
    test('toJson/fromJson preserva todos os campos', () {
      final original = base();
      final recuperado = DofItemModel.fromJson(original.toJson());

      expect(recuperado.id, original.id);
      expect(recuperado.numero, original.numero);
      expect(recuperado.produto, original.produto);
      expect(recuperado.especieCientifico, original.especieCientifico);
      expect(recuperado.nomePopular, original.nomePopular);
      expect(recuperado.saldoLivre, original.saldoLivre);
      expect(recuperado.saldoTotal, original.saldoTotal);
      expect(recuperado.unidade, original.unidade);
      expect(recuperado.sessaoId, original.sessaoId);
    });

    test('toJson expõe todas as chaves esperadas', () {
      expect(
        base().toJson().keys,
        containsAll(<String>[
          'id',
          'numero',
          'produto',
          'especieCientifico',
          'nomePopular',
          'saldoLivre',
          'saldoTotal',
          'unidade',
          'criadoEm',
          'sessaoId',
        ]),
      );
    });

    test('unidade ausente no JSON assume m³', () {
      final json = base().toJson()..remove('unidade');
      expect(DofItemModel.fromJson(json).unidade, 'm³');
    });

    test('criadoEm é preenchido automaticamente quando não informado', () {
      expect(base().criadoEm, isNotNull);
    });
  });

  group('DofItemModel — copyWith', () {
    test('altera só o campo informado', () {
      final alterado = base().copyWith(saldoTotal: 99);
      expect(alterado.saldoTotal, 99);
      expect(alterado.numero, '001');
      expect(alterado.especieCientifico, 'Goupia glabra');
    });

    test('sem argumentos devolve cópia equivalente', () {
      final copia = base().copyWith();
      expect(copia.toJson()..remove('criadoEm'),
          base().toJson()..remove('criadoEm'));
    });
  });
}
