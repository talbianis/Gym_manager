import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RevenueLineChart extends StatelessWidget {
  final List<int> revenueData;

  const RevenueLineChart({super.key, required this.revenueData});

  @override
  Widget build(BuildContext context) {
    final spots = revenueData.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.toDouble());
    }).toList();

    // Prevent crash when all values are 0
    final maxRevenue = revenueData.reduce((a, b) => a > b ? a : b);
    final safeMax = maxRevenue == 0 ? 10.0 : maxRevenue * 1.2;

    // Increase interval for better readability
    final interval = safeMax / 4; // fewer labels, more spacing

    final currencyFormatter = NumberFormat.currency(
      locale: 'fr_DZ',
      symbol: 'DZD ',
      decimalDigits: 0,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            spreadRadius: 2,
            offset: Offset(2, 4),
          ),
        ],
      ),
      height: 300,
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: 29,
          minY: 0,
          maxY: safeMax,
          gridData: FlGridData(
            show: true,
            horizontalInterval: interval,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey.withOpacity(0.2),
                strokeWidth: 1,
              );
            },
            drawVerticalLine: false,
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 4, // show every 4th day
                getTitlesWidget: (value, meta) {
                  final date = DateTime.now().subtract(
                    Duration(days: 29 - value.toInt()),
                  );
                  final formatter = DateFormat('MM/dd');
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      formatter.format(date),
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: interval,
                reservedSize: 60, // space for labels
                getTitlesWidget: (value, meta) {
                  return Text(
                    currencyFormatter.format(value),
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              gradient: LinearGradient(
                colors: [Colors.blueAccent, Colors.lightBlueAccent],
              ),
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    Colors.blueAccent.withOpacity(0.3),
                    Colors.lightBlueAccent.withOpacity(0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
