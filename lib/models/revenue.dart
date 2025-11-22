class Revenue {
  final int? id;
  final DateTime date;
  final int waterSales;
  final int sessionSales;
  final int subscriptionSales;

  Revenue({
    this.id,
    required this.date,
    required this.waterSales,
    required this.sessionSales,
    required this.subscriptionSales,
  });

  int get total => waterSales + sessionSales + subscriptionSales;

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "date": date.toIso8601String(),
      "water_sales": waterSales,
      "session_sales": sessionSales,
      "subscription_sales": subscriptionSales,
      "total": total,
    };
  }

  factory Revenue.fromMap(Map<String, dynamic> map) {
    return Revenue(
      id: map["id"],
      date: DateTime.parse(map["date"]),
      waterSales: map["water_sales"],
      sessionSales: map["session_sales"],
      subscriptionSales: map["subscription_sales"],
    );
  }
}
