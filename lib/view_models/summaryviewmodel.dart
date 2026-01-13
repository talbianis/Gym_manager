import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/revenue.dart';

class SummaryViewModel extends ChangeNotifier {
  DateTime selectedDate = DateTime.now();

  int totalRevenue = 0;
  int totalExpenses = 0;
  int netBalance = 0;

  bool isLoading = false;

  Future<void> loadSummary() async {
    isLoading = true;
    notifyListeners();

    // ---------- REVENUE ----------
    Revenue? revenue = await DBHelper.getRevenueByDate(selectedDate);

    totalRevenue = revenue?.total ?? 0;

    // ---------- EXPENSES ----------
    totalExpenses = await DBHelper.getTotalExpensesByDate(selectedDate);

    // ---------- NET ----------
    netBalance = totalRevenue - totalExpenses;

    isLoading = false;
    notifyListeners();
  }

  void changeDate(DateTime date) {
    selectedDate = date;
    loadSummary();
  }
}
