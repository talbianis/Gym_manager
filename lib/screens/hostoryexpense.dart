import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gym_manager/const/colors.dart';
import 'package:gym_manager/models/needs.dart';
import 'package:gym_manager/database/db_helper.dart';

class ExpenseHistoryScreen extends StatefulWidget {
  @override
  _ExpenseHistoryScreenState createState() => _ExpenseHistoryScreenState();
}

class _ExpenseHistoryScreenState extends State<ExpenseHistoryScreen> {
  DateTime selectedDate = DateTime.now();
  List<DailyExpense> expenses = [];
  int totalExpenses = 0;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadExpensesForDate(selectedDate);
  }

  Future<void> _loadExpensesForDate(DateTime date) async {
    setState(() => isLoading = true);

    expenses = await DBHelper.getExpensesByDate(date);
    totalExpenses = await DBHelper.getTotalExpensesByDate(date);

    setState(() => isLoading = false);
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
      setState(() => selectedDate = picked);
      _loadExpensesForDate(picked);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColor.whitecolor),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: AppColor.mainColor,
        title: Text(
          'Expense History',
          style: TextStyle(color: AppColor.whitecolor, fontSize: 22.sp),
        ),
      ),
      backgroundColor: Colors.grey[200],
      body: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: [
            // Date Selector Card
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
                            'Date',
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
                          _loadExpensesForDate(selectedDate);
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
                                _loadExpensesForDate(selectedDate);
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
                          'Pick',
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

            // Total Expenses Card
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(15.r),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Expenses',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '$totalExpenses DA',
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[700],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20.h),

            // Expenses List
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : expenses.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inbox_outlined,
                            size: 80.sp,
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: 20.h),
                          Text(
                            'No expenses for ${_formatDate(selectedDate)}',
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: expenses.length,
                      itemBuilder: (context, index) {
                        final expense = expenses[index];
                        return Card(
                          margin: EdgeInsets.only(bottom: 12.h),
                          elevation: 2,
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 20.w,
                              vertical: 10.h,
                            ),
                            leading: CircleAvatar(
                              backgroundColor: Colors.red[100],
                              radius: 25.r,
                              child: Icon(
                                Icons.money_off,
                                color: Colors.red[700],
                                size: 24.sp,
                              ),
                            ),
                            title: Text(
                              expense.title,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18.sp,
                              ),
                            ),
                            subtitle: expense.note != null
                                ? Padding(
                                    padding: EdgeInsets.only(top: 5.h),
                                    child: Text(
                                      expense.note!,
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  )
                                : null,
                            trailing: Text(
                              '${expense.amount} DA',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.red[700],
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
  }
}
