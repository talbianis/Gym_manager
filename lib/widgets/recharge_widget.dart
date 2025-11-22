import 'package:flutter/material.dart';
import 'package:gym_manager/models/client.dart';
import 'package:gym_manager/view_models/client_viewmodel.dart'
    show ClientViewModel;
import 'package:provider/provider.dart';

void showRechargeDialog(Client client, BuildContext context) {
  DateTime rechargeStartDate = client.endDate; // default
  int monthsToAdd = 1;

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text("Recharge ${client.name}"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Current subscription ends on ${client.endDate}"),
                SizedBox(height: 10),
                Row(
                  children: [
                    Text("Start Date: "),
                    TextButton(
                      child: Text(
                        "${rechargeStartDate.year}-${rechargeStartDate.month}-${rechargeStartDate.day}",
                      ),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: rechargeStartDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() {
                            rechargeStartDate = picked; // rebuild UI
                          });
                        }
                      },
                    ),
                  ],
                ),
                SizedBox(height: 10),
                DropdownButton<int>(
                  value: monthsToAdd,
                  items: [1, 3, 6, 12]
                      .map(
                        (m) => DropdownMenuItem(
                          value: m,
                          child: Text("$m month(s)"),
                        ),
                      )
                      .toList(),
                  onChanged: (val) {
                    setState(() {
                      monthsToAdd = val!;
                    });
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                child: Text("Cancel"),
                onPressed: () => Navigator.pop(context),
              ),
              ElevatedButton(
                child: Text("Recharge"),
                onPressed: () {
                  final newEndDate = rechargeStartDate.add(
                    Duration(days: 30 * monthsToAdd),
                  );

                  Provider.of<ClientViewModel>(
                    context,
                    listen: false,
                  ).rechargeClient(client, newEndDate);

                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      );
    },
  );
}
