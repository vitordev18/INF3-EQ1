import 'package:isar/isar.dart';

part 'fiscalizacao_sessao_model.g.dart';

/// Representa um lote/visita de fiscalização: o conjunto de [DofItemModel]
/// importados juntos (uma planilha DOF) para uma madeireira, do início do
/// import até o "Concluir Fiscalização".
///
/// Substitui o antigo comportamento de `clearAll()` a cada novo import: em
/// vez de apagar os produtos anteriores, cada import cria uma nova sessão e
/// carimba os itens recém-lidos com [id] via `DofItemModel.sessaoId`.
@Collection()
class FiscalizacaoSessaoModel {
  Id isarId = Isar.autoIncrement;

  late String id;
  late String madeireiraNome;
  late DateTime iniciadaEm;

  /// null enquanto a sessão está em andamento.
  DateTime? concluidaEm;

  /// Só deve haver uma sessão com ativa=true por vez (regra aplicada pelo
  /// datasource, não pelo Isar).
  bool ativa = true;

  /// Preenchidos apenas ao encerrar a sessão (ver
  /// FiscalizacaoSessaoLocalDatasource.encerrarSessao), para que o Hub de
  /// Início e o futuro Histórico não dependam de reconsultar/recalcular a
  /// partir dos registros de produto, que podem futuramente ser limpos.
  int? itensTotalSnapshot;
  int? itensConcluidosSnapshot;
  int? itensExcedentesSnapshot;
  int? itensPendentesSnapshot;

  /// Soma de `FiscalizacaoRegistroModel.volumeTotalM3` de todos os itens da
  /// sessão, carimbada no mesmo instante que os snapshots acima (ver
  /// [FiscalizacaoSessaoLocalDatasource.encerrarSessao]). Alimenta o texto
  /// "X,X m³ fiscalizados" da lista "Últimas Fiscalizações" do Hub de Início
  /// sem precisar reconsultar os registros de produto.
  double? volumeTotalSnapshot;

  FiscalizacaoSessaoModel({
    required this.id,
    required this.madeireiraNome,
    required this.iniciadaEm,
    this.concluidaEm,
    this.ativa = true,
    this.itensTotalSnapshot,
    this.itensConcluidosSnapshot,
    this.itensExcedentesSnapshot,
    this.itensPendentesSnapshot,
    this.volumeTotalSnapshot,
  });

  @ignore
  bool get concluida => concluidaEm != null;
}
