import 'package:isar/isar.dart';
import '../../../../core/services/isar_service.dart';
import '../models/fiscalizacao_registro_model.dart';

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
      final existing = await isar.fiscalizacaoRegistroModels
          .filter()
          .dofItemIdEqualTo(dofItemId)
          .findFirst();
      if (existing != null) {
        await isar.fiscalizacaoRegistroModels.delete(existing.isarId);
      }
    });
  }
}
