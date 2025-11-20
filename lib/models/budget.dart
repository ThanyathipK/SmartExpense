class Budget {
  final int? id;
  final String category;
  final double amount;
  final double spent;

  Budget({
    this.id,
    required this.category,
    required this.amount,
    this.spent = 0.0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'amount': amount,
    };
  }

  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      id: map['id'],
      category: map['category'],
      amount: (map['amount'] as num).toDouble(),
      spent: (map['spent'] as num?)?.toDouble() ?? 0.0,
    );
  }
}