import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gym_manager/const/colors.dart';
import 'package:gym_manager/screens/expense.dart';
import 'package:gym_manager/view_models/reveniew_viewmodel.dart';
import 'package:provider/provider.dart';
import '../widgets/counter_row.dart';

class RevenueScreen extends StatefulWidget {
  @override
  State<RevenueScreen> createState() => _RevenueScreenState();
}

class _RevenueScreenState extends State<RevenueScreen> {
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    Provider.of<RevenueViewModel>(
      context,
      listen: false,
    ).loadTodayRevenueToCounters();
  }

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
          "Daily Revenue",
          style: TextStyle(color: Colors.white, fontSize: 22.sp),
        ),
        backgroundColor: AppColor.mainColor,
      ),
      backgroundColor: Colors.grey[200],
      body: Consumer<RevenueViewModel>(
        builder: (context, vm, child) {
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 20.h),
            child: Column(
              children: [
                // Counters
                ...vm.items.map(
                  (it) => CounterRow(
                    icon: it.icon,
                    label: it.label,
                    price: it.price,
                    count: it.count,
                    onIncrement: () => vm.increment(it.key),
                    onDecrement: () => vm.decrement(it.key),
                  ),
                ),

                SizedBox(height: 40.h),

                // TOTAL
                Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: AppColor.whitecolor,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "TOTAL REVENUE",
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        "${vm.total} DA",
                        style: TextStyle(
                          fontSize: 36.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 30.h),

                // SAVE BUTTON
                ElevatedButton.icon(
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
                  icon: vm.isSaving
                      ? CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        )
                      : Icon(Icons.save, color: Colors.white),
                  label: Text(
                    "Save Revenue",
                    style: TextStyle(color: Colors.white, fontSize: 18.sp),
                  ),
                  onPressed: vm.isSaving
                      ? null
                      : () async {
                          await vm.saveTodayRevenue();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.green,
                              content: Text("Revenue saved successfully"),
                            ),
                          );
                        },
                ),
                SizedBox(height: 20.h),
                Container(
                  width: 200.w,
                  child: TextButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                        AppColor.mainColor,
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ExpenseScreen()),
                      );
                    },
                    child: Text(
                      'show expense',
                      style: TextStyle(
                        fontSize: 18.sp,
                        color: AppColor.whitecolor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
