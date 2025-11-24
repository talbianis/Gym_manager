// import 'package:path/path.dart';
// import 'package:sqflite/sqflite.dart';

// import 'package:gym_manager/models/revenue.dart';
// import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// class DBHelper {
//   static Database? _db;

//   // Open DB
//   static Future<Database> get database async {
//     if (_db != null) return _db!;
//     _db = await initDB();
//     return _db!;
//   }

//   // Init DB
//   static Future<Database> initDB() async {
//     final dbFactory = databaseFactoryFfi;
//     final dbPath = await dbFactory.getDatabasesPath();
//     final path = join(dbPath, "gym_manager.db");

//     return await dbFactory.openDatabase(
//       path,
//       options: OpenDatabaseOptions(
//         version: 1,
//         onCreate: (db, version) async {
//           // CLIENTS TABLE
//           await db.execute("""
//             CREATE TABLE clients (
//               id INTEGER PRIMARY KEY AUTOINCREMENT,
//               name TEXT,
//               phone TEXT,
//               start_date TEXT,
//               end_date TEXT,
//               subscription_type TEXT
//             )
//           """);

//           // REVENUES TABLE
//           await db.execute("""
//             CREATE TABLE revenues (
//               id INTEGER PRIMARY KEY AUTOINCREMENT,
//               date TEXT,
//               water_sales INTEGER DEFAULT 0,
//               session_sales INTEGER DEFAULT 0,
//               subscription_sales INTEGER DEFAULT 0,
//               whey_sales INTEGER DEFAULT 0,
//               total INTEGER DEFAULT 0
//             )
//           """);
//         },
//       ),
//     );
//   }

//   // ------------------ REVENUE FUNCTIONS -----------------------

//   // Insert a revenue day
//   static Future<int> insertRevenue(Revenue r) async {
//     final db = await DBHelper.database;
//     return await db.insert('revenues', r.toMap());
//   }

//   // Get revenue by date (yyyy-MM-dd)
//   static Future<Revenue?> getRevenueByDate(DateTime date) async {
//     final db = await DBHelper.database;
//     final iso = DateTime(date.year, date.month, date.day).toIso8601String();

//     final result = await db.query(
//       'revenues',
//       where: "date LIKE ?",
//       whereArgs: ['$iso%'],
//       limit: 1,
//     );

//     if (result.isEmpty) return null;
//     return Revenue.fromMap(result.first);
//   }

//   // Update revenue for today
//   static Future<int> updateRevenue(Revenue r) async {
//     final db = await DBHelper.database;
//     return await db.update(
//       'revenues',
//       r.toMap(),
//       where: "id = ?",
//       whereArgs: [r.id],
//     );
//   }

//   // Last N days
//   static Future<Map<String, int>> getDailyRevenueLast30Days() async {
//     final db = await DBHelper.database;

//     final result = await db.rawQuery('''
//     SELECT date, SUM(total) as total
//     FROM revenues
//     WHERE date BETWEEN date('now', '-29 days') AND date('now')
//     GROUP BY date
//     ORDER BY date ASC
//     ''');

//     Map<String, int> data = {};
//     for (var row in result) {
//       data[row['date'] as String] = row['total'] != null
//           ? row['total'] as int
//           : 0;
//     }

//     return data;
//   }
// }
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:gym_manager/models/revenue.dart';

class DBHelper {
  static Database? _db;

  // ------------------ OPEN DATABASE ------------------
  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await initDB();
    return _db!;
  }

  // ------------------ INIT DB ------------------
  static Future<Database> initDB() async {
    final dbFactory = databaseFactoryFfi;
    final dbPath = await dbFactory.getDatabasesPath();
    final path = join(dbPath, "gym_manager.db");

    return await dbFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          // CLIENTS TABLE
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

          // REVENUES TABLE
          await db.execute("""
            CREATE TABLE revenues (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              date TEXT,                     -- YYYY-MM-DD only
              water_sales INTEGER DEFAULT 0,
              session_sales INTEGER DEFAULT 0,
              subscription_sales INTEGER DEFAULT 0,
              whey_sales INTEGER DEFAULT 0,
              total INTEGER DEFAULT 0
            )
          """);
        },
      ),
    );
  }

  // ------------------ INSERT REVENUE DAY ------------------
  static Future<int> insertRevenue(Revenue r) async {
    final db = await DBHelper.database;
    return await db.insert('revenues', r.toMap());
  }

  // ------------------ GET REVENUE BY DATE ------------------
  // Date format: YYYY-MM-DD
  static Future<Revenue?> getRevenueByDate(DateTime date) async {
    final db = await DBHelper.database;

    final String sqlDate =
        "${date.year.toString().padLeft(4, '0')}-"
        "${date.month.toString().padLeft(2, '0')}-"
        "${date.day.toString().padLeft(2, '0')}";

    final result = await db.query(
      'revenues',
      where: "date = ?",
      whereArgs: [sqlDate],
      limit: 1,
    );

    if (result.isEmpty) return null;
    return Revenue.fromMap(result.first);
  }

  // ------------------ UPDATE REVENUE ------------------
  static Future<int> updateRevenue(Revenue r) async {
    final db = await DBHelper.database;
    return await db.update(
      'revenues',
      r.toMap(),
      where: "id = ?",
      whereArgs: [r.id],
    );
  }

  // ------------------ LAST 30 DAYS REVENUE ------------------
  static Future<Map<String, int>> getDailyRevenueLast30Days() async {
    final db = await DBHelper.database;

    final result = await db.rawQuery('''
      SELECT date, SUM(total) AS total
      FROM revenues
      WHERE date BETWEEN date('now','-29 days') AND date('now')
      GROUP BY date
      ORDER BY date ASC
    ''');

    Map<String, int> map = {};
    for (var row in result) {
      final String date = row["date"] as String;
      final int total = row["total"] != null ? row["total"] as int : 0;
      map[date] = total;
    }

    return map;
  }
}
