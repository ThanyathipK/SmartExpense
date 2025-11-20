class Transaction {
  final int? id;
  final int accountId;
  final String type; // expense or income
  final String category;
  final double amount;
  final DateTime date;
  final String notes;

  Transaction({
    this.id,
    required this.accountId,
    required this.type,
    required this.category,
    required this.amount,
    required this.date,
    required this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'accountId': accountId,
      'type': type,
      'category': category,
      'amount': amount,
      'date': date.toIso8601String(),
      'notes': notes,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      accountId: map['accountId'],
      type: map['type'],
      category: map['category'],
      amount: (map['amount'] as num).toDouble(),
      date: DateTime.parse(map['date']),
      notes: map['notes'],
    );
  }
}