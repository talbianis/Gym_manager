import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ClientsBarChart extends StatelessWidget {
  final String total;
  final int active;
  final int expired;

  const ClientsBarChart({
    super.key,
    required this.total,
    required this.active,
    required this.expired,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 97, 105, 109),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Clients Overview",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 260,
            child: BarChart(
              BarChartData(
                maxY: _maxValue(),
                minY: 0, // Explicitly set minY to 0
                alignment: BarChartAlignment.spaceAround,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      String title;
                      switch (group.x.toInt()) {
                        case 0:
                          title = 'Total clients';
                          break;
                        case 1:
                          title = 'Active clients';
                          break;
                        case 2:
                          title = 'Expired clients';
                          break;
                        default:
                          title = '';
                      }

                      final value = rod.toY.toInt();
                      return BarTooltipItem(
                        '$title\n$value',
                        const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),

                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 38,
                      getTitlesWidget: (value, meta) {
                        switch (value.toInt()) {
                          case 0:
                            return const Text("Total");
                          case 1:
                            return const Text("Active");
                          case 2:
                            return const Text("Expired");
                          default:
                            return const Text("");
                        }
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      interval: _gridInterval(), // Add interval here too
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),

                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: _gridInterval(),
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.grey.withOpacity(0.15),
                    strokeWidth: 1,
                  ),
                ),

                borderData: FlBorderData(show: false),

                barGroups: [
                  _buildBar(
                    x: 0,
                    value: double.parse(total),
                    color1: Colors.blueAccent,
                    color2: Colors.blue.shade200,
                  ),
                  _buildBar(
                    x: 1,
                    value: active.toDouble(),
                    color1: Colors.greenAccent.shade700,
                    color2: Colors.greenAccent,
                  ),
                  _buildBar(
                    x: 2,
                    value: expired.toDouble(),
                    color1: Colors.redAccent,
                    color2: Colors.red.shade200,
                  ),
                ],
              ),
              swapAnimationDuration: const Duration(milliseconds: 600),
              swapAnimationCurve: Curves.easeOut,
            ),
          ),
        ],
      ),
    );
  }

  // ---- Helpers ---- //

  BarChartGroupData _buildBar({
    required int x,
    required double value,
    required Color color1,
    required Color color2,
  }) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: value,
          borderRadius: BorderRadius.circular(10),
          width: 26,
          gradient: LinearGradient(
            colors: [color1, color2],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: _maxValue(),
            color: Colors.grey.withOpacity(0.1),
          ),
        ),
      ],
    );
  }

  double _maxValue() {
    final values = [double.parse(total), active.toDouble(), expired.toDouble()];
    final max = values.reduce((a, b) => a > b ? a : b);
    // If all values are zero, return a default max value to avoid zero interval
    if (max == 0) {
      return 10.0; // Default max when all values are zero
    }
    return max + (max * 0.2); // add 20% padding
  }

  double _gridInterval() {
    final max = _maxValue();
    final interval = (max / 5).ceilToDouble();
    // Ensure interval is never zero
    return interval > 0 ? interval : 2.0;
  }
}
