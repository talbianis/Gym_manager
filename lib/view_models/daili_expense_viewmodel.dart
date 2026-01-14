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
  // In DailyExpenseViewModel class, add this method after addExpense method

  // حذف مصروف
  Future<void> deleteExpense(int expenseId, DateTime date) async {
    await DBHelper.deleteExpense(expenseId);
    await loadExpenses(date);
  }

  Future<List<int>> getLast30DaysExpenses() async {
    final dbData = await DBHelper.getDailyExpenseLast30Days();

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
