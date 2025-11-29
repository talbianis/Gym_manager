// utils/dialog_utils.dart
import 'package:flutter/material.dart';
import 'package:gym_manager/models/vipclient.dart';
import 'package:gym_manager/view_models/vip_viewmodel.dart';
import 'package:gym_manager/widgets/snakbar.dart';
import 'package:provider/provider.dart';

class DialogUtils {
  static Future<void> showAddClientDialog(BuildContext context) async {
    final nameController = TextEditingController();
    final ageController = TextEditingController();
    final phoneController = TextEditingController();
    final weightController = TextEditingController();

    DateTime startDate = DateTime.now();
    DateTime endDate = DateTime.now().add(const Duration(days: 30));

    return showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Add VIP Client'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: ageController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Age',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Phone',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: weightController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Initial Weight (kg)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: const Text('Start Date'),
                    subtitle: Text(
                      '${startDate.day}/${startDate.month}/${startDate.year}',
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: startDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (date != null) {
                        setDialogState(() {
                          startDate = date;
                          endDate = date.add(const Duration(days: 30));
                        });
                      }
                    },
                  ),
                  ListTile(
                    title: const Text('End Date'),
                    subtitle: Text(
                      '${endDate.day}/${endDate.month}/${endDate.year}',
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: endDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (date != null) {
                        setDialogState(() {
                          endDate = date;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (nameController.text.isEmpty ||
                      ageController.text.isEmpty ||
                      phoneController.text.isEmpty ||
                      weightController.text.isEmpty) {
                    CustomSnackBar.showError(
                      context,
                      'Please fill all required fields',
                    );
                    return;
                  }

                  final weight = double.tryParse(weightController.text);
                  if (weight == null || weight <= 30) {
                    CustomSnackBar.showWarning(
                      context,
                      'Please enter a valid weight',
                    );
                    return;
                  }

                  final weights = <WeightEntry>[
                    WeightEntry(date: DateTime.now(), weight: weight),
                  ];

                  final client = VipClient(
                    name: nameController.text,
                    age: int.parse(ageController.text),
                    phone: phoneController.text,
                    weights: weights,
                    startDate: startDate,
                    endDate: endDate,
                  );

                  final success = await Provider.of<VipClientViewModel>(
                    context,
                    listen: false,
                  ).addVipClient(client);

                  Navigator.pop(context);

                  if (success) {
                    CustomSnackBar.showSuccess(
                      context,
                      'VIP Client added successfully',
                    );
                  }
                },
                child: const Text('Add'),
              ),
            ],
          );
        },
      ),
    );
  }
}
