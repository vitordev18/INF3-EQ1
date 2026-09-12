import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fiscaliza/core/database/database_providers.dart';
import 'package:fiscaliza/features/dof/data/dof_repository.dart';
import 'package:fiscaliza/features/dof/data/models/dof_item_model.dart';

final dofRepositoryProvider = Provider<DofRepository>((ref) {
  final isarService = ref.watch(isarServiceProvider);
  return DofRepository(isarService);
});

class ParsedDofItemsNotifier extends Notifier<List<DofItemModel>> {
  @override
  List<DofItemModel> build() {
    _hydrate();
    return [];
  }

  Future<void> _hydrate() async {
    final datasource = ref.read(dofRepositoryProvider);
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
