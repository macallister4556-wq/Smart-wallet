class Transaction {
  final String id;
  final String title;
  final double amount;
  final String category; // e.g., "Airtime", "Data", "Expense", "Income"
  final DateTime date;
  final bool isAutoSynced;

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.isAutoSynced = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'amount': amount,
        'category': category,
        'date': date.toIso8601String(),
        'isAutoSynced': isAutoSynced,
      };

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
        id: json['id'],
        title: json['title'],
        amount: (json['amount'] as num).toDouble(),
        category: json['category'],
        date: DateTime.parse(json['date']),
        isAutoSynced: json['isAutoSynced'] ?? false,
      );
}
