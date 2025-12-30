import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gym_manager/const/colors.dart';
import 'package:gym_manager/models/vipclient.dart';

import 'package:gym_manager/view_models/vip_viewmodel.dart';
import 'package:gym_manager/widgets/snakbar.dart';

import 'package:gym_manager/widgets/vip/builderchips.dart';
import 'package:gym_manager/widgets/vip/clieentlist.dart';

import 'package:gym_manager/widgets/vip/searchbarvip.dart';
import 'package:gym_manager/widgets/vip/statevipcard.dart';
import 'package:provider/provider.dart';

class VipClientsScreen extends StatefulWidget {
  const VipClientsScreen({Key? key}) : super(key: key);

  @override
  State<VipClientsScreen> createState() => _VipClientsScreenState();
}

class _VipClientsScreenState extends State<VipClientsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<VipClientViewModel>(context, listen: false).loadVipClients();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColor.whitecolor),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: AppColor.mainColor,
        title: Text(
          'VIP Clients',
          style: TextStyle(color: AppColor.whitecolor, fontSize: 22.sp),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: AppColor.whitecolor),
            onPressed: () => _showFilterDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          BuildStateCard(),
          Searchbarvip(),
          Builderchips(),
          Expanded(child: Clieentlist()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColor.mainColor,
        onPressed: () => showAddClientDialog(context),
        child: const Icon(Icons.add, color: AppColor.whitecolor),
      ),
    );
  }
}

void showAddClientDialog(BuildContext context) async {
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final phoneController = TextEditingController();
  final weightController = TextEditingController();
  final heightcontroller = TextEditingController();

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

                TextField(
                  controller: heightcontroller,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Height (cm)',
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
                if (double.parse(ageController.text) < 14 ||
                    double.parse(ageController.text) > 80) {
                  CustomSnackBar.showWarning(
                    context,
                    'Please enter a valid age between 14 and 80',
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
                  height: int.parse(heightcontroller.text),
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

void _showFilterDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Sort By'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('Name'),
            onTap: () {
              Provider.of<VipClientViewModel>(
                context,
                listen: false,
              ).sortClients(VipClientSort.name);
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('Age'),
            onTap: () {
              Provider.of<VipClientViewModel>(
                context,
                listen: false,
              ).sortClients(VipClientSort.age);
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('Days Remaining'),
            onTap: () {
              Provider.of<VipClientViewModel>(
                context,
                listen: false,
              ).sortClients(VipClientSort.daysRemaining);
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('End Date'),
            onTap: () {
              Provider.of<VipClientViewModel>(
                context,
                listen: false,
              ).sortClients(VipClientSort.endDate);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    ),
  );
}
