import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';
import 'package:fiscaliza/core/database/isar_service.dart';
import 'package:fiscaliza/core/utils/formatting_converter.dart';
import 'package:fiscaliza/features/dof/data/models/dof_item_model.dart';
import 'package:fiscaliza/features/fiscalizacao/data/models/fiscalizacao_registro_model.dart';
import 'package:fiscaliza/features/fiscalizacao/data/models/medicao_grupo_model.dart';
import 'package:fiscaliza/features/fiscalizacao/domain/calculo_status.dart';

class FiscalizacaoRepository {
  final IsarService _isarService;

  FiscalizacaoRepository(this._isarService);

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

  Future<int> getTotalMedidoByDofItem(String dofItemId) async {
    final medicoes = await getMedicoesByDofItem(dofItemId);
    return medicoes.fold<int>(0, (s, m) => s + m.quantidade);
  }

  Future<List<MedicaoGrupoModel>> getMedicoesByDofItem(String dofItemId) async {
    final isar = await _isarService.db;
    return await isar.medicaoGrupoModels
        .filter()
        .dofItemIdEqualTo(dofItemId)
        .findAll();
  }

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

  Future<void> recalcularEPersistirVolume(
    DofItemModel dofItem,
    int contagemTotal,
  ) async {
    final medicoes = await getMedicoesByDofItem(dofItem.id);
    final volume = medicoes.fold<double>(
      0.0,
      (sum, m) => sum + FormattingConverter.calcularVolume(
        larguraCm: m.larguraCm,
        alturaCm: m.alturaCm,
        comprimentoM: m.comprimentoM,
        quantidade: m.quantidade,
      ),
    );

    final totalMedido = medicoes.fold(0, (s, m) => s + m.quantidade);

    final status = calcularStatus(
      volumeMedidoM3: volume,
      saldoDeclaradoM3: dofItem.saldoTotal,
      pecasContadas: contagemTotal,
      pecasMedidas: totalMedido,
    );

    final existing = await getByDofItemId(dofItem.id);
    final registro = FiscalizacaoRegistroModel(
      id: existing?.id ?? const Uuid().v4(),
      dofItemId: dofItem.id,
      contagemTotal: contagemTotal,
      fotoPaths: existing?.fotoPaths ?? const [],
      dataCaptura: existing?.dataCaptura ?? DateTime.now(),
      status: status,
      detecoesPorFoto: existing?.detecoesPorFoto ?? const [],
      regioesPorFoto: existing?.regioesPorFoto ?? const [],
      volumeTotalM3: volume,
    );
    if (existing != null) registro.isarId = existing.isarId;

    await saveRegistro(registro);
  }

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
