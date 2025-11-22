class Client {
  final int? id;
  final String name;
  final String phone;
  final DateTime startDate;
  DateTime endDate;
  final String subscriptionType;

  Client({
    this.id,
    required this.name,
    required this.phone,
    required this.startDate,
    required this.endDate,
    required this.subscriptionType,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name,
      "phone": phone,
      "start_date": startDate.toIso8601String(),
      "end_date": endDate.toIso8601String(),
      "subscription_type": subscriptionType,
    };
  }

  factory Client.fromMap(Map<String, dynamic> map) {
    return Client(
      id: map["id"],
      name: map["name"],
      phone: map["phone"],
      startDate: DateTime.parse(map["start_date"]),
      endDate: DateTime.parse(map["end_date"]),
      subscriptionType: map["subscription_type"],
    );
  }
}
