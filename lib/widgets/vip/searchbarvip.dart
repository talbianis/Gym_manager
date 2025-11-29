import 'package:flutter/material.dart';
import 'package:gym_manager/view_models/vip_viewmodel.dart';
import 'package:provider/provider.dart' show Provider;

class Searchbarvip extends StatefulWidget {
  const Searchbarvip({super.key});

  @override
  State<Searchbarvip> createState() => _SearchbarvipState();
}

class _SearchbarvipState extends State<Searchbarvip> {
  final TextEditingController _searchController = TextEditingController();
  // bool _isSearching = false;
  // bool _initialLoad = true;

  @override
  Widget build(BuildContext context) {
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
}
