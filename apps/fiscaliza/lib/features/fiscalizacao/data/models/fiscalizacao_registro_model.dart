import 'package:isar/isar.dart';
import 'package:fiscaliza/features/fiscalizacao/domain/entities/status_fiscalizacao.dart';

part 'fiscalizacao_registro_model.g.dart';

@Collection()
class FiscalizacaoRegistroModel {
  Id isarId = Isar.autoIncrement;

  late String id;
  late String dofItemId;
  late int contagemTotal;
  late List<String> fotoPaths;
  late DateTime dataCaptura;

  List<String> detecoesPorFoto = [];

  List<String> regioesPorFoto = [];

  /// Soma do volume cubado dos grupos de medição; 0.0 enquanto o fiscal não
  /// preencher a tela de Medidas.
  double volumeTotalM3 = 0.0;

  @enumerated
  late StatusFiscalizacao status;

  FiscalizacaoRegistroModel({
    required this.id,
    required this.dofItemId,
    required this.contagemTotal,
    required this.fotoPaths,
    required this.dataCaptura,
    required this.status,
    this.detecoesPorFoto = const [],
    this.regioesPorFoto = const [],
    this.volumeTotalM3 = 0.0,
  });
}
