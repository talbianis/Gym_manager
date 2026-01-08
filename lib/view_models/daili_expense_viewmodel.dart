import 'package:flutter/material.dart';
import 'package:gym_manager/models/needs.dart';
import '../database/db_helper.dart';

class DailyExpenseViewModel extends ChangeNotifier {
  List<DailyExpense> expenses = [];
  int totalExpenses = 0;
  bool isLoading = false;

  // تحميل مصاريف يوم معيّن
  Future<void> loadExpenses(DateTime date) async {
    isLoading = true;
    notifyListeners();

    expenses = await DBHelper.getExpensesByDate(date);
    totalExpenses = await DBHelper.getTotalExpensesByDate(date);

    isLoading = false;
    notifyListeners();
  }

  // إضافة مصروف جديد
  Future<void> addExpense(DailyExpense expense) async {
    await DBHelper.insertExpense(expense);
    await loadExpenses(DateTime.now());
  }
}
