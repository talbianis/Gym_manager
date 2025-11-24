import 'package:flutter/material.dart';

class FloatingSearchButton extends StatelessWidget {
  final VoidCallback onPressed;

  const FloatingSearchButton({Key? key, required this.onPressed})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: Colors.white,
      foregroundColor: Colors.blue[700],
      elevation: 4,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [Colors.blue[500]!, Colors.blue[700]!],
          ),
        ),
        child: Icon(Icons.search, color: Colors.white),
      ),
    );
  }
}
