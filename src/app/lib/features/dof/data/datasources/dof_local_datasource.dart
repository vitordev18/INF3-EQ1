import '../models/dof_item_model.dart';
import 'package:isar/isar.dart';
import '../../../../core/services/isar_service.dart';

class DofLocalDatasource {
  final IsarService _isarService;

  DofLocalDatasource(this._isarService);

  /// Salva uma lista inteira de itens lidos da planilha
  Future<void> saveDofItems(List<DofItemModel> items) async {
    final isar = await _isarService.db;
    
    // writeTxn é usado para qualquer operação de escrita
    await isar.writeTxn(() async {
      await isar.dofItemModels.putAll(items);
    });
  }

  /// Busca todos os dados para mostrar na tela
  Future<List<DofItemModel>> getAllDofs() async {
    final isar = await _isarService.db;
    return await isar.dofItemModels.where().findAll();
  }

  /// Limpa o banco (útil antes de importar uma nova planilha)
  Future<void> clearAll() async {
    final isar = await _isarService.db;
    await isar.writeTxn(() async {
      await isar.dofItemModels.clear();
    });
  }
}