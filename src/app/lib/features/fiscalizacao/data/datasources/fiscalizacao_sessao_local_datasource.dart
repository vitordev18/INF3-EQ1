import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/services/isar_service.dart';
import '../../../dof/data/models/dof_item_model.dart';
import '../../domain/entities/status_fiscalizacao.dart';
import '../models/fiscalizacao_registro_model.dart';
import '../models/fiscalizacao_sessao_model.dart';

/// Datasource responsável pelo ciclo de vida de [FiscalizacaoSessaoModel]:
/// abrir uma sessão a cada novo import DOF, encerrá-la ao concluir a
/// fiscalização, e listar sessões para o Hub de Início / futuro Histórico.
///
/// Substitui o antigo `DofLocalDatasource.clearAll()`: em vez de apagar os
/// produtos da fiscalização anterior a cada novo import, cada import agora
/// cria uma sessão nova e os `DofItemModel` ficam carimbados com
/// `sessaoId`, preservando o histórico.
class FiscalizacaoSessaoLocalDatasource {
  final IsarService _isarService;

  FiscalizacaoSessaoLocalDatasource(this._isarService);

  /// Cria uma nova sessão (madeireira + timestamp de início) e a marca como
  /// ativa.
  ///
  /// Só deve haver uma sessão ativa por vez (regra documentada no próprio
  /// [FiscalizacaoSessaoModel]). O fluxo normal — ver
  /// `UploadDofViewModel.confirmarESalvar` — chama [getSessaoAtiva] antes,
  /// pergunta ao usuário se quer encerrar a fiscalização em andamento e, em
  /// caso positivo, chama [encerrarSessao] explicitamente (o que calcula os
  /// snapshots a partir dos registros reais) antes de chamar este método.
  ///
  /// Como rede de segurança contra estados inconsistentes (ex.: uma sessão
  /// ativa "esquecida" por um bug ou fluxo interrompido), qualquer sessão
  /// ainda ativa é desativada aqui — mas SEM carimbar `concluidaEm` nem
  /// snapshots, para não ser exibida no histórico como se tivesse sido
  /// encerrada corretamente (ver filtro em [getSessoesRecentes]). Ela
  /// simplesmente deixa de ser a sessão ativa e de aparecer na home.
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

  /// Retorna a sessão ativa no momento (a fiscalização em andamento exibida
  /// no banner de aviso do Hub de Início), se houver.
  Future<FiscalizacaoSessaoModel?> getSessaoAtiva() async {
    final isar = await _isarService.db;
    return await isar.fiscalizacaoSessaoModels
        .filter()
        .ativaEqualTo(true)
        .findFirst();
  }

  /// Encerra a sessão indicada: recalcula os 4 snapshots a partir dos
  /// [DofItemModel] carimbados com esse `sessaoId` e dos
  /// [FiscalizacaoRegistroModel] associados a cada um, marca `ativa=false`
  /// e carimba `concluidaEm`. Chamado pela ConcluirFiscalizacaoScreen.
  ///
  /// Um item sem registro (nunca fotografado) ou com status `emAndamento`
  /// conta como "pendente" no snapshot final — ao concluir a fiscalização,
  /// tudo que não terminou como concluído/excedente fica registrado como
  /// pendente no histórico (mesma regra do aviso exibido na tela de
  /// conclusão).
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

  /// Sessões concluídas mais recentes primeiro, para a lista "Últimas
  /// Fiscalizações" do Hub de Início.
  ///
  /// Só inclui sessões com `concluidaEm != null`: sessões abandonadas (uma
  /// nova iniciada sem passar por "Concluir Fiscalização") não têm snapshot
  /// e não fazem sentido nessa lista — ver nota em [criarSessao].
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
