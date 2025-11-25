import 'package:flutter/material.dart';
import 'package:gym_manager/const/colors.dart';

class NormalAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onSearchPressed;

  const NormalAppBar({Key? key, required this.onSearchPressed})
    : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 100,
      backgroundColor: AppColor.mainColor,
      title: Text(
        "Clients",
        style: TextStyle(
          color: AppColor.whitecolor,
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
