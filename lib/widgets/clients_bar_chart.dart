import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ClientsBarChart extends StatelessWidget {
  final int total;
  final int active;
  final int expired;

  ClientsBarChart({
    required this.total,
    required this.active,
    required this.expired,
  });

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        barGroups: [
          BarChartGroupData(
            x: 0,
            barRods: [BarChartRodData(toY: total.toDouble())],
          ),
          BarChartGroupData(
            x: 1,
            barRods: [BarChartRodData(toY: active.toDouble())],
          ),
          BarChartGroupData(
            x: 2,
            barRods: [BarChartRodData(toY: expired.toDouble())],
          ),
        ],
      ),
    );
  }
}
