import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fiscaliza/core/database/database_providers.dart';
import 'package:fiscaliza/features/dof/data/dof_providers.dart';
import 'package:fiscaliza/features/dof/data/models/dof_item_model.dart';
import 'package:fiscaliza/features/fiscalizacao/data/fiscalizacao_repository.dart';
import 'package:fiscaliza/features/fiscalizacao/data/fiscalizacao_sessao_repository.dart';
import 'package:fiscaliza/features/fiscalizacao/data/models/fiscalizacao_registro_model.dart';
import 'package:fiscaliza/features/fiscalizacao/data/models/fiscalizacao_sessao_model.dart';
import 'package:fiscaliza/features/fiscalizacao/domain/entities/status_fiscalizacao.dart';

final fiscalizacaoRepositoryProvider =
    Provider<FiscalizacaoRepository>((ref) {
  final isarService = ref.watch(isarServiceProvider);
  return FiscalizacaoRepository(isarService);
});

final registroPorItemProvider =
    FutureProvider.family<FiscalizacaoRegistroModel?, String>(
  (ref, dofItemId) {
    final ds = ref.watch(fiscalizacaoRepositoryProvider);
    return ds.getByDofItemId(dofItemId);
  },
);

final fiscalizacaoSessaoRepositoryProvider =
    Provider<FiscalizacaoSessaoRepository>((ref) {
  final isarService = ref.watch(isarServiceProvider);
  return FiscalizacaoSessaoRepository(isarService);
});

final sessaoAtivaProvider = FutureProvider<FiscalizacaoSessaoModel?>((ref) {
  final ds = ref.watch(fiscalizacaoSessaoRepositoryProvider);
  return ds.getSessaoAtiva();
});

final sessoesRecentesProvider =
    FutureProvider<List<FiscalizacaoSessaoModel>>((ref) {
  final ds = ref.watch(fiscalizacaoSessaoRepositoryProvider);
  return ds.getSessoesRecentes();
});

final itensDaSessaoAtivaProvider = Provider<List<DofItemModel>>((ref) {
  final sessaoAtiva = ref.watch(sessaoAtivaProvider).value;
  if (sessaoAtiva == null) return const [];
  final todosOsItens = ref.watch(parsedDofItemsProvider);
  return todosOsItens
      .where((item) => item.sessaoId == sessaoAtiva.id)
      .toList();
});

final progressoSessaoAtivaProvider =
    FutureProvider<(int concluidos, int total)>((ref) async {
  final itens = ref.watch(itensDaSessaoAtivaProvider);
  if (itens.isEmpty) return (0, 0);
  final ds = ref.watch(fiscalizacaoRepositoryProvider);
  final registros = await Future.wait(
    itens.map((item) => ds.getByDofItemId(item.id)),
  );
  final concluidos = registros
      .where((r) =>
          r?.status == StatusFiscalizacao.concluido ||
          r?.status == StatusFiscalizacao.excedente)
      .length;
  return (concluidos, itens.length);
});

final resumoSessaoAtivaProvider = FutureProvider<
    (int total, int concluidos, int excedentes, int pendentes)>((ref) async {
  final itens = ref.watch(itensDaSessaoAtivaProvider);
  if (itens.isEmpty) return (0, 0, 0, 0);
  final ds = ref.watch(fiscalizacaoRepositoryProvider);
  final registros = await Future.wait(
    itens.map((item) => ds.getByDofItemId(item.id)),
  );
  var concluidos = 0;
  var excedentes = 0;
  var pendentes = 0;
  for (final r in registros) {
    switch (r?.status) {
      case StatusFiscalizacao.concluido:
        concluidos++;
        break;
      case StatusFiscalizacao.excedente:
        excedentes++;
        break;
      case StatusFiscalizacao.emAndamento:
      case StatusFiscalizacao.pendente:
      case null:
        pendentes++;
        break;
    }
  }
  return (itens.length, concluidos, excedentes, pendentes);
});
