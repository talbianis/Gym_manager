import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gym_manager/const/colors.dart';
import 'package:gym_manager/screens/clients_screen.dart';
import 'package:gym_manager/screens/expired_client.dart';
import 'package:gym_manager/screens/revenue_screen.dart';
import 'package:gym_manager/view_models/client_viewmodel.dart';
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
  @override
  void initState() {
    super.initState();

    Provider.of<ClientViewModel>(context, listen: false).loadClients();
    Provider.of<RevenueViewModel>(
      context,
      listen: false,
    ).loadTodayRevenueToCounters();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.mainColor,

      body: Container(
        color: AppColor.mainColor,
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
                          child: Text(
                            'Gym Manager Dashboard',
                            style: TextStyle(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
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
                                              color: Colors.blue,
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
                                            color: AppColor.blackcolor,
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
                                              color: Colors.red,
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
                                            onDoubleTap: () {
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      RevenueScreen(),
                                                ),
                                              );
                                            },
                                            child: StatCard(
                                              color: Colors.green,
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
                        child: Consumer<RevenueViewModel>(
                          builder: (context, revVM, child) =>
                              FutureBuilder<List<int>>(
                                future: revVM.getLast30DaysRevenue(),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }
                                  return RevenueLineChart(
                                    revenueData: snapshot.data!,
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
