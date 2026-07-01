import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/services/isar_service.dart';
import '../../../../core/utils/formatting_converter.dart';
import '../../../dof/data/models/dof_item_model.dart';
import '../models/fiscalizacao_registro_model.dart';
import '../models/medicao_grupo_model.dart';
import '../../domain/entities/status_fiscalizacao.dart';

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

  /// Soma a quantidade de peças medidas em todas as fotos de um DOF item.
  Future<int> getTotalMedidoByDofItem(String dofItemId) async {
    final medicoes = await getMedicoesByDofItem(dofItemId);
    return medicoes.fold<int>(0, (s, m) => s + m.quantidade);
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

  /// Recalcula volume total das medições, deriva o status e persiste o registro.
  /// Cria um registro mínimo se ainda não existir.
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
    final todosMediados = contagemTotal > 0 && totalMedido >= contagemTotal;

    final StatusFiscalizacao status;
    if (!todosMediados || volume == 0.0) {
      status = StatusFiscalizacao.emAndamento;
    } else if (volume <= dofItem.saldoTotal) {
      status = StatusFiscalizacao.concluido;
    } else {
      status = StatusFiscalizacao.excedente;
    }

    final existing = await getByDofItemId(dofItem.id);
    final registro = FiscalizacaoRegistroModel(
      id: existing?.id ?? const Uuid().v4(),
      dofItemId: dofItem.id,
      contagemTotal: contagemTotal,
      fotoPaths: existing?.fotoPaths ?? const [],
      dataCaptura: existing?.dataCaptura ?? DateTime.now(),
      status: status,
      detecoesPorFoto: existing?.detecoesPorFoto ?? const [],
      volumeTotalM3: volume,
    );
    if (existing != null) registro.isarId = existing.isarId;

    await saveRegistro(registro);
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
