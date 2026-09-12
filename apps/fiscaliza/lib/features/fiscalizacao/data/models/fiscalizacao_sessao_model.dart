import 'package:isar/isar.dart';

part 'fiscalizacao_sessao_model.g.dart';

@Collection()
/// Lote de uma visita de fiscalização: os itens importados de uma mesma
/// planilha DOF para uma madeireira, do início do import até o encerramento.
class FiscalizacaoSessaoModel {
  Id isarId = Isar.autoIncrement;

  late String id;
  late String madeireiraNome;
  late DateTime iniciadaEm;

  DateTime? concluidaEm;

  /// Só pode haver uma sessão ativa por vez.
  bool ativa = true;

  int? itensTotalSnapshot;
  int? itensConcluidosSnapshot;
  int? itensExcedentesSnapshot;
  int? itensPendentesSnapshot;

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
