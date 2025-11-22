import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class RevenueLineChart extends StatelessWidget {
  final List<double> data;

  RevenueLineChart({required this.data});

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: data
                .asMap()
                .entries
                .map((e) => FlSpot(e.key.toDouble(), e.value))
                .toList(),
            barWidth: 3,
            dotData: FlDotData(show: true),
          ),
        ],
      ),
    );
  }
}
