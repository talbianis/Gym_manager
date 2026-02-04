import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gym_manager/const/colors.dart';
import 'package:gym_manager/models/needs.dart';
import 'package:gym_manager/screens/sumarry.dart';
import 'package:gym_manager/view_models/daili_expense_viewmodel.dart';
import 'package:provider/provider.dart';

class ExpenseScreen extends StatefulWidget {
  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  DateTime selectedDate = DateTime.now();
  bool _initialLoadDone = false;

  @override
  void initState() {
    super.initState();

    // FIXED: Load expenses AFTER the build completes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadExpenses();
      _initialLoadDone = true;
    });
  }

  void _loadExpenses() {
    Provider.of<DailyExpenseViewModel>(
      context,
      listen: false,
    ).loadExpenses(selectedDate);
  }

  // ---------------- DATE PICKER ----------------
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
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

    if (picked != null) {
      setState(() => selectedDate = picked);
      _loadExpenses();
    }
  }

  String _formatDate(DateTime d) {
    return "${d.day}/${d.month}/${d.year}";
  }

  // ---------------- ADD EXPENSE ----------------
  void _showAddExpenseDialog() {
    final titleController = TextEditingController();
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Add Expense", style: TextStyle(fontSize: 22.sp)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: "Title"),
            ),
            SizedBox(height: 10.h),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "Amount (DA)"),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.mainColor,
            ),
            child: Text("Add", style: TextStyle(color: AppColor.whitecolor)),
            onPressed: () async {
              if (titleController.text.isEmpty || amountController.text.isEmpty)
                return;

              final expense = DailyExpense(
                date: selectedDate, // ⭐ important
                title: titleController.text,
                amount: int.parse(amountController.text),
              );

              await Provider.of<DailyExpenseViewModel>(
                context,
                listen: false,
              ).addExpense(expense);

              if (!mounted) return;
              Navigator.pop(context);
              _loadExpenses();
            },
          ),
        ],
      ),
    );
  }

  // ---------------- DELETE EXPENSE ----------------
  Future<void> _deleteExpense(int expenseId, String title) async {
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete Expense"),
        content: Text("Are you sure you want to delete '$title'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      if (!mounted) return;
      await Provider.of<DailyExpenseViewModel>(
        context,
        listen: false,
      ).deleteExpense(expenseId, selectedDate);
    }
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back, color: AppColor.whitecolor),
        ),
        title: Text(
          "Daily Expenses",
          style: TextStyle(color: Colors.white, fontSize: 22.sp),
        ),
        backgroundColor: AppColor.mainColor,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColor.mainColor,
        child: Icon(Icons.add, color: AppColor.whitecolor),
        onPressed: _showAddExpenseDialog,
      ),
      body: Consumer<DailyExpenseViewModel>(
        builder: (context, vm, child) {
          // Optional: Show initial loading if no data loaded yet
          if (!_initialLoadDone && vm.expenses.isEmpty && !vm.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // ---------- DATE SELECTOR ----------
              Container(
                margin: EdgeInsets.all(20.w),
                padding: EdgeInsets.all(15.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.calendar_today, color: Colors.red),
                        SizedBox(width: 10.w),
                        Text(
                          _formatDate(selectedDate),
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.mainColor,
                      ),
                      child: Text(
                        "Change",
                        style: TextStyle(color: AppColor.whitecolor),
                      ),
                      onPressed: _pickDate,
                    ),
                  ],
                ),
              ),

              // ---------- TOTAL ----------
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20.w),
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15.r),
                ),
                child: Column(
                  children: [
                    Text(
                      "TOTAL EXPENSES",
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      "${vm.totalExpenses} DA",
                      style: TextStyle(
                        fontSize: 30.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20.h),

              // ---------- EXPENSES LIST ----------
              Expanded(
                child: vm.isLoading
                    ? Center(child: CircularProgressIndicator())
                    : vm.expenses.isEmpty
                    ? Center(child: Text("No expenses for this date"))
                    : ListView.builder(
                        itemCount: vm.expenses.length,
                        itemBuilder: (context, index) {
                          final expense = vm.expenses[index];
                          return Dismissible(
                            key: Key(expense.id.toString()),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              padding: EdgeInsets.only(right: 20.w),
                              child: Icon(
                                Icons.delete,
                                color: Colors.white,
                                size: 30.sp,
                              ),
                            ),
                            confirmDismiss: (direction) async {
                              return await showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text("Delete Expense"),
                                  content: Text(
                                    "Are you sure you want to delete '${expense.title}'?",
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: Text("Cancel"),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                      ),
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: Text(
                                        "Delete",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                            onDismissed: (direction) async {
                              await Provider.of<DailyExpenseViewModel>(
                                context,
                                listen: false,
                              ).deleteExpense(expense.id!, selectedDate);
                            },
                            child: Card(
                              margin: EdgeInsets.symmetric(
                                horizontal: 20.w,
                                vertical: 8.h,
                              ),
                              child: ListTile(
                                leading: Icon(
                                  Icons.money_off,
                                  color: Colors.red,
                                ),
                                title: Text(expense.title),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      "${expense.amount} DA",
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20.sp,
                                      ),
                                    ),
                                    SizedBox(width: 10.w),
                                    IconButton(
                                      icon: Icon(
                                        Icons.delete_outline,
                                        color: Colors.grey,
                                      ),
                                      onPressed: () => _deleteExpense(
                                        expense.id!,
                                        expense.title,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
              SizedBox(height: 10.h),
              // ---------- SUMMARY BUTTON ----------
              Container(
                margin: EdgeInsets.only(bottom: 20.h),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.mainColor,
                    padding: EdgeInsets.symmetric(
                      horizontal: 30.w,
                      vertical: 15.h,
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => SummaryScreen()),
                    );
                  },
                  child: Text(
                    'View Summary',
                    style: TextStyle(
                      color: AppColor.whitecolor,
                      fontSize: 18.sp,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
