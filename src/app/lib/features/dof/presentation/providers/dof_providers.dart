import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/isar_service.dart';
import '../../data/datasources/dof_local_datasource.dart';

final isarServiceProvider = Provider<IsarService>((ref) {
  return IsarService();
});

final dofLocalDatasourceProvider = Provider<DofLocalDatasource>((ref) {
  final isarService = ref.watch(isarServiceProvider);
  return DofLocalDatasource(isarService);
});
