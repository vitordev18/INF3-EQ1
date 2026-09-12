import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';
import 'package:fiscaliza/core/database/isar_service.dart';
import 'package:fiscaliza/features/dof/data/models/dof_item_model.dart';
import 'package:fiscaliza/features/fiscalizacao/domain/entities/status_fiscalizacao.dart';
import 'package:fiscaliza/features/fiscalizacao/data/models/fiscalizacao_registro_model.dart';
import 'package:fiscaliza/features/fiscalizacao/data/models/fiscalizacao_sessao_model.dart';

class FiscalizacaoSessaoRepository {
  final IsarService _isarService;

  FiscalizacaoSessaoRepository(this._isarService);

  Future<FiscalizacaoSessaoModel> criarSessao(String madeireiraNome) async {
    final isar = await _isarService.db;
    final sessao = FiscalizacaoSessaoModel(
      id: const Uuid().v4(),
      madeireiraNome: madeireiraNome,
      iniciadaEm: DateTime.now(),
    );
    await isar.writeTxn(() async {
      final ativasAnteriores = await isar.fiscalizacaoSessaoModels
          .filter()
          .ativaEqualTo(true)
          .findAll();
      for (final anterior in ativasAnteriores) {
        anterior.ativa = false;
        await isar.fiscalizacaoSessaoModels.put(anterior);
      }
      await isar.fiscalizacaoSessaoModels.put(sessao);
    });
    return sessao;
  }

  Future<FiscalizacaoSessaoModel?> getSessaoAtiva() async {
    final isar = await _isarService.db;
    return await isar.fiscalizacaoSessaoModels
        .filter()
        .ativaEqualTo(true)
        .findFirst();
  }

  Future<void> encerrarSessao(String sessaoId) async {
    final isar = await _isarService.db;
    final sessao = await isar.fiscalizacaoSessaoModels
        .filter()
        .idEqualTo(sessaoId)
        .findFirst();
    if (sessao == null) return;

    final itens =
        await isar.dofItemModels.filter().sessaoIdEqualTo(sessaoId).findAll();

    int concluidos = 0;
    int excedentes = 0;
    int pendentes = 0;
    double volumeTotal = 0;
    for (final item in itens) {
      final registro = await isar.fiscalizacaoRegistroModels
          .filter()
          .dofItemIdEqualTo(item.id)
          .findFirst();
      volumeTotal += registro?.volumeTotalM3 ?? 0.0;
      switch (registro?.status) {
        case StatusFiscalizacao.concluido:
          concluidos++;
        case StatusFiscalizacao.excedente:
          excedentes++;
        case StatusFiscalizacao.emAndamento:
        case StatusFiscalizacao.pendente:
        case null:
          pendentes++;
      }
    }

    sessao
      ..ativa = false
      ..concluidaEm = DateTime.now()
      ..itensTotalSnapshot = itens.length
      ..itensConcluidosSnapshot = concluidos
      ..itensExcedentesSnapshot = excedentes
      ..itensPendentesSnapshot = pendentes
      ..volumeTotalSnapshot = volumeTotal;

    await isar.writeTxn(() async {
      await isar.fiscalizacaoSessaoModels.put(sessao);
    });
  }

  Future<List<FiscalizacaoSessaoModel>> getSessoesRecentes(
      {int limit = 3}) async {
    final isar = await _isarService.db;
    final concluidas = await isar.fiscalizacaoSessaoModels
        .filter()
        .concluidaEmIsNotNull()
        .findAll();
    concluidas.sort((a, b) => b.concluidaEm!.compareTo(a.concluidaEm!));
    if (concluidas.length > limit) {
      return concluidas.sublist(0, limit);
    }
    return concluidas;
  }
}
