import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gym_manager/const/colors.dart';
import 'package:gym_manager/models/needs.dart';
import 'package:gym_manager/view_models/daili_expense_viewmodel.dart';
import 'package:gym_manager/view_models/reveniew_viewmodel.dart';

import 'package:provider/provider.dart';
import '../widgets/counter_row.dart';

class RevenueScreen extends StatefulWidget {
  @override
  _RevenueScreenState createState() => _RevenueScreenState();
}

class _RevenueScreenState extends State<RevenueScreen> {
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadDataForDate(selectedDate);
  }

  void _loadDataForDate(DateTime date) {
    // Load revenue for selected date
    Provider.of<RevenueViewModel>(
      context,
      listen: false,
    ).loadTodayRevenueToCounters();

    // Load expenses for selected date
    Provider.of<DailyExpenseViewModel>(
      context,
      listen: false,
    ).loadExpenses(date);
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: AppColor.mainColor),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      _loadDataForDate(picked);
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(Duration(days: 1));
    final selectedDay = DateTime(date.year, date.month, date.day);

    if (selectedDay == today) {
      return 'Today';
    } else if (selectedDay == yesterday) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _showAddExpenseDialog() {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Expense'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  hintText: 'Water, Cleaning, etc.',
                ),
              ),
              SizedBox(height: 10.h),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Amount (DA)'),
              ),
              SizedBox(height: 10.h),
              TextField(
                controller: noteController,
                decoration: InputDecoration(labelText: 'Note (Optional)'),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.mainColor,
            ),
            onPressed: () async {
              if (titleController.text.isEmpty ||
                  amountController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Please fill required fields'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              final expense = DailyExpense(
                date: selectedDate, // ← Uses selected date
                title: titleController.text,
                amount: int.parse(amountController.text),
                note: noteController.text.isEmpty ? null : noteController.text,
              );

              await Provider.of<DailyExpenseViewModel>(
                context,
                listen: false,
              ).addExpense(expense);

              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Expense added successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: Text('Add', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColor.whitecolor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: AppColor.mainColor,
        title: Text(
          "Daily Revenue & Expenses",
          style: TextStyle(color: AppColor.whitecolor, fontSize: 22.sp),
        ),
      ),
      backgroundColor: Colors.grey[200],
      body: Consumer2<RevenueViewModel, DailyExpenseViewModel>(
        builder: (context, revenueVM, expenseVM, child) {
          final netProfit = revenueVM.total - expenseVM.totalExpenses;

          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 50.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // DATE SELECTOR
                  Container(
                    padding: EdgeInsets.all(15.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              color: AppColor.mainColor,
                              size: 24.sp,
                            ),
                            SizedBox(width: 10.w),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Selected Date',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Text(
                                  _formatDate(selectedDate),
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                    color: AppColor.mainColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.arrow_back_ios, size: 20.sp),
                              onPressed: () {
                                setState(() {
                                  selectedDate = selectedDate.subtract(
                                    Duration(days: 1),
                                  );
                                });
                                _loadDataForDate(selectedDate);
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.arrow_forward_ios, size: 20.sp),
                              onPressed:
                                  selectedDate.isBefore(
                                    DateTime(
                                      DateTime.now().year,
                                      DateTime.now().month,
                                      DateTime.now().day,
                                    ),
                                  )
                                  ? () {
                                      setState(() {
                                        selectedDate = selectedDate.add(
                                          Duration(days: 1),
                                        );
                                      });
                                      _loadDataForDate(selectedDate);
                                    }
                                  : null,
                            ),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColor.mainColor,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 15.w,
                                  vertical: 8.h,
                                ),
                              ),
                              icon: Icon(
                                Icons.date_range,
                                color: Colors.white,
                                size: 18.sp,
                              ),
                              label: Text(
                                'Pick Date',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14.sp,
                                ),
                              ),
                              onPressed: _selectDate,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // REVENUE SECTION
                  Text(
                    "REVENUE",
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColor.mainColor,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  ...revenueVM.items.map(
                    (it) => CounterRow(
                      label: it.label,
                      price: it.price,
                      count: it.count,
                      onIncrement: () => revenueVM.increment(it.key),
                      onDecrement: () => revenueVM.decrement(it.key),
                    ),
                  ),

                  SizedBox(height: 30.h),
                  Divider(thickness: 2),
                  SizedBox(height: 20.h),

                  // EXPENSES SECTION
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "EXPENSES",
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.red[700],
                        ),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[700],
                          padding: EdgeInsets.symmetric(
                            horizontal: 15.w,
                            vertical: 8.h,
                          ),
                        ),
                        icon: Icon(Icons.add, color: Colors.white, size: 18.sp),
                        label: Text(
                          'Add Expense',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                          ),
                        ),
                        onPressed: _showAddExpenseDialog,
                      ),
                    ],
                  ),
                  SizedBox(height: 15.h),

                  // Expenses List
                  expenseVM.isLoading
                      ? Center(child: CircularProgressIndicator())
                      : expenseVM.expenses.isEmpty
                      ? Center(
                          child: Padding(
                            padding: EdgeInsets.all(20.h),
                            child: Text(
                              'No expenses for ${_formatDate(selectedDate)}',
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: expenseVM.expenses.length,
                          itemBuilder: (context, index) {
                            final expense = expenseVM.expenses[index];
                            return Card(
                              margin: EdgeInsets.only(bottom: 10.h),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.red[100],
                                  child: Icon(
                                    Icons.money_off,
                                    color: Colors.red[700],
                                  ),
                                ),
                                title: Text(
                                  expense.title,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.sp,
                                  ),
                                ),
                                subtitle: expense.note != null
                                    ? Text(expense.note!)
                                    : null,
                                trailing: Text(
                                  '${expense.amount} DA',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red[700],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                  SizedBox(height: 30.h),
                  Divider(thickness: 2),
                  SizedBox(height: 20.h),

                  // SUMMARY SECTION
                  Container(
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildSummaryRow(
                          'Total Revenue',
                          revenueVM.total,
                          Colors.green,
                        ),
                        SizedBox(height: 10.h),
                        _buildSummaryRow(
                          'Total Expenses',
                          expenseVM.totalExpenses,
                          Colors.red,
                        ),
                        Divider(thickness: 2, height: 30.h),
                        _buildSummaryRow(
                          'NET PROFIT',
                          netProfit,
                          netProfit >= 0 ? Colors.blue : Colors.red,
                          isTotal: true,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 30.h),

                  // Save Button
                  Center(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.mainColor,
                        padding: EdgeInsets.symmetric(
                          vertical: 15.h,
                          horizontal: 30.w,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                      ),
                      icon: revenueVM.isSaving
                          ? SizedBox(
                              width: 20.w,
                              height: 20.h,
                              child: CircularProgressIndicator(
                                color: AppColor.whitecolor,
                                strokeWidth: 2,
                              ),
                            )
                          : Icon(Icons.save, color: AppColor.whitecolor),
                      label: Text(
                        "Save Today's Revenue",
                        style: TextStyle(
                          fontSize: 18.sp,
                          color: AppColor.whitecolor,
                        ),
                      ),
                      onPressed: revenueVM.isSaving
                          ? null
                          : () async {
                              await revenueVM.saveTodayRevenue();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: AppColor.mainColor,
                                  content: Text(
                                    "Today's revenue saved",
                                    style: TextStyle(
                                      color: AppColor.whitecolor,
                                    ),
                                  ),
                                ),
                              );
                            },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    int amount,
    Color color, {
    bool isTotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 20.sp : 16.sp,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
          ),
        ),
        Text(
          '${amount} DA',
          style: TextStyle(
            fontSize: isTotal ? 24.sp : 18.sp,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
