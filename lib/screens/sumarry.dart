import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gym_manager/const/colors.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:gym_manager/view_models/summaryviewmodel.dart'
    show SummaryViewModel;

class SummaryScreen extends StatelessWidget {
  const SummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SummaryViewModel()..loadSummary(),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back_ios, color: AppColor.whitecolor),
          ),
          backgroundColor: AppColor.mainColor,
          title: Text(
            'Summary',
            style: TextStyle(color: AppColor.whitecolor, fontSize: 25.sp),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                context.read<SummaryViewModel>().loadSummary();
              },
            ),
          ],
        ),
        body: Consumer<SummaryViewModel>(
          builder: (context, vm, _) {
            if (vm.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return RefreshIndicator(
              onRefresh: () async => vm.loadSummary(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Date Range Display
                      Row(
                        children: [
                          Icon(Icons.calendar_today, size: 16.sp),
                          SizedBox(width: 8.w),
                          Text(
                            DateFormat('dd MMM yyyy').format(vm.selectedDate),
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),

                      // Financial Cards
                      _card(
                        title: 'Total Revenue',
                        value: vm.totalRevenue,
                        color: AppColor.successcolor,
                        icon: Icons.arrow_upward,
                      ),
                      _card(
                        title: 'Total Expenses',
                        value: vm.totalExpenses,
                        color: AppColor.warningcolor,
                        icon: Icons.arrow_downward,
                      ),
                      _card(
                        title: 'Net Balance',
                        value: vm.netBalance,
                        color: vm.netBalance >= 0 ? Colors.blue : Colors.orange,
                        icon: vm.netBalance >= 0
                            ? Icons.trending_up
                            : Icons.trending_down,
                      ),

                      SizedBox(height: 24.h),

                      // Date Selection
                      Center(
                        child: ElevatedButton.icon(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                              AppColor.mainColor,
                            ),
                            padding: MaterialStateProperty.all(
                              EdgeInsets.symmetric(
                                horizontal: 20.w,
                                vertical: 10.h,
                              ),
                            ),
                            shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.r),
                                side: BorderSide(
                                  color: AppColor.mainColor,
                                  width: 2.w,
                                ),
                              ),
                            ),
                          ),
                          icon: const Icon(
                            Icons.date_range,
                            color: AppColor.whitecolor,
                          ),
                          label: Text(
                            'Change Date',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: AppColor.whitecolor,
                              fontSize: 22.sp,
                            ),
                          ),
                          onPressed: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: vm.selectedDate,
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                            );
                            if (date != null) vm.changeDate(date);
                          },
                        ),
                      ),

                      // Optional: Add insights
                      if (vm.totalRevenue > 0 || vm.totalExpenses > 0)
                        _insightsSection(vm),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _card({
    required String title,
    required int value,
    required Color color,
    IconData? icon,
  }) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: 15.h),
      child: ListTile(
        leading: icon != null
            ? CircleAvatar(
                backgroundColor: color.withOpacity(0.1),
                child: Icon(icon, color: color, size: 20),
              )
            : null,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: Text(
          _formatCurrency(value),
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }

  Widget _insightsSection(SummaryViewModel vm) {
    final profitMargin = vm.totalRevenue > 0
        ? ((vm.netBalance / vm.totalRevenue) * 100)
        : 0;

    return Card(
      margin: EdgeInsets.only(top: 20.h),
      child: Padding(
        padding: EdgeInsets.all(16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Insights',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Icon(Icons.insights, size: 16.sp, color: Colors.blue),
                SizedBox(width: 8.w),
                Text(
                  'Profit Margin: ${profitMargin.toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: profitMargin >= 0 ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Row(
              children: [
                const Icon(
                  Icons.account_balance_wallet,
                  size: 16,
                  color: Colors.blue,
                ),
                SizedBox(width: 8.w),
                Text(
                  'Expense Ratio: ${(vm.totalExpenses / (vm.totalRevenue == 0 ? 1 : vm.totalRevenue)).toStringAsFixed(1)}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatCurrency(int value) {
    return '${value.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} DA';
  }
}
