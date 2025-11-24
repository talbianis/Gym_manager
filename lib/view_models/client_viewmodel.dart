// import 'package:flutter/material.dart';
// import '../models/client.dart';
// import '../database/db_helper.dart';

// class ClientViewModel extends ChangeNotifier {
//   List<Client> clients = [];
//   List<Client> _filteredClients = [];
//   String _searchQuery = "";

//   List<Client> get filteredClients => _filteredClients;
//   String get searchQuery => _searchQuery;
//   Future<void> loadClients() async {
//     final db = await DBHelper.database;
//     final data = await db.query("clients");

//     clients = data.map((e) => Client.fromMap(e)).toList();
//     notifyListeners();
//   }

//   void searchClients(String query) {
//     _searchQuery = query;

//     if (query.isEmpty) {
//       _filteredClients = clients;
//     } else {
//       _filteredClients = clients
//           .where(
//             (client) =>
//                 client.name.toLowerCase().contains(query.toLowerCase()) ||
//                 client.phone.contains(query),
//           )
//           .toList();
//     }
//     notifyListeners();
//   }

//   // ADD THIS METHOD TO CLEAR SEARCH
//   void clearSearch() {
//     _searchQuery = '';
//     _filteredClients = clients;
//     notifyListeners();
//   }

//   Future<void> addClient(Client client) async {
//     final db = await DBHelper.database;
//     await db.insert("clients", client.toMap());
//     await loadClients();
//   }

//   Future<void> deleteClient(int id) async {
//     final db = await DBHelper.database;
//     await db.delete("clients", where: "id = ?", whereArgs: [id]);
//     await loadClients();
//   }

//   List<Client> get expiredClients {
//     return clients
//         .where((c) => c.endDate.difference(DateTime.now()).inDays < 0)
//         .toList();
//   }

//   void rechargeClient(Client client, DateTime newEndDate) async {
//     client.endDate = newEndDate; // update end date

//     final db = await DBHelper.database;
//     await db.update(
//       'clients',
//       client.toMap(),
//       where: 'id = ?',
//       whereArgs: [client.id],
//     );

//     notifyListeners();
//   }
// }
import 'package:flutter/material.dart';
import 'package:gym_manager/database/db_helper.dart';
import 'package:gym_manager/models/client.dart';

class ClientViewModel extends ChangeNotifier {
  List<Client> clients = [];
  List<Client> _filteredClients = []; // This should show all clients by default
  String _searchQuery = '';

  List<Client> get filteredClients =>
      _filteredClients.isEmpty ? clients : _filteredClients;
  String get searchQuery => _searchQuery;

  Future<void> loadClients() async {
    final db = await DBHelper.database;
    final data = await db.query("clients");

    clients = data.map((e) => Client.fromMap(e)).toList();
    _filteredClients = []; // Set to empty to show all clients
    _searchQuery = '';
    notifyListeners();
  }

  void searchClients(String query) {
    _searchQuery = query;

    if (query.isEmpty) {
      _filteredClients = []; // Empty means show all clients
    } else {
      _filteredClients = clients
          .where(
            (client) =>
                client.name.toLowerCase().contains(query.toLowerCase()) ||
                client.phone.contains(query),
          )
          .toList();
    }
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    _filteredClients = []; // Empty means show all clients
    notifyListeners();
  }

  // Your existing methods remain the same...
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

  List<Client> get expiredClients {
    return clients
        .where((c) => c.endDate.difference(DateTime.now()).inDays < 0)
        .toList();
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
