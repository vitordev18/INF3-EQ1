import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../../features/dof/data/models/dof_item_model.dart';
import '../../features/fiscalizacao/data/models/fiscalizacao_registro_model.dart';

class IsarService {
  late Future<Isar> db;

  IsarService() {
    db = openDB();
  }

  Future<Isar> openDB() async {
    if (Isar.instanceNames.isEmpty) {
      final dir = await getApplicationDocumentsDirectory();
      return await Isar.open(
        [DofItemModelSchema, FiscalizacaoRegistroModelSchema],
        directory: dir.path,
        inspector: true,
      );
    }
    return Future.value(Isar.getInstance());
  }
}
