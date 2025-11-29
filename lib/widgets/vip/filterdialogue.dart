import 'package:flutter/material.dart';

import 'package:gym_manager/view_models/vip_viewmodel.dart';

import 'package:provider/provider.dart';

class Filterdialogue extends StatefulWidget {
  const Filterdialogue({super.key});

  @override
  State<Filterdialogue> createState() => _FilterdialogueState();
}

class _FilterdialogueState extends State<Filterdialogue> {
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _showFilterDialog(context),
    );
    return Container();
  }

  Future<void> _showFilterDialog(BuildContext context) async {
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
}
