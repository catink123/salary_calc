import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

class DB {
  static late final Database _instance;

  static Future<void> ensureDB() async {
    final dir = await getApplicationDocumentsDirectory();
    final dbPath = join(dir.path, 'salary_calc_database.db');

    _instance = await databaseFactoryIo.openDatabase(dbPath);
  }

  static Database get instance => _instance;
}
