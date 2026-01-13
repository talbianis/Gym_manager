import 'package:flutter/material.dart';
import '../models/revenue_item.dart';
import '../models/revenue.dart';
import '../database/db_helper.dart';

class RevenueViewModel extends ChangeNotifier {
  // initial prices (customize as needed)
  final List<RevenueItem> items = [
    RevenueItem(key: 'water', label: 'Water Bottle', price: 50),
    RevenueItem(key: 'whey', label: 'Whey Dose', price: 250),
    RevenueItem(key: 'session', label: 'Single Session', price: 150),
    RevenueItem(key: 'subscription', label: 'Subscription', price: 1200),
    RevenueItem(
      key: 'vip_subscription',
      label: 'VIP Subscription',
      price: 2500,
    ),
  ];

  bool isSaving = false;

  // total revenue of all items
  int get total {
    int sum = 0;
    for (var it in items) sum += it.total;
    return sum;
  }

  // count of items (still useful for UI counters)
  int countByKey(String key) {
    final it = items.firstWhere((e) => e.key == key);
    return it.count;
  }

  // total revenue by key
  int totalByKey(String key) {
    final it = items.firstWhere((e) => e.key == key);
    return it.total;
  }

  void increment(String key) {
    final it = items.firstWhere((e) => e.key == key);
    it.count++;
    notifyListeners();
  }

  void decrement(String key) {
    final it = items.firstWhere((e) => e.key == key);
    if (it.count > 0) {
      it.count--;
      notifyListeners();
    }
  }

  void resetCounts() {
    for (var it in items) it.count = 0;
    notifyListeners();
  }

  // Save today's revenue to DB (overwrite if already exists for today)
  Future<void> saveTodayRevenue() async {
    isSaving = true;
    notifyListeners();

    final today = DateTime.now();
    final existing = await DBHelper.getRevenueByDate(today);

    final revenue = Revenue(
      date: DateTime(today.year, today.month, today.day),
      waterSales: totalByKey('water'),
      sessionSales: totalByKey('session'),
      subscriptionSales: totalByKey('subscription'),
      wheySales: totalByKey('whey'),
      vipSubscriptionSales: totalByKey('vip_subscription'),
    );

    if (existing != null) {
      // delete existing and insert new (simple approach)
      final db = await DBHelper.database;
      await db.delete('revenues', where: 'id = ?', whereArgs: [existing.id]);
    }

    await DBHelper.insertRevenue(revenue);

    isSaving = false;
    print('i succesuflu save to db ');
    notifyListeners();
  }

  // Load today's saved revenue into counters (if any)
  Future<void> loadTodayRevenueToCounters() async {
    final today = DateTime.now();
    final existing = await DBHelper.getRevenueByDate(today);
    if (existing != null) {
      items.firstWhere((i) => i.key == 'water').count =
          (existing.waterSales /
                  items.firstWhere((i) => i.key == 'water').price)
              .round();
      items.firstWhere((i) => i.key == 'whey').count =
          (existing.wheySales / items.firstWhere((i) => i.key == 'whey').price)
              .round();
      items.firstWhere((i) => i.key == 'session').count =
          (existing.sessionSales /
                  items.firstWhere((i) => i.key == 'session').price)
              .round();
      items.firstWhere((i) => i.key == 'subscription').count =
          (existing.subscriptionSales /
                  items.firstWhere((i) => i.key == 'subscription').price)
              .round();
      items.firstWhere((i) => i.key == 'vip_subscription').count =
          (existing.vipSubscriptionSales /
                  items.firstWhere((i) => i.key == 'vip_subscription').price)
              .round();
    } else {
      resetCounts();
    }
    notifyListeners();
  }

  // Get last 30 days totals (for chart)
  Future<List<int>> getLast30DaysRevenue() async {
    final dbData = await DBHelper.getDailyRevenueLast30Days();

    List<int> finalData = [];

    for (int i = 29; i >= 0; i--) {
      final date = DateTime.now().subtract(Duration(days: i));
      final dateString =
          "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

      finalData.add(dbData[dateString] ?? 0);
    }

    return finalData;
  }
}
