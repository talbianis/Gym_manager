import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gym_manager/const/colors.dart';
import 'package:gym_manager/screens/clients_screen.dart';
import 'package:gym_manager/screens/expired_client.dart';
import 'package:gym_manager/screens/revenue_screen.dart';
import 'package:gym_manager/view_models/client_viewmodel.dart';
import 'package:gym_manager/view_models/daili_expense_viewmodel.dart';
import 'package:gym_manager/view_models/reveniew_viewmodel.dart';
import 'package:gym_manager/widgets/clients_bar_chart.dart';
import 'package:gym_manager/widgets/revenue_line_chart.dart';
import 'package:gym_manager/widgets/sidebar.dart';
import 'package:gym_manager/widgets/stat_card.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _initialized = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_initialized) {
      _initialized = true;

      // Load after widget is fully mounted
      Future.microtask(() {
        Provider.of<ClientViewModel>(context, listen: false).loadClients();
        Provider.of<RevenueViewModel>(
          context,
          listen: false,
        ).loadTodayRevenueToCounters();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Container(
        color: AppColor.greycolor.shade400,
        child: Row(
          children: [
            SideBar(),
            SizedBox(width: 20.w),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Gym Manager Dashboard',
                                style: TextStyle(
                                  fontSize: 24.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppColor.whitecolor,
                                ),
                              ),
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 25.r,
                                    backgroundImage: AssetImage(
                                      'assets/images/alilast2.jpg',
                                    ),
                                  ),
                                  SizedBox(width: 15.w),
                                  Text(
                                    'Ali Ziainia',
                                    style: TextStyle(
                                      color: AppColor.whitecolor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 25.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Container(
                          height: 150.h,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.r),
                            color: Colors.white,
                          ),
                          child: Column(
                            children: [
                              SizedBox(height: 10.h),
                              Padding(
                                padding: const EdgeInsets.only(left: 1),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(width: 20.w),
                                    Consumer<ClientViewModel>(
                                      builder: (context, value, child) =>
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      ClientsScreen(),
                                                ),
                                              );
                                            },
                                            child: StatCard(
                                              color: AppColor.blackcolor,
                                              title: "Total Clients",
                                              value: value.clients.length
                                                  .toString(),
                                            ),
                                          ),
                                    ),
                                    SizedBox(width: 80.w),
                                    Consumer<ClientViewModel>(
                                      builder: (context, value, child) =>
                                          StatCard(
                                            color: AppColor.successcolor,
                                            title: "Active",
                                            value:
                                                (value.clients.length -
                                                        value
                                                            .expiredClients
                                                            .length)
                                                    .toString(),
                                          ),
                                    ),
                                    SizedBox(width: 80.w),
                                    Consumer<ClientViewModel>(
                                      builder: (context, value, child) =>
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      ExpiredClientsScreen(),
                                                ),
                                              );
                                            },
                                            child: StatCard(
                                              color: AppColor.warningcolor,
                                              title: "Expired",
                                              value: value.expiredClients.length
                                                  .toString(),
                                            ),
                                          ),
                                    ),
                                    SizedBox(width: 80.w),
                                    Consumer<RevenueViewModel>(
                                      builder: (context, revValue, child) =>
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      RevenueScreen(),
                                                ),
                                              );
                                            },
                                            child: StatCard(
                                              color: Colors.blue.shade900,
                                              title: "Today Revenue",
                                              value:
                                                  revValue.total.toString() +
                                                  " DA",
                                            ),
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),

                    // --- Line Chart (30 days revenue) ---
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: EdgeInsets.all(20.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(color: Colors.black12, blurRadius: 6),
                          ],
                        ),
                        child:
                            Consumer2<RevenueViewModel, DailyExpenseViewModel>(
                              builder: (context, revVM, expVM, child) =>
                                  FutureBuilder<List<List<int>>>(
                                    future: Future.wait<List<int>>([
                                      revVM.getLast30DaysRevenue(),
                                      expVM.getLast30DaysExpenses(),
                                    ]),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      }

                                      if (snapshot.hasError ||
                                          !snapshot.hasData) {
                                        return const Center(
                                          child: Text(
                                            'Error loading chart data',
                                          ),
                                        );
                                      }

                                      final revenueData = snapshot.data![0];
                                      final expenseData = snapshot.data![1];

                                      return RevenueLineChart(
                                        revenueData: revenueData,
                                        expenseData: expenseData,
                                      );
                                    },
                                  ),
                            ),
                      ),
                    ),
                    SizedBox(height: 12.h),

                    // --- Bar Chart (clients overview) ---
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: EdgeInsets.all(20.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(color: Colors.black12, blurRadius: 6),
                          ],
                        ),
                        child: Consumer<ClientViewModel>(
                          builder: (context, clientVM, child) =>
                              ClientsBarChart(
                                active:
                                    clientVM.clients.length -
                                    clientVM.expiredClients.length,
                                expired: clientVM.expiredClients.length,
                                total: clientVM.clients.length.toString(),
                              ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
