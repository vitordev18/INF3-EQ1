import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/isar_service.dart';
import '../../data/datasources/dof_local_datasource.dart';
import '../../data/models/dof_item_model.dart';

final isarServiceProvider = Provider<IsarService>((ref) {
  return IsarService();
});

final dofLocalDatasourceProvider = Provider<DofLocalDatasource>((ref) {
  final isarService = ref.watch(isarServiceProvider);
  return DofLocalDatasource(isarService);
});

class ParsedDofItemsNotifier extends Notifier<List<DofItemModel>> {
  @override
  List<DofItemModel> build() {
    // Cold-start (app recém-aberto ou provider recriado): sem isso, esta
    // lista ficava vazia até o próximo import, mesmo com itens já
    // persistidos no Isar de uma fiscalização em andamento. Devolve [] de
    // imediato (Notifier.build() é síncrono) e hidrata em seguida; quem
    // observa este provider recebe o estado populado assim que a leitura do
    // Isar terminar.
    _hydrate();
    return [];
  }

  Future<void> _hydrate() async {
    final datasource = ref.read(dofLocalDatasourceProvider);
    final itens = await datasource.getAllDofs();
    state = itens;
  }

  void updateItems(List<DofItemModel> items) {
    state = items;
  }
}

final parsedDofItemsProvider =
    NotifierProvider<ParsedDofItemsNotifier, List<DofItemModel>>(
  ParsedDofItemsNotifier.new,
);
