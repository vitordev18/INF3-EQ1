import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import 'package:app/core/utils/formatting_converter.dart';
import 'package:app/features/dof/data/models/dof_item_model.dart';
import 'package:app/features/fiscalizacao/data/datasources/fiscalizacao_local_datasource.dart';
import 'package:app/features/fiscalizacao/data/models/medicao_grupo_model.dart';
import 'package:app/features/fiscalizacao/presentation/providers/fiscalizacao_providers.dart';

const Object _sentinel = Object();

const List<Map<String, dynamic>> tamanhosComuns = [
  {'nome': 'Prancha', 'comp': 300.0, 'larg': 30.0, 'alt': 5.0},
  {'nome': 'Viga', 'comp': 300.0, 'larg': 15.0, 'alt': 5.0},
  {'nome': 'Caibro', 'comp': 300.0, 'larg': 5.0, 'alt': 5.0},
  {'nome': 'Tábua', 'comp': 300.0, 'larg': 30.0, 'alt': 2.5},
  {'nome': 'Ripa', 'comp': 300.0, 'larg': 5.0, 'alt': 1.5},
];

class MedidasState {
  final List<MedicaoGrupoModel> listaMedidas;
  final int? indexEmEdicao;
  final bool isSaving;
  final bool isNavigating;
  final bool isLoading;
  final int currentFotoIndex;
  final String especieTexto;

  const MedidasState({
    this.listaMedidas = const [],
    this.indexEmEdicao,
    this.isSaving = false,
    this.isNavigating = false,
    this.isLoading = true,
    this.currentFotoIndex = 0,
    this.especieTexto = 'Espécie não identificada',
  });

  bool get emEdicao => indexEmEdicao != null;

  int get totalPecasMedidas =>
      listaMedidas.fold(0, (soma, item) => soma + item.quantidade);

  MedidasState copyWith({
    List<MedicaoGrupoModel>? listaMedidas,
    Object? indexEmEdicao = _sentinel,
    bool? isSaving,
    bool? isNavigating,
    bool? isLoading,
    int? currentFotoIndex,
    String? especieTexto,
  }) =>
      MedidasState(
        listaMedidas: listaMedidas ?? this.listaMedidas,
        indexEmEdicao: indexEmEdicao == _sentinel
            ? this.indexEmEdicao
            : indexEmEdicao as int?,
        isSaving: isSaving ?? this.isSaving,
        isNavigating: isNavigating ?? this.isNavigating,
        isLoading: isLoading ?? this.isLoading,
        currentFotoIndex: currentFotoIndex ?? this.currentFotoIndex,
        especieTexto: especieTexto ?? this.especieTexto,
      );
}

final medidasViewModelProvider =
    AutoDisposeNotifierProvider<MedidasViewModel, MedidasState>(
  MedidasViewModel.new,
);

class MedidasViewModel extends AutoDisposeNotifier<MedidasState> {
  late FiscalizacaoLocalDatasource _ds;
  late DofItemModel _dofItem;

  final comprimentoController = TextEditingController();
  final larguraController = TextEditingController();
  final alturaController = TextEditingController();
  final quantidadeController = TextEditingController();

  @override
  MedidasState build() {
    _ds = ref.read(fiscalizacaoLocalDatasourceProvider);
    ref.onDispose(() {
      comprimentoController.dispose();
      larguraController.dispose();
      alturaController.dispose();
      quantidadeController.dispose();
    });
    return const MedidasState();
  }

  Future<void> initialize(DofItemModel dofItem, int fotoIndex) async {
    _dofItem = dofItem;
    state = state.copyWith(
      currentFotoIndex: fotoIndex,
      especieTexto: _montarEspecieTexto(dofItem),
      isLoading: true,
    );
    final salvos = await _ds.getMedicoesDaFoto(dofItem.id, fotoIndex);
    state = state.copyWith(
      listaMedidas: List<MedicaoGrupoModel>.from(salvos),
      isLoading: false,
    );
  }

