import 'package:flutter/material.dart';
import '../models/revenue.dart';
import '../database/db_helper.dart';

class RevenueViewModel extends ChangeNotifier {
  List<Revenue> revenues = [];

  Future<void> loadRevenues() async {
    final db = await DBHelper.database;
    final data = await db.query("revenues");

    revenues = data.map((e) => Revenue.fromMap(e)).toList();
    notifyListeners();
  }

  Future<void> addRevenue(Revenue revenue) async {
    final db = await DBHelper.database;
    await db.insert("revenues", revenue.toMap());
    await loadRevenues();
  }
}
