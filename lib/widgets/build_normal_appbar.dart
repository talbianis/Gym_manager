import 'package:flutter/material.dart';

class NormalAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onSearchPressed;
  final String text;

  const NormalAppBar({
    super.key,
    required this.onSearchPressed,
    required this.text,
  });

  @override
  Size get preferredSize => Size.fromHeight(110);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 8,
      backgroundColor: Colors.white,
      title: Text(
        "Clientssssssss",
        style: TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
      ),
      centerTitle: false,
      actions: [
        Container(
          margin: EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(Icons.search, color: Colors.black87),
            onPressed: onSearchPressed,
          ),
        ),
      ],
    );
  }
}
