import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DBHelper {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await initDB();
    return _db!;
  }

  static Future<Database> initDB() async {
    final dbFactory = databaseFactoryFfi;
    final dbPath = await dbFactory.getDatabasesPath();
    final path = join(dbPath, "gym_manager.db");

    return await dbFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          await db.execute("""
            CREATE TABLE clients (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT,
              phone TEXT,
              start_date TEXT,
              end_date TEXT,
              subscription_type TEXT
            )
          """);

          await db.execute("""
            CREATE TABLE revenues (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              date TEXT,
              water_sales INTEGER,
              session_sales INTEGER,
              subscription_sales INTEGER,
              total INTEGER
            )
          """);
        },
      ),
    );
  }
}
