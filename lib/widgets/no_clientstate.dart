import 'package:flutter/material.dart';

class NoClientsState extends StatelessWidget {
  final VoidCallback onAddClient;

  const NoClientsState({Key? key, required this.onAddClient}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No clients yet',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          SizedBox(height: 8),
          Text(
            'Tap the + button to add your first client',
            style: TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: onAddClient,
            child: Text('Add First Client'),
          ),
        ],
      ),
    );
  }
}
