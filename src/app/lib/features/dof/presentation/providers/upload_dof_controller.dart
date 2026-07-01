import 'dart:io';
import 'package:app/features/dof/data/models/dof_item_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import '../../data/services/excel_parser_service.dart';
import '../../data/services/csv_parser_service.dart';
import '../../data/datasources/dof_local_datasource.dart';
import 'dof_providers.dart';

class UploadDofState {
  final bool isLoading;
  final String? error;
  final bool isSuccess;

  UploadDofState({this.isLoading = false, this.error, this.isSuccess = false});
}

class UploadDofController extends StateNotifier<UploadDofState> {
  final DofLocalDatasource _datasource;

  UploadDofController(this._datasource) : super(UploadDofState());

  Future<void> processFile(File file) async {
    state = UploadDofState(isLoading: true);

    try {
      final extension = p.extension(file.path).toLowerCase();
      List<DofItemModel> items = [];

      if (extension == '.xlsx' || extension == '.xls') {
        items = await ExcelParserService.parseFile(file: file);
      } else if (extension == '.csv') {
        items = await CsvParserService.parseFile(file: file);
      } else {
        throw Exception('Formato de arquivo não suportado: $extension');
      }

      if (items.isNotEmpty) {
        await _datasource.saveDofItems(items);
        state = UploadDofState(isSuccess: true);
      } else {
        throw Exception('Nenhum dado válido encontrado no arquivo.');
      }

    } catch (e) {
      state = UploadDofState(error: e.toString());
    }
  }
}

final uploadDofControllerProvider = StateNotifierProvider<UploadDofController, UploadDofState>((ref) {
  final datasource = ref.watch(dofLocalDatasourceProvider);
  return UploadDofController(datasource);
});