  String _montarEspecieTexto(DofItemModel dofItem) {
    final nomePopular = dofItem.nomePopular.trim();
    final nomeCientifico = dofItem.especieCientifico.trim();
    String texto = '';
    if (nomePopular.isNotEmpty && nomeCientifico.isNotEmpty) {
      texto = '$nomePopular ($nomeCientifico)';
    } else if (nomePopular.isNotEmpty) {
      texto = nomePopular;
    } else if (nomeCientifico.isNotEmpty) {
      texto = nomeCientifico;
    }
    if (dofItem.produto.isNotEmpty) {
      texto += ' - ${dofItem.produto}';
    }
    return texto.isNotEmpty ? texto : 'Espécie não identificada';
  }

  int get yoloCountAtual {
    final capturaState = ref.read(capturaNotifierProvider);
    final idx = state.currentFotoIndex;
    return idx < capturaState.fotos.length ? capturaState.fotos[idx].count : 0;
  }

  int get totalFotosSessao => ref.read(capturaNotifierProvider).fotos.length;

  int get totalCountSessao => ref.read(capturaNotifierProvider).totalCount;

  int get pecasRestantes {
    final yoloCount = yoloCountAtual;
    final total = state.totalPecasMedidas;
    final indexEmEdicao = state.indexEmEdicao;
    if (indexEmEdicao != null) {
      final qtdEditando = state.listaMedidas[indexEmEdicao].quantidade;
      return yoloCount - (total - qtdEditando);
    }
    return yoloCount - total;
  }

  bool get hasUnsavedFormInput =>
      comprimentoController.text.isNotEmpty ||
      larguraController.text.isNotEmpty ||
      alturaController.text.isNotEmpty ||
      quantidadeController.text.isNotEmpty;

  bool get precisaConfirmarSalvarIncompleto =>
      state.totalPecasMedidas < yoloCountAtual;

  double calcularVolumeM3(MedicaoGrupoModel item) =>
      FormattingConverter.calcularVolume(
        larguraCm: item.larguraCm,
        alturaCm: item.alturaCm,
        comprimentoM: item.comprimentoM,
        quantidade: item.quantidade,
      );

  void preencherAtalho(Map<String, dynamic> tamanho) {
    comprimentoController.text = (tamanho['comp'] as double).toStringAsFixed(
      0,
    );
    larguraController.text = (tamanho['larg'] as double)
        .toStringAsFixed(1)
        .replaceAll('.0', '');
    alturaController.text = (tamanho['alt'] as double)
        .toStringAsFixed(1)
        .replaceAll('.0', '');
    if (quantidadeController.text.isEmpty) quantidadeController.text = '1';
  }

  void iniciarEdicao(int index) {
    final item = state.listaMedidas[index];
    comprimentoController.text = (item.comprimentoM * 100).toStringAsFixed(0);
    larguraController.text = item.larguraCm
        .toStringAsFixed(1)
        .replaceAll('.0', '');
    alturaController.text = item.alturaCm
        .toStringAsFixed(1)
        .replaceAll('.0', '');
    quantidadeController.text = item.quantidade.toString();
    state = state.copyWith(indexEmEdicao: index);
  }

  void cancelarEdicao() {
    comprimentoController.clear();
    larguraController.clear();
    alturaController.clear();
    quantidadeController.clear();
    state = state.copyWith(indexEmEdicao: null);
  }

  Future<void> _persistirMedidas() async {
    final snapshot = List<MedicaoGrupoModel>.from(state.listaMedidas);
    await _ds.saveMedicoesDaFoto(_dofItem.id, state.currentFotoIndex, snapshot);
  }

