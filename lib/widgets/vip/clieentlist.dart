import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gym_manager/const/colors.dart';
import 'package:gym_manager/models/vipclient.dart';
import 'package:gym_manager/view_models/vip_viewmodel.dart';
import 'package:gym_manager/widgets/snakbar.dart';
import 'package:provider/provider.dart';

class Clieentlist extends StatefulWidget {
  const Clieentlist({super.key});

  @override
  State<Clieentlist> createState() => _ClieentlistState();
}

class _ClieentlistState extends State<Clieentlist> {
  @override
  Widget build(BuildContext context) {
    return Consumer<VipClientViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (viewModel.errorMessage != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(viewModel.errorMessage!),
                SizedBox(height: 16.h),
                ElevatedButton(
                  onPressed: () => viewModel.loadVipClients(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (viewModel.vipClients.isEmpty) {
          return const Center(
            child: Text('No VIP clients found.\nTap + to add one!'),
          );
        }

        return ListView.builder(
          itemCount: viewModel.vipClients.length,
          itemBuilder: (context, index) {
            final client = viewModel.vipClients[index];
            return _buildClientCard(client, viewModel);
          },
        );
      },
    );
  }

  Widget _buildClientCard(VipClient client, VipClientViewModel viewModel) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: InkWell(
        onTap: () => _showClientDetailsDialog(context, client, viewModel),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: client.photo != null
                    ? FileImage(File(client.photo!))
                    : null,
                child: client.photo == null
                    ? Text(
                        client.name[0].toUpperCase(),
                        style: const TextStyle(fontSize: 24),
                      )
                    : null,
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      client.name,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${client.age} years • ${client.phone}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          client.isActive ? Icons.check_circle : Icons.cancel,
                          size: 16,
                          color: client.isActive ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          client.isActive
                              ? '${client.daysRemaining} days left'
                              : 'Expired',
                          style: TextStyle(
                            color: client.isActive ? Colors.green : Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    if (client.latestWeight != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Weight: ${client.latestWeight!.toStringAsFixed(1)} kg',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              PopupMenuButton(
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 20),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'extend',
                    child: Row(
                      children: [
                        Icon(Icons.update, size: 20),
                        SizedBox(width: 8),
                        Text('Extend'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'weight',
                    child: Row(
                      children: [
                        Icon(Icons.monitor_weight, size: 20),
                        SizedBox(width: 8),
                        Text('Add Weight'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 20, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      _showEditClientDialog(context, client, viewModel);
                      break;
                    case 'extend':
                      _showExtendMembershipDialog(context, client, viewModel);
                      break;
                    case 'weight':
                      _showAddWeightDialog(context, client, viewModel);
                      break;
                    case 'delete':
                      _showDeleteConfirmation(context, client, viewModel);
                      break;
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showClientDetailsDialog(
    BuildContext context,
    VipClient client,
    VipClientViewModel viewModel,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(client.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Age', '${client.age} years'),
              _buildDetailRow('Phone', client.phone),
              _buildDetailRow(
                'Status',
                client.isActive ? 'Active' : 'Expired',
                color: client.isActive ? Colors.green : Colors.red,
              ),
              _buildDetailRow('Days Remaining', '${client.daysRemaining} days'),
              _buildDetailRow(
                'Start Date',
                '${client.startDate.day}/${client.startDate.month}/${client.startDate.year}',
              ),
              _buildDetailRow(
                'End Date',
                '${client.endDate.day}/${client.endDate.month}/${client.endDate.year}',
              ),
              const Divider(),
              const Text(
                'Weight History',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              if (client.weights.isEmpty)
                const Text('No weight records')
              else
                ...client.weights.map(
                  (w) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${w.date.day}/${w.date.month}/${w.date.year}'),
                        Text('${w.weight.toStringAsFixed(1)} kg'),
                      ],
                    ),
                  ),
                ),
              if (client.weightProgress != null) ...[
                const Divider(),
                _buildDetailRow(
                  'Progress',
                  '${client.weightProgress!.toStringAsFixed(1)} kg',
                  color: client.weightProgress! < 0
                      ? Colors.green
                      : Colors.orange,
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(AppColor.mainColor),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Close',
              style: TextStyle(color: AppColor.whitecolor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: TextStyle(color: color ?? Colors.black87)),
        ],
      ),
    );
  }

  void _showAddWeightDialog(
    BuildContext context,
    VipClient client,
    VipClientViewModel viewModel,
  ) {
    final weightController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Add Weight Entry'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: weightController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Weight (kg)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Date'),
                  subtitle: Text(
                    '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setDialogState(() {
                        selectedDate = date;
                      });
                    }
                    // setDialogState() {
                    //   if (date != null) {
                    //     selectedDate = date;
                    //   }
                    // }

                    ;
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                    AppColor.mainColor,
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                    AppColor.mainColor,
                  ),
                ),
                onPressed: () async {
                  if (weightController.text.isEmpty ||
                      double.parse(weightController.text) <= 30) {
                    CustomSnackBar.showError(
                      context,
                      'please enter a valid weight',
                    );
                    return Navigator.pop(context);
                  }

                  final entry = WeightEntry(
                    date: selectedDate,
                    weight: double.parse(weightController.text),
                  );

                  final success = await viewModel.addWeightEntry(
                    client.id!,
                    entry,
                  );

                  Navigator.pop(context);

                  if (success) {
                    CustomSnackBar.showSuccess(
                      context,
                      'Weight entry added successfully',
                    );
                  }
                },
                child: const Text(
                  'Add',
                  style: TextStyle(color: AppColor.whitecolor),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showExtendMembershipDialog(
    BuildContext context,
    VipClient client,
    VipClientViewModel viewModel,
  ) {
    final daysController = TextEditingController(text: '30');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Extend Membership'),
        content: TextField(
          controller: daysController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Number of Days',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(AppColor.mainColor),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(AppColor.mainColor),
            ),
            onPressed: () async {
              final days = int.tryParse(daysController.text);
              if (days == null || days <= 0) {
                CustomSnackBar.showError(context, 'Please enter valid days');
                return Navigator.pop(context);
              }

              final success = await viewModel.extendMembership(
                client.id!,
                days,
              );

              Navigator.pop(context);

              if (success) {
                CustomSnackBar.showSuccess(
                  context,
                  'Membership extended by $days days',
                );
              }
            },
            child: const Text('Extend', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEditClientDialog(
    BuildContext context,
    VipClient client,
    VipClientViewModel viewModel,
  ) {
    final nameController = TextEditingController(text: client.name);
    final ageController = TextEditingController(text: client.age.toString());
    final phoneController = TextEditingController(text: client.phone);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit VIP Client'),
        content: Column(
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
          ],
        ),
        actions: [
          TextButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(AppColor.mainColor),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.mainColor,
            ),
            onPressed: () async {
              final updatedClient = client.copyWith(
                name: nameController.text,
                age: int.parse(ageController.text),
                phone: phoneController.text,
              );

              final success = await viewModel.updateVipClient(updatedClient);

              Navigator.pop(context);

              if (success) {
                CustomSnackBar.showSuccess(
                  context,
                  'Client updated successfully',
                );
              }
            },
            child: const Text(
              'Update',
              style: TextStyle(color: AppColor.whitecolor),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    VipClient client,
    VipClientViewModel viewModel,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Client'),
        content: Text('Are you sure you want to delete ${client.name}?'),
        actions: [
          TextButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(AppColor.mainColor),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final success = await viewModel.deleteVipClient(client.id!);

              Navigator.pop(context);

              if (success) {
                CustomSnackBar.showSuccess(
                  context,
                  'Client deleted successfully',
                );
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColor.whitecolor),
            ),
          ),
        ],
      ),
    );
  }
}
