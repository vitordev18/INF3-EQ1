import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../../features/dof/data/models/dof_item_model.dart';

class IsarService {
  late Future<Isar> db;

  IsarService() {
    db = openDB();
  }

  Future<Isar> openDB() async {
    // Evita abrir instâncias duplicadas no Flutter
    if (Isar.instanceNames.isEmpty) {
      final dir = await getApplicationDocumentsDirectory();
      return await Isar.open(
        [DofItemModelSchema], // Schema que acabamos de gerar
        directory: dir.path,
        inspector: true, // Habilita o painel de debug do Isar
      );
    }
    return Future.value(Isar.getInstance());
  }
}