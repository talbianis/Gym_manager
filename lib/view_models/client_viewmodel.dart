import 'package:flutter/material.dart';
import '../models/client.dart';
import '../database/db_helper.dart';

class ClientViewModel extends ChangeNotifier {
  List<Client> clients = [];

  Future<void> loadClients() async {
    final db = await DBHelper.database;
    final data = await db.query("clients");

    clients = data.map((e) => Client.fromMap(e)).toList();
    notifyListeners();
  }

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
    client.endDate = newEndDate; // update end date

    final db = await DBHelper.database;
    await db.update(
      'clients',
      client.toMap(),
      where: 'id = ?',
      whereArgs: [client.id],
    );

    notifyListeners();
  }
}
