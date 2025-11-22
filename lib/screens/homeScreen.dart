import 'package:flutter/material.dart';
import 'package:gym_manager/const/colors.dart';
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
  void initState() {
    super.initState();

    Provider.of<ClientViewModel>(context, listen: false).loadClients();

    Provider.of<RevenueViewModel>(
      context,
      listen: false,
    ).loadTodayRevenueToCounters();
  }

  int get expiredCount => Provider.of<ClientViewModel>(
    context,
    listen: false,
  ).expiredClients.length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Center(
          child: Text(
            "Gym Manager Dashboard",
            style: TextStyle(color: Colors.white),
          ),
        ),
        backgroundColor: AppColor.mainColor,
      ),
      body: Row(
        children: [
          SideBar(),
          SizedBox(width: 40),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Consumer<ClientViewModel>(
                        builder: (context, value, child) => StatCard(
                          title: "Total Clients",
                          value: value.clients.length.toString(),
                        ),
                      ),
                      StatCard(title: "Active", value: "95"),
                      Consumer<ClientViewModel>(
                        builder: (context, value, child) => StatCard(
                          title: "Expired",
                          value: value.expiredClients.length.toString(),
                        ),
                      ),
                      Consumer<RevenueViewModel>(
                        builder: (context, revValue, child) => StatCard(
                          title: "Today Revenue",
                          value: revValue.total.toString() + " DA",
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 50),
                  Expanded(
                    flex: 3,

                    child: Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: Colors.black12, blurRadius: 6),
                        ],
                      ),
                      child: RevenueLineChart(
                        data: [
                          1200,
                          1500,
                          1000,
                          1800,
                          2100,
                          2300,
                          1700,
                          2000,
                          1900,
                          2500,
                          2600,
                          3000,
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: Colors.black12, blurRadius: 6),
                        ],
                      ),
                      child: Consumer<ClientViewModel>(
                        builder: (context, clientVM, child) => ClientsBarChart(
                          active: 30,
                          expired: 20,
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
    );
  }
}
