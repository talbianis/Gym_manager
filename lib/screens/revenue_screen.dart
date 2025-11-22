import 'package:flutter/material.dart';
import 'package:gym_manager/view_models/reveniew_viewmodel.dart';

import 'package:provider/provider.dart';

import '../widgets/counter_row.dart';

class RevenueScreen extends StatefulWidget {
  @override
  _RevenueScreenState createState() => _RevenueScreenState();
}

class _RevenueScreenState extends State<RevenueScreen> {
  @override
  void initState() {
    super.initState();
    // load today's saved counters if any
    Provider.of<RevenueViewModel>(
      context,
      listen: false,
    ).loadTodayRevenueToCounters();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Daily Revenue")),
      body: Consumer<RevenueViewModel>(
        builder: (context, vm, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Items list
                ...vm.items.map(
                  (it) => CounterRow(
                    label: it.label,
                    price: it.price,
                    count: it.count,
                    onIncrement: () => vm.increment(it.key),
                    onDecrement: () => vm.decrement(it.key),
                  ),
                ),
                const SizedBox(height: 20),
                // Total
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "TOTAL",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "${vm.total} DA",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Save Button
                ElevatedButton.icon(
                  icon: vm.isSaving
                      ? CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        )
                      : Icon(Icons.save),
                  label: Text("Save Today's Revenue"),
                  onPressed: vm.isSaving
                      ? null
                      : () async {
                          await vm.saveTodayRevenue();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Today's revenue saved")),
                          );
                        },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
