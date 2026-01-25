import 'package:flutter/material.dart';

class RevenueItem {
  final String key; // e.g. "water", "whey", "session", "subscription"
  final String label; // human label
  int count;
  IconData? icon;
  final int price; // price in DA (integer)

  RevenueItem({
    required this.key,
    required this.label,
    this.count = 0,
    required this.price,
    this.icon,
  });

  int get total => count * price;

  Map<String, dynamic> toMap() => {
    'key': key,
    'label': label,
    'count': count,
    'price': price,
  };
}
