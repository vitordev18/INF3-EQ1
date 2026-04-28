import '../models/dof_item_model.dart';
import 'package:isar/isar.dart';
import '../../../../core/services/isar_service.dart';

class DofLocalDatasource {
  final IsarService _isarService;

  DofLocalDatasource(this._isarService);

  Future<void> saveDofItems(List<DofItemModel> items) async {
    final isar = await _isarService.db;

    await isar.writeTxn(() async {
      await isar.dofItemModels.putAll(items);
    });
  }

  Future<List<DofItemModel>> getAllDofs() async {
    final isar = await _isarService.db;
    return await isar.dofItemModels.where().findAll();
  }

  Future<void> clearAll() async {
    final isar = await _isarService.db;
    await isar.writeTxn(() async {
      await isar.dofItemModels.clear();
    });
  }
}
