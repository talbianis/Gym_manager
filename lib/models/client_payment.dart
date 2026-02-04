class ClientPayment {
  final int? id;
  final int clientId;
  final DateTime date;
  final int? amount;
  final String? subscriptionType;
  final String? note;

  ClientPayment({
    this.id,
    required this.clientId,
    required this.date,
    this.amount,
    this.subscriptionType,
    this.note,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'client_id': clientId,
    'date': _formatDate(date),
    'amount': amount,
    'subscription_type': subscriptionType,
    'note': note,
  };

  factory ClientPayment.fromMap(Map<String, dynamic> m) => ClientPayment(
    id: m['id'],
    clientId: m['client_id'],
    date: DateTime.parse(m['date']),
    amount: m['amount'],
    subscriptionType: m['subscription_type'],
    note: m['note'],
  );

  String _formatDate(DateTime d) =>
      "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
}
