import 'package:flutter/material.dart';
import 'package:gym_manager/const/colors.dart';
import 'package:gym_manager/view_models/vip_viewmodel.dart';
import 'package:provider/provider.dart';

class Builderchips extends StatefulWidget {
  const Builderchips({super.key});

  @override
  State<Builderchips> createState() => _BuilderchipsState();
}

class _BuilderchipsState extends State<Builderchips> {
  @override
  Widget build(BuildContext context) {
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
}
