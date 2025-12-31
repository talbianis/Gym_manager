import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gym_manager/models/vipclient.dart';

class BmiTrendChart extends StatelessWidget {
  final VipClient client;

  const BmiTrendChart({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    final data = client.bmiHistory;

    if (data.length < 2) {
      return const Center(child: Text("Not enough data to show BMI trend"));
    }

    return SizedBox(
      height: 100.h,
      width: 200.w,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: true),
          borderData: FlBorderData(show: true),
          titlesData: FlTitlesData(
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= data.length) {
                    return const SizedBox();
                  }
                  final d = data[index].date;
                  return Text('${d.day}/${d.month}');
                },
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(
                data.length,
                (i) => FlSpot(i.toDouble(), data[i].bmi),
              ),
              isCurved: true,
              barWidth: 3,
              dotData: FlDotData(show: true),
              color: client.bmi != null
                  ? client.bmiColor(client.bmi!)
                  : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
