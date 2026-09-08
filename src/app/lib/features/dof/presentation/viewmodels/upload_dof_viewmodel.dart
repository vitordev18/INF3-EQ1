import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import 'package:app/features/dof/data/models/dof_item_model.dart';
import 'package:app/features/dof/data/services/csv_parser_service.dart';
import 'package:app/features/dof/data/services/excel_parser_service.dart';
import 'package:app/features/dof/presentation/providers/dof_providers.dart';
import 'package:app/features/fiscalizacao/data/models/fiscalizacao_sessao_model.dart';
import 'package:app/features/fiscalizacao/presentation/providers/fiscalizacao_providers.dart';

const Object _sentinel = Object();

/// Resultado de [UploadDofViewModel.confirmarESalvar]. Sealed para que a tela
/// seja obrigada (via switch exaustivo) a tratar o caso em que já existe uma
/// fiscalização em andamento, em vez de simplesmente ignorá-la como o antigo
/// contrato `Future<bool>` permitia.
sealed class ConfirmarESalvarResultado {}

/// Já existe uma sessão ativa (fiscalização em andamento). A tela deve
/// perguntar ao usuário se quer encerrá-la e, em caso positivo, chamar
/// `confirmarESalvar(encerrarAnterior: true)` novamente.
class PrecisaConfirmarEncerramento extends ConfirmarESalvarResultado {
  final FiscalizacaoSessaoModel sessaoAtiva;
  PrecisaConfirmarEncerramento(this.sessaoAtiva);
}

class SalvouComSucesso extends ConfirmarESalvarResultado {}

class ErroAoSalvar extends ConfirmarESalvarResultado {
  final String mensagem;
  ErroAoSalvar(this.mensagem);
}

class UploadDofState {
  final bool isImporting;
  final bool isSaving;
  final String? statusMessage;
  final bool isError;
  final List<DofItemModel> parsedItems;
  final String madeireiraNome;

  const UploadDofState({
    this.isImporting = false,
    this.isSaving = false,
    this.statusMessage,
    this.isError = false,
    this.parsedItems = const [],
    this.madeireiraNome = '',
  });

  bool get canConfirm =>
      parsedItems.isNotEmpty &&
      madeireiraNome.trim().isNotEmpty &&
      !isImporting &&
      !isSaving;

  UploadDofState copyWith({
    bool? isImporting,
    bool? isSaving,
    Object? statusMessage = _sentinel,
    bool? isError,
    List<DofItemModel>? parsedItems,
    String? madeireiraNome,
  }) =>
      UploadDofState(
        isImporting: isImporting ?? this.isImporting,
        isSaving: isSaving ?? this.isSaving,
        statusMessage: statusMessage == _sentinel
            ? this.statusMessage
            : statusMessage as String?,
        isError: isError ?? this.isError,
        parsedItems: parsedItems ?? this.parsedItems,
        madeireiraNome: madeireiraNome ?? this.madeireiraNome,
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

  void setMadeireiraNome(String value) {
    state = state.copyWith(madeireiraNome: value);
  }

  /// Cria uma nova sessão de fiscalização para os itens já importados
  /// ([state.parsedItems]) e os persiste carimbados com o `sessaoId` dessa
  /// sessão — substitui o antigo `clearAll()` (que apagava a fiscalização
  /// anterior a cada import).
  ///
  /// Se já existir uma sessão ativa, retorna [PrecisaConfirmarEncerramento]
  /// em vez de salvar; a tela deve perguntar ao usuário e, se ele confirmar,
  /// chamar este método de novo com `encerrarAnterior: true` para de fato
  /// encerrar a sessão anterior (calculando seus snapshots finais) antes de
  /// abrir a nova.
  Future<ConfirmarESalvarResultado> confirmarESalvar({
    bool encerrarAnterior = false,
  }) async {
    final sessaoDatasource = ref.read(fiscalizacaoSessaoLocalDatasourceProvider);
    final sessaoAtiva = await sessaoDatasource.getSessaoAtiva();

    if (sessaoAtiva != null && !encerrarAnterior) {
      return PrecisaConfirmarEncerramento(sessaoAtiva);
    }

    state = state.copyWith(isSaving: true);
    try {
      if (sessaoAtiva != null) {
        await sessaoDatasource.encerrarSessao(sessaoAtiva.id);
      }

      final novaSessao = await sessaoDatasource.criarSessao(
        state.madeireiraNome.trim(),
      );

      final itensComSessao = state.parsedItems
          .map((item) => item.copyWith(sessaoId: novaSessao.id))
          .toList();

      final datasource = ref.read(dofLocalDatasourceProvider);
      await datasource.saveDofItems(itensComSessao);
      ref.read(parsedDofItemsProvider.notifier).updateItems(itensComSessao);

      ref.invalidate(sessaoAtivaProvider);
      ref.invalidate(sessoesRecentesProvider);

      return SalvouComSucesso();
    } catch (e) {
      final mensagem = 'Erro ao salvar no banco de dados: $e';
      state = state.copyWith(statusMessage: mensagem, isError: true);
      return ErroAoSalvar(mensagem);
    } finally {
      state = state.copyWith(isSaving: false);
    }
  }
}
