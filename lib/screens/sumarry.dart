import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:gym_manager/view_models/summaryviewmodel.dart'
    show SummaryViewModel;

class SummaryScreen extends StatelessWidget {
  const SummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SummaryViewModel()..loadSummary(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Summary'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                context.read<SummaryViewModel>().loadSummary();
              },
            ),
          ],
        ),
        body: Consumer<SummaryViewModel>(
          builder: (context, vm, _) {
            if (vm.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return RefreshIndicator(
              onRefresh: () async => vm.loadSummary(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Date Range Display
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            DateFormat('dd MMM yyyy').format(vm.selectedDate),
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Financial Cards
                      _card(
                        title: 'Total Revenue',
                        value: vm.totalRevenue,
                        color: Colors.green,
                        icon: Icons.arrow_upward,
                      ),
                      _card(
                        title: 'Total Expenses',
                        value: vm.totalExpenses,
                        color: Colors.red,
                        icon: Icons.arrow_downward,
                      ),
                      _card(
                        title: 'Net Balance',
                        value: vm.netBalance,
                        color: vm.netBalance >= 0 ? Colors.blue : Colors.orange,
                        icon: vm.netBalance >= 0
                            ? Icons.trending_up
                            : Icons.trending_down,
                      ),

                      const SizedBox(height: 24),

                      // Date Selection
                      Center(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.date_range),
                          label: const Text('Change Date'),
                          onPressed: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: vm.selectedDate,
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                            );
                            if (date != null) vm.changeDate(date);
                          },
                        ),
                      ),

                      // Optional: Add insights
                      if (vm.totalRevenue > 0 || vm.totalExpenses > 0)
                        _insightsSection(vm),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _card({
    required String title,
    required int value,
    required Color color,
    IconData? icon,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: icon != null
            ? CircleAvatar(
                backgroundColor: color.withOpacity(0.1),
                child: Icon(icon, color: color, size: 20),
              )
            : null,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: Text(
          _formatCurrency(value),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }

  Widget _insightsSection(SummaryViewModel vm) {
    final profitMargin = vm.totalRevenue > 0
        ? ((vm.netBalance / vm.totalRevenue) * 100)
        : 0;

    return Card(
      margin: const EdgeInsets.only(top: 20),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Insights',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.insights, size: 16, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Profit Margin: ${profitMargin.toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: profitMargin >= 0 ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.account_balance_wallet,
                  size: 16,
                  color: Colors.blue,
                ),
                const SizedBox(width: 8),
                Text(
                  'Expense Ratio: ${(vm.totalExpenses / (vm.totalRevenue == 0 ? 1 : vm.totalRevenue)).toStringAsFixed(1)}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatCurrency(int value) {
    return '${value.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} DA';
  }
}
