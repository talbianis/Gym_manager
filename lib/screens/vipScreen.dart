import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gym_manager/const/colors.dart';
import 'package:gym_manager/models/vipclient.dart';
import 'package:gym_manager/view_models/vip_viewmodel.dart';
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
          _buildStatsCards(),
          _buildSearchBar(),
          _buildFilterChips(),
          Expanded(child: _buildClientsList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddClientDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatsCards() {
    return Consumer<VipClientViewModel>(
      builder: (context, viewModel, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total',
                  viewModel.totalVipClients.toString(),
                  Colors.blue,
                  Icons.people,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  'Active',
                  viewModel.activeVipClients.toString(),
                  Colors.green,
                  Icons.check_circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  'Expired',
                  viewModel.expiredVipClients.toString(),
                  Colors.red,
                  Icons.cancel,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  'Expiring',
                  viewModel.expiringInFiveDays.toString(),
                  Colors.orange,
                  Icons.warning,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search by name or phone...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    Provider.of<VipClientViewModel>(
                      context,
                      listen: false,
                    ).searchClients('');
                  },
                )
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
        ),
        onChanged: (value) {
          Provider.of<VipClientViewModel>(
            context,
            listen: false,
          ).searchClients(value);
        },
      ),
    );
  }

  Widget _buildFilterChips() {
    return Consumer<VipClientViewModel>(
      builder: (context, viewModel, child) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              _buildFilterChip('All', VipClientFilter.all, viewModel),
              const SizedBox(width: 8),
              _buildFilterChip('Active', VipClientFilter.active, viewModel),
              const SizedBox(width: 8),
              _buildFilterChip('Expired', VipClientFilter.expired, viewModel),
              const SizedBox(width: 8),
              _buildFilterChip(
                'Expiring Soon',
                VipClientFilter.expiringSoon,
                viewModel,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(
    String label,
    VipClientFilter filter,
    VipClientViewModel viewModel,
  ) {
    final isSelected = viewModel.currentFilter == filter;
    return FilterChip(
      selectedColor: Colors.blueGrey,
      backgroundColor: AppColor.mainColor,
      label: Text(label, style: TextStyle(color: AppColor.whitecolor)),
      selected: isSelected,

      onSelected: (selected) {
        viewModel.filterClients(filter);
      },
    );
  }

  Widget _buildClientsList() {
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

  void _showAddClientDialog(BuildContext context) {
    final nameController = TextEditingController();
    final ageController = TextEditingController();
    final phoneController = TextEditingController();
    final weightController = TextEditingController();

    DateTime startDate = DateTime.now();
    DateTime endDate = DateTime.now().add(const Duration(days: 30));

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        // ← AJOUT IMPORTANT
        builder: (context, setDialogState) {
          // ← setDialogState pour le dialog
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
                          // ← Utilisez setDialogState ici
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
                          // ← Utilisez setDialogState ici
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
                      phoneController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please fill all fields')),
                    );
                    return;
                  }

                  final weights = <WeightEntry>[];
                  if (weightController.text.isNotEmpty) {
                    weights.add(
                      WeightEntry(
                        date: DateTime.now(),
                        weight: double.parse(weightController.text),
                      ),
                    );
                  }

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
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('VIP Client added successfully'),
                      ),
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
                  if (weightController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter weight')),
                    );
                    return;
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      snackBarAnimationStyle: AnimationStyle(
                        curve: Curves.easeIn,
                        reverseCurve: Curves.easeOut,
                      ),
                      const SnackBar(content: Text('Weight entry added')),
                    );
                  }
                },
                child: const Text('Add', style: TextStyle(color: Colors.white)),
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
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter valid days')),
                );
                return;
              }

              final success = await viewModel.extendMembership(
                client.id!,
                days,
              );

              Navigator.pop(context);

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Membership extended by $days days')),
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
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Client updated successfully')),
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
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Client deleted')));
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
