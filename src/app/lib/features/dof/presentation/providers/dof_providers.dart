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
  List<DofItemModel> build() => [];

  void updateItems(List<DofItemModel> items) {
    state = items;
  }
}

final parsedDofItemsProvider =
    NotifierProvider<ParsedDofItemsNotifier, List<DofItemModel>>(
  ParsedDofItemsNotifier.new,
);
