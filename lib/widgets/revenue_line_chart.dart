// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// class RevenueLineChart extends StatelessWidget {
//   final List<int> revenueData;

//   const RevenueLineChart({super.key, required this.revenueData});

//   @override
//   Widget build(BuildContext context) {
//     final spots = revenueData.asMap().entries.map((e) {
//       return FlSpot(e.key.toDouble(), e.value.toDouble());
//     }).toList();

//     // Prevent crash when all values are 0
//     final maxRevenue = revenueData.reduce((a, b) => a > b ? a : b);
//     final safeMax = maxRevenue == 0 ? 10.0 : maxRevenue * 1.2;

//     // Increase interval for better readability
//     final interval = safeMax / 4; // fewer labels, more spacing

//     final currencyFormatter = NumberFormat.currency(
//       locale: 'fr_DZ',
//       symbol: 'DZD ',
//       decimalDigits: 0,
//     );

//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black12,
//             blurRadius: 8,
//             spreadRadius: 2,
//             offset: Offset(2, 4),
//           ),
//         ],
//       ),
//       height: 300,
//       child: LineChart(
//         LineChartData(
//           minX: 0,
//           maxX: 29,
//           minY: 0,
//           maxY: safeMax,
//           gridData: FlGridData(
//             show: true,
//             horizontalInterval: interval,
//             getDrawingHorizontalLine: (value) {
//               return FlLine(
//                 color: Colors.grey.withOpacity(0.2),
//                 strokeWidth: 1,
//               );
//             },
//             drawVerticalLine: false,
//           ),
//           titlesData: FlTitlesData(
//             bottomTitles: AxisTitles(
//               sideTitles: SideTitles(
//                 showTitles: true,
//                 reservedSize: 30,
//                 interval: 4, // show every 4th day
//                 getTitlesWidget: (value, meta) {
//                   final date = DateTime.now().subtract(
//                     Duration(days: 29 - value.toInt()),
//                   );
//                   final formatter = DateFormat('MM/dd');
//                   return Padding(
//                     padding: const EdgeInsets.only(top: 4),
//                     child: Text(
//                       formatter.format(date),
//                       style: TextStyle(color: Colors.grey[600], fontSize: 12),
//                     ),
//                   );
//                 },
//               ),
//             ),
//             leftTitles: AxisTitles(
//               sideTitles: SideTitles(
//                 showTitles: true,
//                 interval: interval,
//                 reservedSize: 60, // space for labels
//                 getTitlesWidget: (value, meta) {
//                   return Text(
//                     currencyFormatter.format(value),
//                     style: TextStyle(color: Colors.grey[600], fontSize: 12),
//                   );
//                 },
//               ),
//             ),
//             topTitles: const AxisTitles(
//               sideTitles: SideTitles(showTitles: false),
//             ),
//             rightTitles: const AxisTitles(
//               sideTitles: SideTitles(showTitles: false),
//             ),
//           ),
//           borderData: FlBorderData(show: false),
//           lineBarsData: [
//             LineChartBarData(
//               spots: spots,
//               isCurved: true,
//               gradient: LinearGradient(
//                 colors: [Colors.blueAccent, Colors.blue.shade900],
//               ),
//               barWidth: 4,
//               isStrokeCapRound: true,
//               dotData: FlDotData(show: true),
//               belowBarData: BarAreaData(
//                 show: true,
//                 gradient: LinearGradient(
//                   colors: [
//                     Colors.blueAccent.withOpacity(0.3),
//                     Colors.lightBlueAccent.withOpacity(0.0),
//                   ],
//                   begin: Alignment.topCenter,
//                   end: Alignment.bottomCenter,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RevenueLineChart extends StatelessWidget {
  final List<int> revenueData;
  final List<int> expenseData;

  const RevenueLineChart({
    super.key,
    required this.revenueData,
    required this.expenseData,
  });

  @override
  Widget build(BuildContext context) {
    // Revenue spots
    final revenueSpots = revenueData.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.toDouble());
    }).toList();

    // Expense spots
    final expenseSpots = expenseData.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.toDouble());
    }).toList();

    // Max Y from both
    final maxRevenue = revenueData.isEmpty
        ? 0
        : revenueData.reduce((a, b) => a > b ? a : b);
    final maxExpense = expenseData.isEmpty
        ? 0
        : expenseData.reduce((a, b) => a > b ? a : b);

    final maxYValue = maxRevenue > maxExpense ? maxRevenue : maxExpense;
    final safeMax = maxYValue == 0 ? 10.0 : maxYValue * 1.2;
    final interval = safeMax / 4;

    final currencyFormatter = NumberFormat.currency(
      locale: 'fr_DZ',
      symbol: 'DA ',
      decimalDigits: 0,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      height: 340,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            spreadRadius: 2,
            offset: Offset(2, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // LEGEND
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _legendItem(Colors.blueAccent, "Revenue"),
              const SizedBox(width: 20),
              _legendItem(Colors.redAccent, "Expenses"),
            ],
          ),

          const SizedBox(height: 16),

          Expanded(
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: 29,
                minY: 0,
                maxY: safeMax,

                gridData: FlGridData(
                  show: true,
                  horizontalInterval: interval,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.withOpacity(0.2),
                      strokeWidth: 1,
                    );
                  },
                ),

                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 4,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        final date = DateTime.now().subtract(
                          Duration(days: 29 - value.toInt()),
                        );
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            DateFormat('MM/dd').format(date),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: interval,
                      reservedSize: 60,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          currencyFormatter.format(value),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
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
                  // 🔵 REVENUE LINE
                  LineChartBarData(
                    spots: revenueSpots,
                    isCurved: true,
                    gradient: LinearGradient(
                      colors: [Colors.blueAccent, Colors.blue.shade900],
                    ),
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          Colors.blueAccent.withOpacity(0.25),
                          Colors.transparent,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),

                  // 🔴 EXPENSE LINE
                  LineChartBarData(
                    spots: expenseSpots,
                    isCurved: true,
                    color: Colors.redAccent,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
