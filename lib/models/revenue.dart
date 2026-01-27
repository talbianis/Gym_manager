class Revenue {
  final int? id;
  final DateTime date;

  final int waterSales;
  final int sessionSales;
  final int subscriptionSales;
  final int wheySales;
  final int vipSubscriptionSales;

  final int extraRevenue; // ✅ NEW
  final int total;

  Revenue({
    this.id,
    required this.date,
    required this.waterSales,
    required this.sessionSales,
    required this.subscriptionSales,
    required this.wheySales,
    this.vipSubscriptionSales = 0,
    this.extraRevenue = 0, // ✅ NEW
  }) : total =
           waterSales +
           sessionSales +
           subscriptionSales +
           wheySales +
           vipSubscriptionSales +
           extraRevenue;

  /// Convert DateTime to SQL Date Format: YYYY-MM-DD
  String _toSqlDate(DateTime d) {
    return "${d.year.toString().padLeft(4, '0')}-"
        "${d.month.toString().padLeft(2, '0')}-"
        "${d.day.toString().padLeft(2, '0')}";
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'date': _toSqlDate(date),
    'water_sales': waterSales,
    'session_sales': sessionSales,
    'subscription_sales': subscriptionSales,
    'whey_sales': wheySales,
    'vip_subscription_sales': vipSubscriptionSales,
    'extra_revenue': extraRevenue, // ✅ NEW
    'total': total,
  };

  factory Revenue.fromMap(Map<String, dynamic> m) => Revenue(
    id: m['id'],
    date: DateTime.parse(m['date']),
    waterSales: m['water_sales'] ?? 0,
    sessionSales: m['session_sales'] ?? 0,
    subscriptionSales: m['subscription_sales'] ?? 0,
    wheySales: m['whey_sales'] ?? 0,
    vipSubscriptionSales: m['vip_subscription_sales'] ?? 0,
    extraRevenue: m['extra_revenue'] ?? 0, // ✅ NEW
  );
}
