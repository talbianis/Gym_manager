import 'package:flutter/material.dart';

class _buildNormalAppBar extends StatefulWidget {
  const _buildNormalAppBar({Key? key}) : super(key: key);

  @override
  State<_buildNormalAppBar> createState() => _buildNormalAppBarState();
}

bool isSearching = false;

class _buildNormalAppBarState extends State<_buildNormalAppBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text("Clients"),
      actions: [
        IconButton(
          onPressed: () {
            setState(() {
              isSearching = true;
            });
          },
          icon: Icon(Icons.search),
        ),
      ],
    );
  }
}
