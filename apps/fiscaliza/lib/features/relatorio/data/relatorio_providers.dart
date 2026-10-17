import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import 'package:fiscaliza/core/database/database_providers.dart';
import 'package:fiscaliza/features/dof/data/models/dof_item_model.dart';
import 'package:fiscaliza/features/fiscalizacao/data/fiscalizacao_providers.dart';
import 'package:fiscaliza/features/fiscalizacao/data/fiscalizacao_repository.dart';
import 'package:fiscaliza/features/fiscalizacao/data/models/fiscalizacao_registro_model.dart';
import 'package:fiscaliza/features/fiscalizacao/data/models/medicao_grupo_model.dart';
import 'package:fiscaliza/features/fiscalizacao/data/models/fiscalizacao_sessao_model.dart';
import 'package:fiscaliza/features/relatorio/domain/linha_relatorio.dart';
import 'package:fiscaliza/features/relatorio/domain/montar_relatorio.dart';

final relatorioSessaoAtivaProvider = StreamProvider<Relatorio?>((ref) async* {
  final sessao = await ref.watch(sessaoAtivaProvider.future);
  if (sessao == null) {
    yield null;
    return;
  }

  final itens = ref.watch(itensDaSessaoAtivaProvider);
  final repository = ref.watch(fiscalizacaoRepositoryProvider);
  final isar = await ref.watch(isarServiceProvider).db;

  yield await _montar(sessao, itens, repository);

  await for (final _ in _mudancasDaFiscalizacao(isar, ref)) {
    yield await _montar(sessao, itens, repository);
  }
});

Future<Relatorio> _montar(
  FiscalizacaoSessaoModel sessao,
  List<DofItemModel> itens,
  FiscalizacaoRepository repository,
) async {
  final medicoesPorItemId = <String, List<MedicaoGrupoModel>>{};
  for (final item in itens) {
    medicoesPorItemId[item.id] = await repository.getMedicoesByDofItem(item.id);
  }

  return Relatorio(
    cabecalho: CabecalhoRelatorio(
      madeireiraNome: sessao.madeireiraNome,
      cnpj: sessao.madeireiraCnpj,
      endereco: sessao.madeireiraEndereco,
      dataFiscalizacao: sessao.iniciadaEm,
    ),
    linhas: montarRelatorio(itens: itens, medicoesPorItemId: medicoesPorItemId),
  );
}

Stream<void> _mudancasDaFiscalizacao(Isar isar, Ref ref) {
  final controller = StreamController<void>();

  final assinaturas = <StreamSubscription<void>>[
    isar.medicaoGrupoModels.watchLazy().listen(controller.add),
    isar.fiscalizacaoRegistroModels.watchLazy().listen(controller.add),
  ];

  Future<void> encerrar() async {
    for (final assinatura in assinaturas) {
      await assinatura.cancel();
    }
    await controller.close();
  }

  controller.onCancel = encerrar;
  ref.onDispose(encerrar);

  return controller.stream;
}
