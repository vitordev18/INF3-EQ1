import 'package:isar/isar.dart';
import '../../../../core/services/isar_service.dart';
import '../models/fiscalizacao_registro_model.dart';
import '../models/medicao_grupo_model.dart';

class FiscalizacaoLocalDatasource {
  final IsarService _isarService;

  FiscalizacaoLocalDatasource(this._isarService);

  Future<void> saveRegistro(FiscalizacaoRegistroModel registro) async {
    final isar = await _isarService.db;
    await isar.writeTxn(() async {
      await isar.fiscalizacaoRegistroModels.put(registro);
    });
  }

  Future<FiscalizacaoRegistroModel?> getByDofItemId(String dofItemId) async {
    final isar = await _isarService.db;
    return await isar.fiscalizacaoRegistroModels
        .filter()
        .dofItemIdEqualTo(dofItemId)
        .findFirst();
  }

  Future<List<FiscalizacaoRegistroModel>> getAll() async {
    final isar = await _isarService.db;
    return await isar.fiscalizacaoRegistroModels.where().findAll();
  }

  Future<void> deleteByDofItemId(String dofItemId) async {
    final isar = await _isarService.db;
    await isar.writeTxn(() async {
      // Cascade: remove medições antes de remover o registro
      final medicoes = await isar.medicaoGrupoModels
          .filter()
          .dofItemIdEqualTo(dofItemId)
          .findAll();
      for (final m in medicoes) {
        await isar.medicaoGrupoModels.delete(m.isarId);
      }
      final existing = await isar.fiscalizacaoRegistroModels
          .filter()
          .dofItemIdEqualTo(dofItemId)
          .findFirst();
      if (existing != null) {
        await isar.fiscalizacaoRegistroModels.delete(existing.isarId);
      }
    });
  }

  // ─── MedicaoGrupoModel ──────────────────────────────────────────────────────

  /// Substitui todos os grupos de uma foto específica pelos novos grupos (operação atômica).
  Future<void> saveMedicoesDaFoto(
    String dofItemId,
    int fotoIndex,
    List<MedicaoGrupoModel> grupos,
  ) async {
    final isar = await _isarService.db;
    await isar.writeTxn(() async {
      final existentes = await isar.medicaoGrupoModels
          .filter()
          .dofItemIdEqualTo(dofItemId)
          .and()
          .fotoIndexEqualTo(fotoIndex)
          .findAll();
      for (final g in existentes) {
        await isar.medicaoGrupoModels.delete(g.isarId);
      }
      for (final g in grupos) {
        await isar.medicaoGrupoModels.put(g);
      }
    });
  }

  /// Retorna todos os grupos de medição de um DOF item (todas as fotos).
  Future<List<MedicaoGrupoModel>> getMedicoesByDofItem(String dofItemId) async {
    final isar = await _isarService.db;
    return await isar.medicaoGrupoModels
        .filter()
        .dofItemIdEqualTo(dofItemId)
        .findAll();
  }

  /// Retorna os grupos de medição de uma foto específica.
  Future<List<MedicaoGrupoModel>> getMedicoesDaFoto(
    String dofItemId,
    int fotoIndex,
  ) async {
    final isar = await _isarService.db;
    return await isar.medicaoGrupoModels
        .filter()
        .dofItemIdEqualTo(dofItemId)
        .and()
        .fotoIndexEqualTo(fotoIndex)
        .findAll();
  }

  /// Deleta todos os grupos de medição de uma foto específica.
  Future<void> deleteMedicoesDaFoto(String dofItemId, int fotoIndex) async {
    final isar = await _isarService.db;
    await isar.writeTxn(() async {
      final existentes = await isar.medicaoGrupoModels
          .filter()
          .dofItemIdEqualTo(dofItemId)
          .and()
          .fotoIndexEqualTo(fotoIndex)
          .findAll();
      for (final g in existentes) {
        await isar.medicaoGrupoModels.delete(g.isarId);
      }
    });
  }

  /// Reindexar medições após remoção de foto: decrementa fotoIndex de todos com fotoIndex > removedIndex.
  Future<void> reindexMedicoesAposRemocao(
      String dofItemId, int removedIndex) async {
    final isar = await _isarService.db;
    await isar.writeTxn(() async {
      final afetados = await isar.medicaoGrupoModels
          .filter()
          .dofItemIdEqualTo(dofItemId)
          .findAll();
      for (final m in afetados) {
        if (m.fotoIndex > removedIndex) {
          final atualizado = MedicaoGrupoModel(
            id: m.id,
            dofItemId: m.dofItemId,
            fotoIndex: m.fotoIndex - 1,
            comprimentoM: m.comprimentoM,
            larguraCm: m.larguraCm,
            alturaCm: m.alturaCm,
            quantidade: m.quantidade,
            isPrincipal: m.isPrincipal,
          )..isarId = m.isarId;
          await isar.medicaoGrupoModels.put(atualizado);
        }
      }
    });
  }
}
