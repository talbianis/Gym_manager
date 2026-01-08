class DailyExpense {
  final int? id;
  final DateTime date;
  final String title; // Water, Cleaning, Electricity...
  final int amount; // المبلغ
  final String? note;

  DailyExpense({
    this.id,
    required this.date,
    required this.title,
    required this.amount,
    this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': _formatDate(date),
      'title': title,
      'amount': amount,
      'note': note,
    };
  }

  factory DailyExpense.fromMap(Map<String, dynamic> map) {
    return DailyExpense(
      id: map['id'],
      date: DateTime.parse(map['date']),
      title: map['title'],
      amount: map['amount'],
      note: map['note'],
    );
  }

  static String _formatDate(DateTime d) {
    return "${d.year.toString().padLeft(4, '0')}-"
        "${d.month.toString().padLeft(2, '0')}-"
        "${d.day.toString().padLeft(2, '0')}";
  }
}