  Future<String?> adicionarNaTabelaLocal() async {
    final qtd = int.tryParse(quantidadeController.text) ?? 0;
    if (qtd <= 0) return 'A quantidade deve ser maior que zero.';
    final restantes = pecasRestantes;
    if (qtd > restantes) {
      return 'Ação bloqueada! Restam apenas $restantes peças.';
    }
    final compCm = double.tryParse(comprimentoController.text) ?? 0.0;
    final largCm = double.tryParse(larguraController.text) ?? 0.0;
    final altCm = double.tryParse(alturaController.text) ?? 0.0;
    if (compCm <= 0 || largCm <= 0 || altCm <= 0) {
      return 'Preencha as dimensões corretamente.';
    }

    final lista = [...state.listaMedidas];
    final indexEmEdicao = state.indexEmEdicao;
    final novoItem = MedicaoGrupoModel(
      id: indexEmEdicao != null ? lista[indexEmEdicao].id : const Uuid().v4(),
      dofItemId: _dofItem.id,
      fotoIndex: state.currentFotoIndex,
      comprimentoM: compCm / 100,
      larguraCm: largCm,
      alturaCm: altCm,
      quantidade: qtd,
      isPrincipal: lista.isEmpty,
    );

    if (indexEmEdicao != null) {
      novoItem.isarId = lista[indexEmEdicao].isarId;
      lista[indexEmEdicao] = novoItem;
    } else {
      final compM = compCm / 100;
      final idxExistente = lista.indexWhere(
        (m) =>
            (m.comprimentoM - compM).abs() < 1e-6 &&
            (m.larguraCm - largCm).abs() < 1e-6 &&
            (m.alturaCm - altCm).abs() < 1e-6,
      );
      if (idxExistente != -1) {
        final existente = lista[idxExistente];
        final merged = MedicaoGrupoModel(
          id: existente.id,
          dofItemId: existente.dofItemId,
          fotoIndex: existente.fotoIndex,
          comprimentoM: existente.comprimentoM,
          larguraCm: existente.larguraCm,
          alturaCm: existente.alturaCm,
          quantidade: existente.quantidade + qtd,
          isPrincipal: existente.isPrincipal,
        )..isarId = existente.isarId;
        lista[idxExistente] = merged;
      } else {
        lista.add(novoItem);
      }
    }

    comprimentoController.clear();
    larguraController.clear();
    alturaController.clear();
    quantidadeController.clear();

    state = state.copyWith(listaMedidas: lista, indexEmEdicao: null);
    await _persistirMedidas();
    return null;
  }

  Future<void> removerItem(int index) async {
    final lista = [...state.listaMedidas]..removeAt(index);
    final eraEdicaoDoRemovido = state.indexEmEdicao == index;
    if (eraEdicaoDoRemovido) {
      comprimentoController.clear();
      larguraController.clear();
      alturaController.clear();
      quantidadeController.clear();
    }
    state = eraEdicaoDoRemovido
        ? state.copyWith(listaMedidas: lista, indexEmEdicao: null)
        : state.copyWith(listaMedidas: lista);
    await _persistirMedidas();
  }

  Future<void> irParaFoto(int novoIndex) async {
    if (state.isNavigating || novoIndex == state.currentFotoIndex) return;
    state = state.copyWith(isNavigating: true);

    final salvos = await _ds.getMedicoesDaFoto(_dofItem.id, novoIndex);

    comprimentoController.clear();
    larguraController.clear();
    alturaController.clear();
    quantidadeController.clear();

    state = state.copyWith(
      currentFotoIndex: novoIndex,
      listaMedidas: List<MedicaoGrupoModel>.from(salvos),
      indexEmEdicao: null,
      isNavigating: false,
    );
  }

  Future<bool> salvar() async {
    if (state.isSaving) return false;
    state = state.copyWith(isSaving: true);
    try {
      final capturaState = ref.read(capturaNotifierProvider);
      await _ds.recalcularEPersistirVolume(_dofItem, capturaState.totalCount);
      ref.invalidate(registroPorItemProvider(_dofItem.id));
      await ref.read(registroPorItemProvider(_dofItem.id).future);
      return true;
    } catch (e) {
      debugPrint('[Medidas] Erro ao salvar dados: $e');
      return false;
    } finally {
      state = state.copyWith(isSaving: false);
    }
  }
}
