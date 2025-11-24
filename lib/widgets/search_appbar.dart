import 'package:flutter/material.dart';
import 'package:gym_manager/const/colors.dart';

class SearchAppBar extends StatelessWidget implements PreferredSizeWidget {
  final TextEditingController searchController;
  final VoidCallback onClearSearch;
  final ValueChanged<String> onSearchChanged;

  const SearchAppBar({
    Key? key,
    required this.searchController,
    required this.onClearSearch,
    required this.onSearchChanged,
  }) : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: onClearSearch,
      ),
      title: TextField(
        controller: searchController,
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'Search by name or phone...',
          border: InputBorder.none,
          hintStyle: TextStyle(color: AppColor.blackcolor),
        ),
        style: TextStyle(color: AppColor.blackcolor),
        onChanged: onSearchChanged,
      ),
      actions: [
        if (searchController.text.isNotEmpty)
          IconButton(icon: Icon(Icons.clear), onPressed: onClearSearch),
      ],
    );
  }
}
