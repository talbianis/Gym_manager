import 'package:flutter/material.dart';
import 'package:gym_manager/view_models/vip_viewmodel.dart';
import 'package:provider/provider.dart';

class BuildStateCard extends StatefulWidget {
  const BuildStateCard({super.key});

  @override
  State<BuildStateCard> createState() => _BuildStateCardState();
}

class _BuildStateCardState extends State<BuildStateCard> {
  @override
  Widget build(BuildContext context) {
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
}
