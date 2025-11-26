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
import 'package:gym_manager/models/vipclient.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:gym_manager/models/revenue.dart';

class DBHelper {
  static Database? _db;

  // ------------------------------------------------------
  // GET DATABASE INSTANCE
  // ------------------------------------------------------
  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await initDB();
    return _db!;
  }

  // ------------------------------------------------------
  // INIT DATABASE (Create tables)
  // ------------------------------------------------------
  static Future<Database> initDB() async {
    final dbFactory = databaseFactoryFfi;
    final dbPath = await dbFactory.getDatabasesPath();
    final path = join(dbPath, "gym_manager.db");

    return await dbFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 2, // ⭐ IMPORTANT: Upgrade the DB version
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
              date TEXT,
              water_sales INTEGER DEFAULT 0,
              session_sales INTEGER DEFAULT 0,
              subscription_sales INTEGER DEFAULT 0,
              whey_sales INTEGER DEFAULT 0,
              total INTEGER DEFAULT 0
            )
          """);

          // ⭐ CREATE VIP TABLE
          await _createVipClientsTable(db);
        },

        onUpgrade: (db, oldVersion, newVersion) async {
          // When updating from v1 → v2, create VIP table
          if (oldVersion < 2) {
            await _createVipClientsTable(db);
          }
        },
      ),
    );
  }

  // ------------------------------------------------------
  // CREATE VIP CLIENTS TABLE
  // ------------------------------------------------------
  static Future<void> _createVipClientsTable(Database db) async {
    await db.execute("""
      CREATE TABLE vip_clients (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        age INTEGER NOT NULL,
        phone TEXT NOT NULL,
        photo TEXT,
        weights TEXT NOT NULL,     -- JSON string of weight history
        start_date TEXT NOT NULL,
        end_date TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    """);
  }

  // ------------------------------------------------------
  // VIP CRUD OPERATIONS
  // ------------------------------------------------------

  static Future<int> insertVipClient(VipClient client) async {
    final db = await database;
    return await db.insert('vip_clients', client.toMap());
  }

  static Future<List<VipClient>> getAllVipClients() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('vip_clients');
    return maps.map((m) => VipClient.fromMap(m)).toList();
  }

  static Future<VipClient?> getVipClientById(int id) async {
    final db = await database;
    final maps = await db.query(
      'vip_clients',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return VipClient.fromMap(maps.first);
  }

  static Future<int> updateVipClient(VipClient client) async {
    final db = await database;
    return await db.update(
      'vip_clients',
      client.toMap(),
      where: 'id = ?',
      whereArgs: [client.id],
    );
  }

  static Future<int> deleteVipClient(int id) async {
    final db = await database;
    return await db.delete('vip_clients', where: 'id = ?', whereArgs: [id]);
  }

  static Future<List<VipClient>> getActiveVipClients() async {
    final all = await getAllVipClients();
    return all.where((c) => c.isActive).toList();
  }

  static Future<List<VipClient>> getExpiredVipClients() async {
    final all = await getAllVipClients();
    return all.where((c) => c.isExpired).toList();
  }

  static Future<List<VipClient>> getClientsExpiringInDays(int days) async {
    final all = await getAllVipClients();
    return all
        .where(
          (c) => c.isActive && c.daysRemaining <= days && c.daysRemaining > 0,
        )
        .toList();
  }

  // ------------------------------------------------------
  // REVENUE FUNCTIONS
  // ------------------------------------------------------

  static Future<int> insertRevenue(Revenue r) async {
    final db = await DBHelper.database;
    return await db.insert('revenues', r.toMap());
  }

  static Future<Revenue?> getRevenueByDate(DateTime date) async {
    final db = await DBHelper.database;

    final sqlDate =
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

  static Future<int> updateRevenue(Revenue r) async {
    final db = await DBHelper.database;
    return await db.update(
      'revenues',
      r.toMap(),
      where: "id = ?",
      whereArgs: [r.id],
    );
  }

  static Future<Map<String, int>> getDailyRevenueLast30Days() async {
    final db = await DBHelper.database;

    final result = await db.rawQuery("""
      SELECT date, SUM(total) AS total
      FROM revenues
      WHERE date BETWEEN date('now','-29 days') AND date('now')
      GROUP BY date
      ORDER BY date ASC
    """);

    Map<String, int> map = {};
    for (var row in result) {
      final date = row["date"] as String;
      final total = row["total"] != null ? row["total"] as int : 0;
      map[date] = total;
    }

    return map;
  }
}
