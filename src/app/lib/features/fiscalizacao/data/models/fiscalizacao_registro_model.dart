import 'package:isar/isar.dart';
import 'package:app/features/fiscalizacao/domain/entities/status_fiscalizacao.dart';

part 'fiscalizacao_registro_model.g.dart';

@Collection()
class FiscalizacaoRegistroModel {
  Id isarId = Isar.autoIncrement;

  late String id;
  late String dofItemId;
  late int contagemTotal;
  late List<String> fotoPaths;
  late DateTime dataCaptura;

  /// JSON-encoded `List<Recognition>` por foto.
  /// Índice alinhado com fotoPaths. Default [] garante compatibilidade com registros antigos.
  List<String> detecoesPorFoto = [];

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
  });
}
