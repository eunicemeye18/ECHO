import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;

class DbDefinition {
  Future<Database> createDb() async {
    var dbPath = await sql.getDatabasesPath();
    final db = await sql.openDatabase(
      path.join(dbPath, "nomDeLaBase.db"),
      onCreate: (db, version) async {
        await db.execute(
          """CREATE TABLE songDownload(
            id INTEGER PRIMARY KEY,
            titre TEXT
          )""",
        );
      },
      version: 1,
    );
    return db;
  }
}
