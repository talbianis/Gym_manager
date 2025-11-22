class Revenue {
  final int? id;
  final DateTime date; // store only yyyy-MM-dd as ISO string when saving
  final int waterSales;
  final int sessionSales;
  final int subscriptionSales;
  final int wheySales;
  final int total;

  Revenue({
    this.id,
    required this.date,
    required this.waterSales,
    required this.sessionSales,
    required this.subscriptionSales,
    required this.wheySales,
  }) : total = waterSales + sessionSales + subscriptionSales + wheySales;

  Map<String, dynamic> toMap() => {
    'id': id,
    'date': date.toIso8601String(),
    'water_sales': waterSales,
    'session_sales': sessionSales,
    'subscription_sales': subscriptionSales,
    'whey_sales': wheySales,
    'total': total,
  };

  factory Revenue.fromMap(Map<String, dynamic> m) => Revenue(
    id: m['id'],
    date: DateTime.parse(m['date']),
    waterSales: m['water_sales'],
    sessionSales: m['session_sales'],
    subscriptionSales: m['subscription_sales'],
    wheySales: m['whey_sales'] ?? 0,
  );
}
