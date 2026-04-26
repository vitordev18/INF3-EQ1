import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/isar_service.dart';
import '../../data/datasources/dof_local_datasource.dart';

// --- Adicione estes dois provedores ao seu arquivo ---

// 1. Singleton do Serviço Isar
final isarServiceProvider = Provider<IsarService>((ref) {
  return IsarService();
});

// 2. Provedor do Datasource local que usa o Isar
final dofLocalDatasourceProvider = Provider<DofLocalDatasource>((ref) {
  final isarService = ref.watch(isarServiceProvider);
  return DofLocalDatasource(isarService);
});