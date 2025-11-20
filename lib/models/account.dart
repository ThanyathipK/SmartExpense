class Account {
  final int? id;
  final String name;
  final double balance; // For calculate balance

  Account({this.id, required this.name, required this.balance});

  factory Account.fromMap(Map<String, dynamic> map) {
    return Account(
      id: map['id'],
      name: map['name'],
      balance: (map['current_balance'] as num?)?.toDouble() ?? 0.0,
    );
  }
}