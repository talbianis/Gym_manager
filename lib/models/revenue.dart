class Revenue {
  final int? id;
  final DateTime date;
  final int waterSales;
  final int sessionSales;
  final int subscriptionSales;
  final int wheySales;
  final int total;
  final int vipSubscriptionSales;

  Revenue({
    this.id,
    required this.date,
    required this.waterSales,
    required this.sessionSales,
    required this.subscriptionSales,
    required this.wheySales,
    this.vipSubscriptionSales = 0,
  }) : total =
           waterSales +
           sessionSales +
           subscriptionSales +
           wheySales +
           vipSubscriptionSales;

  /// Convert DateTime to SQL Date Format: YYYY-MM-DD
  String _toSqlDate(DateTime d) {
    return "${d.year.toString().padLeft(4, '0')}-"
        "${d.month.toString().padLeft(2, '0')}-"
        "${d.day.toString().padLeft(2, '0')}";
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'date': _toSqlDate(date), // FIXED — now stored as YYYY-MM-DD
    'water_sales': waterSales,
    'session_sales': sessionSales,
    'subscription_sales': subscriptionSales,
    'whey_sales': wheySales,
    'total': total,
    'vip_subscription_sales': vipSubscriptionSales,
  };

  factory Revenue.fromMap(Map<String, dynamic> m) => Revenue(
    id: m['id'],
    date: DateTime.parse(m['date']), // parses "YYYY-MM-DD" correctly
    waterSales: m['water_sales'],
    sessionSales: m['session_sales'],
    subscriptionSales: m['subscription_sales'],
    wheySales: m['whey_sales'] ?? 0,
    vipSubscriptionSales: m['vip_subscription_sales'] ?? 0,
  );
}
