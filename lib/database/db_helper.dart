import 'package:gym_manager/models/auth.dart';
import 'package:gym_manager/models/vipclient.dart';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:gym_manager/models/revenue.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

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
        version: 4, // ⭐ UPDATED VERSION
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
              total INTEGER DEFAULT 0,
              vip_subscription_sales INTEGER DEFAULT 0
            )
          """);

          // VIP CLIENTS TABLE
          await _createVipClientsTable(db);

          // ⭐ USERS TABLE (for login)
          await _createUsersTable(db);

          // Create default admin user
          await _createDefaultAdmin(db);
        },

        onUpgrade: (db, oldVersion, newVersion) async {
          if (oldVersion < 2) {
            await _createVipClientsTable(db);
          }
          if (oldVersion < 4) {
            await _createUsersTable(db);
            await _createDefaultAdmin(db);
          }
        },
      ),
    );
  }

  // ------------------------------------------------------
  // CREATE USERS TABLE
  // ------------------------------------------------------
  static Future<void> _createUsersTable(Database db) async {
    await db.execute("""
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        password_hash TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    """);
  }

  // ------------------------------------------------------
  // CREATE DEFAULT ADMIN USER
  // ------------------------------------------------------
  static Future<void> _createDefaultAdmin(Database db) async {
    final defaultUsername = 'ali';
    final defaultPassword = 'ali2026';
    final passwordHash = _hashPassword(defaultPassword);

    await db.insert('users', {
      'username': defaultUsername,
      'password_hash': passwordHash,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  // ------------------------------------------------------
  // PASSWORD HASHING
  // ------------------------------------------------------
  static String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  // ------------------------------------------------------
  // USER AUTHENTICATION FUNCTIONS
  // ------------------------------------------------------

  /// Login user - returns User object if successful, null otherwise
  static Future<User?> loginUser(String username, String password) async {
    final db = await database;
    final passwordHash = _hashPassword(password);

    final result = await db.query(
      'users',
      where: 'username = ? AND password_hash = ?',
      whereArgs: [username, passwordHash],
    );

    if (result.isEmpty) return null;
    return User.fromMap(result.first);
  }

  /// Register new user
  static Future<int> registerUser(String username, String password) async {
    final db = await database;
    final passwordHash = _hashPassword(password);

    return await db.insert('users', {
      'username': username,
      'password_hash': passwordHash,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  /// Check if username exists
  static Future<bool> usernameExists(String username) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
    return result.isNotEmpty;
  }

  /// Change password
  static Future<bool> changePassword(
    int userId,
    String oldPassword,
    String newPassword,
  ) async {
    final db = await database;
    final oldHash = _hashPassword(oldPassword);
    final newHash = _hashPassword(newPassword);

    // Verify old password
    final result = await db.query(
      'users',
      where: 'id = ? AND password_hash = ?',
      whereArgs: [userId, oldHash],
    );

    if (result.isEmpty) return false;

    // Update to new password
    await db.update(
      'users',
      {'password_hash': newHash},
      where: 'id = ?',
      whereArgs: [userId],
    );

    return true;
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
        weights TEXT NOT NULL,
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
