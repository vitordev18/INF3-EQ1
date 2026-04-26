import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p; // Necessário para pegar a extensão do arquivo
// Importe seus parsers e datasource
import '../../data/services/excel_parser_service.dart';
import '../../data/services/csv_parser_service.dart';
import '../../data/datasources/dof_local_datasource.dart';
import 'dof_providers.dart'; 

// Usando o StateNotifier para controlar o estado da tela (Carregando, Sucesso, Erro)
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
    // Atualiza a tela para mostrar um loading
    state = UploadDofState(isLoading: true);

    try {
      final extension = p.extension(file.path).toLowerCase();
      List<DofItemModel> items = [];

      // 1. Identifica o tipo de arquivo e chama o parser correto que você já fez!
      if (extension == '.xlsx' || extension == '.xls') {
        items = await ExcelParserService.parseFile(file: file);
      } else if (extension == '.csv') {
        items = await CsvParserService.parseFile(file: file);
      } else {
        throw Exception('Formato de arquivo não suportado: $extension');
      }

      // 2. Salva os itens retornados pelo parser direto no banco Isar
      if (items.isNotEmpty) {
        await _datasource.saveDofItems(items);
        // Atualiza a tela para sucesso
        state = UploadDofState(isSuccess: true);
      } else {
        throw Exception('Nenhum dado válido encontrado no arquivo.');
      }

    } catch (e) {
      // Se der erro no parse ou no banco, mostra na tela
      state = UploadDofState(error: e.toString());
    }
  }
}

// O provider que vai expor esse controller para a sua tela
final uploadDofControllerProvider = StateNotifierProvider<UploadDofController, UploadDofState>((ref) {
  final datasource = ref.watch(dofLocalDatasourceProvider);
  return UploadDofController(datasource);
}); 