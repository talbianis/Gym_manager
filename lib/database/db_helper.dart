import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:gym_manager/models/auth.dart';
import 'package:gym_manager/models/client_payment.dart';
import 'package:gym_manager/models/needs.dart';
import 'package:gym_manager/models/vipclient.dart';
import 'package:gym_manager/models/revenue.dart';

import 'package:path/path.dart';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DBHelper {
  static Database? _db;

  static bool _isClosedIntentionally = false;

  // ------------------------------------------------------
  // GET DATABASE INSTANCE (WITH AUTO-REOPEN)
  // ------------------------------------------------------
  static Future<Database> get database async {
    if (_db != null && _db!.isOpen) {
      return _db!;
    }

    // If database was closed intentionally (for backup/restore), reopen it
    if (_isClosedIntentionally) {
      print('🔄 Reopening database after intentional close...');
      _isClosedIntentionally = false;
    }

    _db = await initDB();
    return _db!;
  }

  // ------------------------------------------------------
  // CLOSE DATABASE (FOR BACKUP/RESTORE)
  // ------------------------------------------------------
  static Future<void> closeDatabaseForBackup() async {
    if (_db != null && _db!.isOpen) {
      await _db!.close();
      _db = null;
      _isClosedIntentionally = true;
    }
  }

  // ------------------------------------------------------
  // REOPEN DATABASE (AFTER BACKUP/RESTORE)
  // ------------------------------------------------------
  static Future<void> reopenDatabase() async {
    if (_db == null || !_db!.isOpen) {
      _db = await initDB();
      _isClosedIntentionally = false;
    }
  }

  // ------------------------------------------------------
  // CHECK IF DATABASE IS OPEN
  // ------------------------------------------------------
  static bool get isDatabaseOpen {
    return _db != null && _db!.isOpen;
  }

  // ------------------------------------------------------
  // GET DATABASE INSTANCE
  // ------------------------------------------------------
  // Removed duplicate definition of the database getter.

  // ------------------------------------------------------
  // INIT DATABASE
  // ------------------------------------------------------
  static Future<Database> initDB() async {
    final dbFactory = databaseFactoryFfi;
    final dbPath = await dbFactory.getDatabasesPath();
    final path = join(dbPath, "gym_manager.db");

    return await dbFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 7,
        onCreate: (db, version) async {
          await _createClientsTable(db);
          await _createRevenueTable(db);
          await _createVipClientsTable(db);
          await _createUsersTable(db);
          await _createDailyExpensesTable(db);
          await _createDefaultAdmin(db);
          await _createClientPaymentsTable(db);
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          if (oldVersion < 2) {
            await _createVipClientsTable(db);
          }
          if (oldVersion < 4) {
            await _createUsersTable(db);
            await _createDefaultAdmin(db);
          }
          if (oldVersion < 5) {
            await _createDailyExpensesTable(db);
          }
          if (oldVersion < 7) {
            await db.execute(
              "ALTER TABLE revenues ADD COLUMN extra_revenue INTEGER DEFAULT 0",
            );
          }
        },
      ),
    );
  }

  // ------------------------------------------------------
  // BASE TABLES
  // ------------------------------------------------------
  static Future<void> _createClientsTable(Database db) async {
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
  }

  static Future<void> _createRevenueTable(Database db) async {
    await db.execute("""
    CREATE TABLE revenues (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      date TEXT,
      water_sales INTEGER DEFAULT 0,
      session_sales INTEGER DEFAULT 0,
      subscription_sales INTEGER DEFAULT 0,
      whey_sales INTEGER DEFAULT 0,
      vip_subscription_sales INTEGER DEFAULT 0,
      extra_revenue INTEGER DEFAULT 0, -- ✅ NEW
      total INTEGER DEFAULT 0
    )
  """);
  }

  static Future<Map<String, int>> getDailyRevenueLast30Days() async {
    final db = await database;

    final result = await db.rawQuery("""
    SELECT date, SUM(total) AS total
    FROM revenues
    WHERE date BETWEEN date('now','-29 days') AND date('now')
    GROUP BY date
    ORDER BY date ASC
  """);

    Map<String, int> data = {};
    for (var row in result) {
      data[row['date'] as String] = (row['total'] ?? 0) as int;
    }

    return data;
  }

  static Future<Map<String, int>> getDailyExpenseLast30Days() async {
    final db = await database;

    final result = await db.rawQuery("""
    SELECT date, SUM(amount) AS total
    FROM daily_expenses
    WHERE date BETWEEN date('now','-29 days') AND date('now')
    GROUP BY date
    ORDER BY date ASC
  """);

    Map<String, int> data = {};
    for (var row in result) {
      data[row['date'] as String] = (row['total'] ?? 0) as int;
    }

    return data;
  }

  //client payments table
  static Future<void> _createClientPaymentsTable(Database db) async {
    await db.execute("""
    CREATE TABLE client_payments (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      client_id INTEGER NOT NULL,
      date TEXT NOT NULL,
      amount INTEGER NOT NULL,
      subscription_type TEXT,
      note TEXT,
      FOREIGN KEY (client_id) REFERENCES clients(id) ON DELETE CASCADE
    )
  """);
  }

  static Future<int> insertClientPayment(ClientPayment payment) async {
    final db = await database;
    return await db.insert('client_payments', payment.toMap());
  }

  static Future<List<ClientPayment>> getPaymentsByClient(int clientId) async {
    final db = await database;

    final result = await db.query(
      'client_payments',
      where: 'client_id = ?',
      whereArgs: [clientId],
      orderBy: 'date DESC',
    );

    return result.map((e) => ClientPayment.fromMap(e)).toList();
  }

  // ------------------------------------------------------
  // VIP CLIENTS
  // ------------------------------------------------------
  static Future<void> _createVipClientsTable(Database db) async {
    await db.execute("""
      CREATE TABLE vip_clients (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        age INTEGER NOT NULL,
        phone TEXT NOT NULL,
        photo TEXT,
        weights TEXT NOT NULL,
        height INTEGER NOT NULL,
        start_date TEXT NOT NULL,
        end_date TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    """);
  }

  static Future<int> insertVipClient(VipClient client) async {
    final db = await database;
    return await db.insert('vip_clients', client.toMap());
  }

  static Future<List<VipClient>> getAllVipClients() async {
    final db = await database;
    final maps = await db.query('vip_clients');
    return maps.map((e) => VipClient.fromMap(e)).toList();
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

  // ------------------------------------------------------
  // USERS / AUTH
  // ------------------------------------------------------
  static Future<void> _createUsersTable(Database db) async {
    await db.execute("""
    CREATE TABLE users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      username TEXT UNIQUE NOT NULL,
      password_hash TEXT NOT NULL,
      created_at TEXT NOT NULL,
      is_logged_in INTEGER DEFAULT 0
    )
  """);
  }

  static Future<void> _createDefaultAdmin(Database db) async {
    final result = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: ['ali'],
    );
    if (result.isEmpty) {
      await db.insert('users', {
        'username': 'ali',
        'password_hash': _hashPassword('ali2026'),
        'created_at': DateTime.now().toIso8601String(),
        'is_logged_in': 0,
      });
    }
  }

  static Future<User?> loginUser(String username, String password) async {
    final db = await database;
    final hash = _hashPassword(password);

    final result = await db.query(
      'users',
      where: 'username = ? AND password_hash = ?',
      whereArgs: [username, hash],
    );

    if (result.isEmpty) return null;
    return User.fromMap(result.first);
  }

  // ADD THESE NEW METHODS:

  // Get current logged in user
  static Future<User?> getLoggedInUser() async {
    final db = await database;

    final result = await db.query(
      'users',
      where: 'is_logged_in = ?',
      whereArgs: [1],
      limit: 1,
    );

    if (result.isEmpty) return null;
    return User.fromMap(result.first);
  }

  // Set user as logged in
  static Future<void> setUserLoggedIn(int userId, bool isLoggedIn) async {
    final db = await database;

    // First, set all users to logged out
    await db.update('users', {'is_logged_in': 0});

    // Then set specific user as logged in if needed
    if (isLoggedIn) {
      await db.update(
        'users',
        {'is_logged_in': 1},
        where: 'id = ?',
        whereArgs: [userId],
      );
    }
  }

  // Logout all users
  static Future<void> logoutAllUsers() async {
    final db = await database;
    await db.update('users', {'is_logged_in': 0});
  }

  static String _hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  static Future<bool> usernameExists(String username) async {
    final db = await database;

    final result = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );

    return result.isNotEmpty;
  }

  static Future<int> registerUser(String username, String password) async {
    final db = await database;

    final passwordHash = _hashPassword(password);

    return await db.insert('users', {
      'username': username,
      'password_hash': passwordHash,
      'created_at': DateTime.now().toIso8601String(),
      'is_logged_in': 0,
    });
  }

  static Future<bool> changePassword(
    int userId,
    String oldPassword,
    String newPassword,
  ) async {
    final db = await database;

    final oldHash = _hashPassword(oldPassword);
    final newHash = _hashPassword(newPassword);

    // verify old password
    final result = await db.query(
      'users',
      where: 'id = ? AND password_hash = ?',
      whereArgs: [userId, oldHash],
    );

    if (result.isEmpty) return false;

    // update new password
    await db.update(
      'users',
      {'password_hash': newHash},
      where: 'id = ?',
      whereArgs: [userId],
    );

    return true;
  }

  // ------------------------------------------------------
  // DAILY EXPENSES (NEEDS)
  // ------------------------------------------------------
  static Future<void> _createDailyExpensesTable(Database db) async {
    await db.execute("""
      CREATE TABLE daily_expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        title TEXT NOT NULL,
        amount INTEGER NOT NULL,
        note TEXT
      )
    """);
  }

  static Future<int> insertExpense(DailyExpense expense) async {
    final db = await database;
    return await db.insert('daily_expenses', expense.toMap());
  }

  static Future<List<DailyExpense>> getExpensesByDate(DateTime date) async {
    final db = await database;
    final d = _formatDate(date);

    final result = await db.query(
      'daily_expenses',
      where: 'date = ?',
      whereArgs: [d],
    );

    return result.map((e) => DailyExpense.fromMap(e)).toList();
  }

  static Future<int> getTotalExpensesByDate(DateTime date) async {
    final db = await database;
    final d = _formatDate(date);

    final result = await db.rawQuery(
      """
      SELECT SUM(amount) as total
      FROM daily_expenses
      WHERE date = ?
    """,
      [d],
    );

    return (result.first['total'] ?? 0) as int;
  }
  // In DBHelper class, add this method after getTotalExpensesByDate method

  static Future<int> deleteExpense(int id) async {
    final db = await database;
    return await db.delete('daily_expenses', where: 'id = ?', whereArgs: [id]);
  }

  // ------------------------------------------------------
  // REVENUE
  // ------------------------------------------------------
  static Future<int> insertRevenue(Revenue r) async {
    final db = await database;
    return await db.insert('revenues', r.toMap());
  }

  static Future<Revenue?> getRevenueByDate(DateTime date) async {
    final db = await database;
    final d = _formatDate(date);

    final result = await db.query(
      'revenues',
      where: 'date = ?',
      whereArgs: [d],
      limit: 1,
    );

    if (result.isEmpty) return null;
    return Revenue.fromMap(result.first);
  }

  static Future<int> updateRevenue(Revenue r) async {
    final db = await database;
    return await db.update(
      'revenues',
      r.toMap(),
      where: 'id = ?',
      whereArgs: [r.id],
    );
  }

  // ------------------------------------------------------
  // HELPERS
  // ------------------------------------------------------
  static String _formatDate(DateTime d) {
    return "${d.year.toString().padLeft(4, '0')}-"
        "${d.month.toString().padLeft(2, '0')}-"
        "${d.day.toString().padLeft(2, '0')}";
  }
}
