import 'package:isar/isar.dart';

part 'medicao_grupo_model.g.dart';

@Collection()
class MedicaoGrupoModel {
  Id isarId = Isar.autoIncrement;

  late String id;
  late String dofItemId;
  late int fotoIndex;
  late double comprimentoM;
  late double larguraCm;
  late double alturaCm;
  late int quantidade;
  late bool isPrincipal;

  MedicaoGrupoModel({
    required this.id,
    required this.dofItemId,
    required this.fotoIndex,
    required this.comprimentoM,
    required this.larguraCm,
    required this.alturaCm,
    required this.quantidade,
    required this.isPrincipal,
  });
}
