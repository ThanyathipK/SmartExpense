class RecurringTransaction {
  final int? id;
  final int accountId;
  final String type;
  final String category;
  final double amount;
  final String notes;
  final String frequency;
  final DateTime nextDate;

  RecurringTransaction({
    this.id,
    required this.accountId,
    required this.type,
    required this.category,
    required this.amount,
    required this.notes,
    required this.frequency,
    required this.nextDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'accountId': accountId,
      'type': type,
      'category': category,
      'amount': amount,
      'notes': notes,
      'frequency': frequency,
      'nextDate': nextDate.toIso8601String(),
    };
  }

  factory RecurringTransaction.fromMap(Map<String, dynamic> map) {
    return RecurringTransaction(
      id: map['id'],
      accountId: map['accountId'],
      type: map['type'],
      category: map['category'],
      amount: (map['amount'] as num).toDouble(),
      notes: map['notes'],
      frequency: map['frequency'],
      nextDate: DateTime.parse(map['nextDate']),
    );
  }
}