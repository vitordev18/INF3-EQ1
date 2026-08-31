import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import 'package:app/features/dof/data/models/dof_item_model.dart';
import 'package:app/features/dof/data/services/csv_parser_service.dart';
import 'package:app/features/dof/data/services/excel_parser_service.dart';
import 'package:app/features/dof/presentation/providers/dof_providers.dart';

const Object _sentinel = Object();

class UploadDofState {
  final bool isImporting;
  final bool isSaving;
  final String? statusMessage;
  final bool isError;
  final List<DofItemModel> parsedItems;

  const UploadDofState({
    this.isImporting = false,
    this.isSaving = false,
    this.statusMessage,
    this.isError = false,
    this.parsedItems = const [],
  });

  bool get canConfirm =>
      parsedItems.isNotEmpty && !isImporting && !isSaving;

  UploadDofState copyWith({
    bool? isImporting,
    bool? isSaving,
    Object? statusMessage = _sentinel,
    bool? isError,
    List<DofItemModel>? parsedItems,
  }) =>
      UploadDofState(
        isImporting: isImporting ?? this.isImporting,
        isSaving: isSaving ?? this.isSaving,
        statusMessage: statusMessage == _sentinel
            ? this.statusMessage
            : statusMessage as String?,
        isError: isError ?? this.isError,
        parsedItems: parsedItems ?? this.parsedItems,
      );
}

final uploadDofViewModelProvider =
    AutoDisposeNotifierProvider<UploadDofViewModel, UploadDofState>(
  UploadDofViewModel.new,
);

class UploadDofViewModel extends AutoDisposeNotifier<UploadDofState> {
  @override
  UploadDofState build() => const UploadDofState();

  Future<void> pickAndParseFile() async {
    state = state.copyWith(
      isImporting: true,
      statusMessage: 'Aguardando seleção do arquivo...',
      isError: false,
      parsedItems: [],
    );

    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls', 'csv'],
        dialogTitle: 'Selecione a planilha DOF',
      );

      if (result != null && result.files.single.path != null) {
        state = state.copyWith(
          statusMessage: 'Fazendo parsing do arquivo...',
        );

        final file = File(result.files.single.path!);
        final extension = p.extension(file.path).toLowerCase();
        List<DofItemModel> tempItems;

        if (extension == '.xlsx' || extension == '.xls') {
          tempItems = await ExcelParserService.parseFile(file: file);
        } else if (extension == '.csv') {
          tempItems = await CsvParserService.parseFile(file: file);
        } else {
          throw Exception('Formato de arquivo não suportado: $extension');
        }

        if (tempItems.isEmpty) {
          throw Exception(
            'A planilha está vazia ou não contém dados válidos.',
          );
        }

        state = state.copyWith(
          parsedItems: tempItems,
          statusMessage: 'Sucesso: ${tempItems.length} itens lidos.',
          isError: false,
        );
      } else {
        state = state.copyWith(
          statusMessage: 'Seleção cancelada pelo usuário.',
          isError: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        statusMessage: 'Erro ao ler arquivo: ${e.toString()}',
        isError: true,
        parsedItems: [],
      );
    } finally {
      state = state.copyWith(isImporting: false);
    }
  }

  Future<bool> confirmarESalvar() async {
    state = state.copyWith(isSaving: true);
    try {
      final datasource = ref.read(dofLocalDatasourceProvider);
      await datasource.clearAll();
      await datasource.saveDofItems(state.parsedItems);
      ref
          .read(parsedDofItemsProvider.notifier)
          .updateItems(state.parsedItems);
      return true;
    } catch (e) {
      state = state.copyWith(
        statusMessage: 'Erro ao salvar no banco de dados: $e',
        isError: true,
      );
      return false;
    } finally {
      state = state.copyWith(isSaving: false);
    }
  }
}
