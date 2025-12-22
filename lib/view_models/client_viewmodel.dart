import 'package:flutter/material.dart';
import 'package:gym_manager/database/db_helper.dart';
import 'package:gym_manager/models/client.dart';

class ClientViewModel extends ChangeNotifier {
  // ========================
  // MAIN DATA
  // ========================
  List<Client> clients = [];

  // ========================
  // SEARCH - ALL CLIENTS
  // ========================
  List<Client> _filteredClients = [];
  String _searchQuery = '';

  List<Client> get filteredClients =>
      _filteredClients.isEmpty ? clients : _filteredClients;

  String get searchQuery => _searchQuery;

  // ========================
  // SEARCH - EXPIRED CLIENTS
  // ========================
  List<Client> _filteredExpiredClients = [];

  // ========================
  // LOAD CLIENTS
  // ========================
  Future<void> loadClients() async {
    final db = await DBHelper.database;
    final data = await db.query("clients");

    clients = data.map((e) => Client.fromMap(e)).toList();

    // reset all filters
    _filteredClients = [];
    _filteredExpiredClients = [];
    _searchQuery = '';

    notifyListeners();
  }

  // ========================
  // ALL CLIENTS SEARCH
  // ========================
  void searchClients(String query) {
    _searchQuery = query;

    if (query.isEmpty) {
      _filteredClients = [];
    } else {
      _filteredClients = clients.where((client) {
        return client.name.toLowerCase().contains(query.toLowerCase()) ||
            client.phone.contains(query);
      }).toList();
    }

    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    _filteredClients = [];
    notifyListeners();
  }

  // ========================
  // EXPIRED CLIENTS
  // ========================
  List<Client> get expiredClients {
    final expired = clients
        .where((c) => c.endDate.isBefore(DateTime.now()))
        .toList();

    return _filteredExpiredClients.isEmpty ? expired : _filteredExpiredClients;
  }

  void searchExpiredClients(String query) {
    final expired = clients
        .where((c) => c.endDate.isBefore(DateTime.now()))
        .toList();

    if (query.isEmpty) {
      _filteredExpiredClients = [];
    } else {
      _filteredExpiredClients = expired.where((client) {
        return client.name.toLowerCase().contains(query.toLowerCase()) ||
            client.phone.contains(query);
      }).toList();
    }

    notifyListeners();
  }

  void clearExpiredSearch() {
    _filteredExpiredClients = [];
    notifyListeners();
  }

  // ========================
  // TODAY EXPIRED CLIENTS
  // ========================
  List<Client> getTodayExpiredClients() {
    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );

    return clients.where((c) {
      final end = DateTime(c.endDate.year, c.endDate.month, c.endDate.day);
      return end.isAtSameMomentAs(today);
    }).toList();
  }

  // ========================
  // CRUD OPERATIONS
  // ========================
  Future<void> addClient(Client client) async {
    final db = await DBHelper.database;
    await db.insert("clients", client.toMap());
    await loadClients();
  }

  Future<void> deleteClient(int id) async {
    final db = await DBHelper.database;
    await db.delete("clients", where: "id = ?", whereArgs: [id]);
    await loadClients();
  }

  void rechargeClient(Client client, DateTime newEndDate) async {
    client.endDate = newEndDate;

    final db = await DBHelper.database;
    await db.update(
      'clients',
      client.toMap(),
      where: 'id = ?',
      whereArgs: [client.id],
    );

    await loadClients();
  }
}
