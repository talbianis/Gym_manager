import 'package:flutter/material.dart';

class EmptySearchState extends StatelessWidget {
  final String query;
  final VoidCallback onClearSearch;

  const EmptySearchState({
    Key? key,
    required this.query,
    required this.onClearSearch,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No clients found for "$query"',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          SizedBox(height: 8),
          TextButton(onPressed: onClearSearch, child: Text('Clear search')),
        ],
      ),
    );
  }
}
