import 'package:flutter_test/flutter_test.dart';
import 'package:app/features/fiscalizacao/data/models/medicao_grupo_model.dart';
import 'package:app/core/utils/formatting_converter.dart';

// Testa a lógica de negócio de persistência de cubagem independente do Isar.
// Para testes de integração com banco real, usar isar_test_helpers quando disponível.

void main() {
  // ── Helpers ─────────────────────────────────────────────────────────────────

  MedicaoGrupoModel grupo({
    required String id,
    required String dofItemId,
    required int fotoIndex,
    double comprimentoM = 3.0,
    double larguraCm = 30.0,
    double alturaCm = 5.0,
    int quantidade = 1,
    bool isPrincipal = false,
  }) =>
      MedicaoGrupoModel(
        id: id,
        dofItemId: dofItemId,
        fotoIndex: fotoIndex,
        comprimentoM: comprimentoM,
        larguraCm: larguraCm,
        alturaCm: alturaCm,
        quantidade: quantidade,
        isPrincipal: isPrincipal,
      );

  // ── Cálculo de Volume ────────────────────────────────────────────────────────

  group('FormattingConverter.calcularVolume', () {
    test('calcula volume corretamente para prancha padrão', () {
      // 300cm × 30cm × 5cm = 3m × 0.30m × 0.05m = 0.045m³
      final vol = FormattingConverter.calcularVolume(
        larguraCm: 30.0,
        alturaCm: 5.0,
        comprimentoM: 3.0,
        quantidade: 1,
      );
      expect(vol, closeTo(0.045, 1e-9));
    });

    test('multiplica pela quantidade corretamente', () {
      final vol = FormattingConverter.calcularVolume(
        larguraCm: 30.0,
        alturaCm: 5.0,
        comprimentoM: 3.0,
        quantidade: 5,
      );
      expect(vol, closeTo(0.225, 1e-9));
    });

    test('volume zero quando alguma dimensão é zero', () {
      final vol = FormattingConverter.calcularVolume(
        larguraCm: 0.0,
        alturaCm: 5.0,
        comprimentoM: 3.0,
        quantidade: 1,
      );
      expect(vol, equals(0.0));
    });
  });

  // ── Lógica de Merge de Grupos ────────────────────────────────────────────────

  group('Merge de grupos com mesmas dimensões', () {
    // Replica a lógica de _adicionarNaTabelaLocal para testar isoladamente
    List<MedicaoGrupoModel> simularAdicionar(
      List<MedicaoGrupoModel> lista,
      MedicaoGrupoModel novo,
    ) {
      final compM = novo.comprimentoM;
      final idxExistente = lista.indexWhere((m) =>
          (m.comprimentoM - compM).abs() < 1e-6 &&
          (m.larguraCm - novo.larguraCm).abs() < 1e-6 &&
          (m.alturaCm - novo.alturaCm).abs() < 1e-6);
      if (idxExistente != -1) {
        final existente = lista[idxExistente];
        final merged = MedicaoGrupoModel(
          id: existente.id,
          dofItemId: existente.dofItemId,
          fotoIndex: existente.fotoIndex,
          comprimentoM: existente.comprimentoM,
          larguraCm: existente.larguraCm,
          alturaCm: existente.alturaCm,
          quantidade: existente.quantidade + novo.quantidade,
          isPrincipal: existente.isPrincipal,
        )..isarId = existente.isarId;
        return [...lista]..[idxExistente] = merged;
      }
      return [...lista, novo];
    }

    test('inserir duas medidas com dimensões iguais faz merge', () {
      final g1 = grupo(id: 'a', dofItemId: 'dof1', fotoIndex: 0, quantidade: 2);
      final g2 = grupo(id: 'b', dofItemId: 'dof1', fotoIndex: 0, quantidade: 3);

      List<MedicaoGrupoModel> lista = [];
      lista = simularAdicionar(lista, g1);
      lista = simularAdicionar(lista, g2);

      expect(lista.length, equals(1));
      expect(lista.first.quantidade, equals(5));
      expect(lista.first.id, equals('a')); // preserva id original
    });

    test('inserir medidas com dimensões diferentes cria grupos separados', () {
      final g1 = grupo(id: 'a', dofItemId: 'dof1', fotoIndex: 0, larguraCm: 30.0, quantidade: 1);
      final g2 = grupo(id: 'b', dofItemId: 'dof1', fotoIndex: 0, larguraCm: 15.0, quantidade: 1);

      List<MedicaoGrupoModel> lista = [];
      lista = simularAdicionar(lista, g1);
      lista = simularAdicionar(lista, g2);

      expect(lista.length, equals(2));
    });

    test('inserir em foto diferente não interfere nos grupos da foto atual', () {
      final g1 = grupo(id: 'a', dofItemId: 'dof1', fotoIndex: 0, quantidade: 1);
      final g2 = grupo(id: 'b', dofItemId: 'dof1', fotoIndex: 1, quantidade: 1);

      // Listas por foto são separadas — simulando o comportamento da tela
      List<MedicaoGrupoModel> listaFoto0 = [];
      List<MedicaoGrupoModel> listaFoto1 = [];

      listaFoto0 = simularAdicionar(listaFoto0, g1);
      listaFoto1 = simularAdicionar(listaFoto1, g2);

      expect(listaFoto0.length, equals(1));
      expect(listaFoto1.length, equals(1));
      expect(listaFoto0.first.fotoIndex, equals(0));
      expect(listaFoto1.first.fotoIndex, equals(1));
    });
  });

  // ── Reindexação após remoção de foto ────────────────────────────────────────

  group('Reindexação de medições após remoção de foto', () {
    // Replica a lógica de reindexMedicoesAposRemocao para testar isoladamente
    List<MedicaoGrupoModel> simularReindex(
      List<MedicaoGrupoModel> medicoes,
      int removedIndex,
    ) {
      return medicoes.map((m) {
        if (m.fotoIndex > removedIndex) {
          return MedicaoGrupoModel(
            id: m.id,
            dofItemId: m.dofItemId,
            fotoIndex: m.fotoIndex - 1,
            comprimentoM: m.comprimentoM,
            larguraCm: m.larguraCm,
            alturaCm: m.alturaCm,
            quantidade: m.quantidade,
            isPrincipal: m.isPrincipal,
          )..isarId = m.isarId;
        }
        return m;
      }).toList();
    }

    test('remover foto 0 decrementa índices das demais', () {
      final medicoes = [
        grupo(id: 'a', dofItemId: 'dof1', fotoIndex: 1),
        grupo(id: 'b', dofItemId: 'dof1', fotoIndex: 2),
      ];

      final reindexadas = simularReindex(medicoes, 0);
      expect(reindexadas[0].fotoIndex, equals(0));
      expect(reindexadas[1].fotoIndex, equals(1));
    });

    test('remover foto do meio decrementa apenas as subsequentes', () {
      final medicoes = [
        grupo(id: 'a', dofItemId: 'dof1', fotoIndex: 0),
        grupo(id: 'b', dofItemId: 'dof1', fotoIndex: 2),
        grupo(id: 'c', dofItemId: 'dof1', fotoIndex: 3),
      ];

      final reindexadas = simularReindex(medicoes, 1);
      expect(reindexadas[0].fotoIndex, equals(0)); // não muda
      expect(reindexadas[1].fotoIndex, equals(1)); // 2 → 1
      expect(reindexadas[2].fotoIndex, equals(2)); // 3 → 2
    });

    test('remover última foto não afeta as demais', () {
      final medicoes = [
        grupo(id: 'a', dofItemId: 'dof1', fotoIndex: 0),
        grupo(id: 'b', dofItemId: 'dof1', fotoIndex: 1),
      ];

      final reindexadas = simularReindex(medicoes, 2); // remove a que seria índice 2
      expect(reindexadas[0].fotoIndex, equals(0));
      expect(reindexadas[1].fotoIndex, equals(1));
    });

    test('medições de dofItem diferente não são afetadas', () {
      // Apenas medições com o mesmo dofItemId devem ser reindexadas
      // (o filtro por dofItemId ocorre na query do banco, mas validamos aqui
      // que o modelo não tem efeito cruzado)
      final m1 = grupo(id: 'a', dofItemId: 'dof1', fotoIndex: 1);
      final m2 = grupo(id: 'b', dofItemId: 'dof2', fotoIndex: 1);

      // Simulando reindex só para dof1
      final medicoesDof1 = [m1];
      final reindexadas = simularReindex(medicoesDof1, 0);
      expect(reindexadas[0].fotoIndex, equals(0)); // dof1: índice decrementou

      // dof2 não foi reindexado (não estava na lista filtrada)
      expect(m2.fotoIndex, equals(1)); // intacto
    });
  });

  // ── Volume Total ─────────────────────────────────────────────────────────────

  group('Cálculo de volume total da sessão', () {
    test('soma volumes de múltiplos grupos de fotos diferentes', () {
      final grupos = [
        grupo(id: 'a', dofItemId: 'dof1', fotoIndex: 0,
            comprimentoM: 3.0, larguraCm: 30.0, alturaCm: 5.0, quantidade: 2),
        grupo(id: 'b', dofItemId: 'dof1', fotoIndex: 1,
            comprimentoM: 3.0, larguraCm: 15.0, alturaCm: 5.0, quantidade: 3),
      ];

      final volumeTotal = grupos.fold<double>(
        0.0,
        (sum, m) => sum + FormattingConverter.calcularVolume(
          larguraCm: m.larguraCm,
          alturaCm: m.alturaCm,
          comprimentoM: m.comprimentoM,
          quantidade: m.quantidade,
        ),
      );

      // Foto 0: 3.0 × 0.30 × 0.05 × 2 = 0.090
      // Foto 1: 3.0 × 0.15 × 0.05 × 3 = 0.0675
      // Total: 0.1575
      expect(volumeTotal, closeTo(0.1575, 1e-9));
    });

    test('volume total zero quando não há grupos', () {
      final grupos = <MedicaoGrupoModel>[];
      final volumeTotal = grupos.fold<double>(
        0.0,
        (sum, m) => sum + FormattingConverter.calcularVolume(
          larguraCm: m.larguraCm,
          alturaCm: m.alturaCm,
          comprimentoM: m.comprimentoM,
          quantidade: m.quantidade,
        ),
      );
      expect(volumeTotal, equals(0.0));
    });
  });

  // ── Consistência de fotoIndex ────────────────────────────────────────────────

  group('Integridade de fotoIndex', () {
    test('fotoIndex é preservado ao criar MedicaoGrupoModel', () {
      final m = grupo(id: 'x', dofItemId: 'dof1', fotoIndex: 3);
      expect(m.fotoIndex, equals(3));
      expect(m.dofItemId, equals('dof1'));
    });

    test('grupos com mesmo dofItemId mas fotoIndex diferentes são independentes', () {
      final m0 = grupo(id: 'a', dofItemId: 'dof1', fotoIndex: 0, larguraCm: 30.0);
      final m1 = grupo(id: 'b', dofItemId: 'dof1', fotoIndex: 1, larguraCm: 15.0);

      // A chave de lookup é (dofItemId, fotoIndex) — grupos diferentes não se conflitam
      expect(m0.fotoIndex == m1.fotoIndex, isFalse);
    });
  });
}
