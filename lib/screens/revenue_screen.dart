import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gym_manager/const/colors.dart';
import 'package:gym_manager/view_models/reveniew_viewmodel.dart';

import 'package:provider/provider.dart';

import '../widgets/counter_row.dart';

class RevenueScreen extends StatefulWidget {
  @override
  _RevenueScreenState createState() => _RevenueScreenState();
}

class _RevenueScreenState extends State<RevenueScreen> {
  @override
  void initState() {
    super.initState();
    // load today's saved counters if any
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
          icon: Icon(Icons.arrow_back, color: AppColor.whitecolor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: AppColor.mainColor,
        title: Text(
          "Daily Revenue",
          style: TextStyle(color: AppColor.whitecolor, fontSize: 22.sp),
        ),
      ),
      backgroundColor: Colors.grey[200],
      body: Consumer<RevenueViewModel>(
        builder: (context, vm, child) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 50.w),
            child: Column(
              children: [
                SizedBox(height: 30.h),
                ...vm.items.map(
                  (it) => CounterRow(
                    label: it.label,
                    price: it.price,
                    count: it.count,
                    onIncrement: () => vm.increment(it.key),
                    onDecrement: () => vm.decrement(it.key),
                  ),
                ),
                SizedBox(height: 40.h),
                // Total
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(
                          "TOTAL REVENUE",
                          style: TextStyle(
                            fontSize: 25.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "${vm.total} DA",
                          style: TextStyle(
                            fontSize: 40.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      height: 50.h,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.mainColor,
                          padding: EdgeInsets.symmetric(
                            vertical: 12.h,
                            horizontal: 20.w,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.r),
                          ),
                        ),
                        icon: vm.isSaving
                            ? CircularProgressIndicator(
                                color: AppColor.whitecolor,
                                strokeWidth: 2,
                              )
                            : Icon(Icons.save, color: AppColor.whitecolor),
                        label: Text(
                          "Save Today's Revenue",
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: AppColor.whitecolor,
                          ),
                        ),
                        onPressed: vm.isSaving
                            ? null
                            : () async {
                                await vm.saveTodayRevenue();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  snackBarAnimationStyle: AnimationStyle(
                                    curve: Curves.easeInQuad,
                                    duration: Duration(milliseconds: 500),
                                    reverseCurve: Curves.easeOut,
                                  ),
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

                // Save Button
              ],
            ),
          );
        },
      ),
    );
  }
}
