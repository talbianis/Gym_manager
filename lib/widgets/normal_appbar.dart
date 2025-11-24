import 'package:flutter/material.dart';

class NormalAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onSearchPressed;

  const NormalAppBar({Key? key, required this.onSearchPressed})
    : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text("Clients"),
      actions: [
        IconButton(onPressed: onSearchPressed, icon: Icon(Icons.search)),
      ],
    );
  }
}
