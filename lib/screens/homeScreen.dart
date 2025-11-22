import 'package:flutter/material.dart';
import 'package:gym_manager/const/colors.dart';

import 'package:gym_manager/widgets/clients_bar_chart.dart';
import 'package:gym_manager/widgets/revenue_line_chart.dart';
import 'package:gym_manager/widgets/sidebar.dart';
import 'package:gym_manager/widgets/stat_card.dart';

class HomeScreen extends StatelessWidget {
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
                      StatCard(title: "Total Clients", value: "120"),
                      StatCard(title: "Active", value: "95"),
                      StatCard(title: "Expired", value: "25"),
                      StatCard(title: "Today Revenue", value: "8500 DA"),
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
                      child: ClientsBarChart(
                        active: 30,
                        expired: 20,
                        total: 150,
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
