import 'package:flutter/foundation.dart'; 
import 'package:path/path.dart';
import 'package:se/models/account.dart';
import 'package:se/models/budget.dart';
import 'package:se/models/recurring_transaction.dart';
import 'package:se/models/transaction.dart';
import 'package:sqflite/sqflite.dart' hide Transaction;

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  
  
  final ValueNotifier<int> dbChangeNotifier = ValueNotifier(0);

  DatabaseHelper._init();

  
  void _notify() {
    dbChangeNotifier.value++; 
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('smart_expense.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 2, onCreate: _createDB, onUpgrade: _onUpgradeDB);
  }

  Future _onUpgradeDB(Database db, int oldVersion, int newVersion) async {
     if (oldVersion < 2) {
       await _createAdvancedTables(db);
     }
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const realType = 'REAL NOT NULL';
    const intType = 'INTEGER NOT NULL';

    await db.execute('''
    CREATE TABLE accounts (
      id $idType,
      name $textType,
      initial_balance $realType DEFAULT 0
    )
    ''');

    await db.execute('''
    CREATE TABLE transactions (
      id $idType,
      accountId $intType,
      type $textType,
      category $textType,
      amount $realType,
      date $textType,
      notes TEXT,
      FOREIGN KEY (accountId) REFERENCES accounts (id) ON DELETE CASCADE
    )
    ''');

    await _createAdvancedTables(db);

    await db.insert('accounts', {'name': 'Cash', 'initial_balance': 0});
    await db.insert('accounts', {'name': 'Bank', 'initial_balance': 0});
  }
  
  Future _createAdvancedTables(Database db) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const realType = 'REAL NOT NULL';
    const intType = 'INTEGER NOT NULL';
    
    await db.execute('''
    CREATE TABLE IF NOT EXISTS budgets (
      id $idType,
      category $textType UNIQUE,
      amount $realType
    )
    ''');
    
    await db.execute('''
    CREATE TABLE IF NOT EXISTS recurring_transactions (
      id $idType,
      accountId $intType,
      type $textType,
      category $textType,
      amount $realType,
      notes TEXT,
      frequency $textType, 
      nextDate $textType,
      FOREIGN KEY (accountId) REFERENCES accounts (id) ON DELETE CASCADE
    )
    ''');
  }

  
  Future<int> insertTransaction(Transaction tx) async {
    final db = await instance.database;
    int id = await db.insert('transactions', tx.toMap());
    _notify(); 
    return id;
  }

  Future<int> updateTransaction(Transaction tx) async {
    final db = await instance.database;
    int id = await db.update('transactions', tx.toMap(), where: 'id = ?', whereArgs: [tx.id]);
    _notify(); 
    return id;
  }

  Future<int> deleteTransaction(int id) async {
    final db = await instance.database;
    int count = await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
    _notify(); 
    return count;
  }


  Future<double> getOverallBalance() async {
    final db = await instance.database;
    final result = await db.rawQuery('''
      SELECT 
        (SELECT COALESCE(SUM(initial_balance), 0) FROM accounts) + 
        COALESCE(SUM(CASE WHEN type = 'income' THEN amount ELSE -amount END), 0) as total_balance
      FROM transactions
    ''');
    
    if (result.isNotEmpty && result.first['total_balance'] != null) {
      return result.first['total_balance'] as double;
    }
    final accountResult = await db.rawQuery('SELECT COALESCE(SUM(initial_balance), 0) as total_balance FROM accounts');
    if (accountResult.isNotEmpty) {
      return (accountResult.first['total_balance'] as num).toDouble();
    }
    return 0.0;
  }

  Future<List<Account>> getAccountsWithBalance() async {
    final db = await instance.database;
    final result = await db.rawQuery('''
      SELECT 
        a.id, 
        a.name, 
        a.initial_balance + COALESCE(SUM(CASE WHEN t.type = 'income' THEN t.amount ELSE -t.amount END), 0) as current_balance
      FROM accounts a
      LEFT JOIN transactions t ON a.id = t.accountId
      GROUP BY a.id, a.name, a.initial_balance
      ORDER BY a.name
    ''');
    return result.map((json) => Account.fromMap(json)).toList();
  }

  Future<List<Transaction>> getAllTransactions() async {
    final db = await instance.database;
    final result = await db.query('transactions', orderBy: 'date DESC');
    return result.map((json) => Transaction.fromMap(json)).toList();
  }
  
  Future<List<Transaction>> getMonthlyTransactions() async {
    final db = await instance.database;
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1).toIso8601String();
    final result = await db.rawQuery('''
      SELECT * FROM transactions
      WHERE date >= ?
      ORDER BY date DESC
    ''', [firstDayOfMonth]);
    return result.map((json) => Transaction.fromMap(json)).toList();
  }

  Future<List<Map<String, dynamic>>> getCategorySpending({String period = 'monthly'}) async {
    final db = await instance.database;
    final now = DateTime.now();
    String startDate;
    if (period == 'monthly') {
      startDate = DateTime(now.year, now.month, 1).toIso8601String();
    } else if (period == 'weekly') {
      final firstDayOfWeek = now.subtract(Duration(days: now.weekday % 7));
      startDate = DateTime(firstDayOfWeek.year, firstDayOfWeek.month, firstDayOfWeek.day).toIso8601String();
    } else if (period == 'yearly') {
      startDate = DateTime(now.year, 1, 1).toIso8601String();
    } else { 
      startDate = DateTime(now.year, now.month, now.day).toIso8601String();
    }
    final result = await db.rawQuery('''
      SELECT category, SUM(amount) as total
      FROM transactions
      WHERE type = 'expense' AND date >= ?
      GROUP BY category
      ORDER BY total DESC
    ''', [startDate]);
    return result;
  }

  
  Future<int> upsertBudget(Budget budget) async {
    final db = await instance.database;
    int id = await db.insert('budgets', budget.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    _notify(); 
    return id;
  }

  Future<List<Budget>> getBudgetsWithSpending() async {
    final db = await instance.database;
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1).toIso8601String();
    final result = await db.rawQuery('''
      SELECT b.id, b.category, b.amount, COALESCE(SUM(t.amount), 0) as spent
      FROM budgets b
      LEFT JOIN transactions t ON b.category = t.category AND t.type = 'expense' AND t.date >= ?
      GROUP BY b.id, b.category, b.amount
    ''', [firstDayOfMonth]);
    return result.map((json) => Budget.fromMap(json)).toList();
  }
  
  Future<int> addRecurringTransaction(RecurringTransaction tx) async {
    final db = await instance.database;
    int id = await db.insert('recurring_transactions', tx.toMap());
    _notify(); 
    return id;
  }

  Future<int> updateRecurringTransactionNextDate(int id, DateTime nextDate) async {
    final db = await instance.database;
    int count = await db.update('recurring_transactions', {'nextDate': nextDate.toIso8601String()}, where: 'id = ?', whereArgs: [id]);
    _notify(); 
    return count;
  }

  Future<List<RecurringTransaction>> getRecurringTransactions() async {
    final db = await instance.database;
    final result = await db.query('recurring_transactions', orderBy: 'nextDate ASC');
    return result.map((json) => RecurringTransaction.fromMap(json)).toList();
  }

  Future<List<RecurringTransaction>> getDueRecurringTransactions(String today) async {
    final db = await instance.database;
    final result = await db.query('recurring_transactions', where: 'nextDate <= ?', whereArgs: [today]);
    return result.map((json) => RecurringTransaction.fromMap(json)).toList();
  }

  Future<List<Transaction>> getTransactionsForAccount(int accountId) async {
    final db = await instance.database;
    final result = await db.query('transactions', where: 'accountId = ?', whereArgs: [accountId], orderBy: 'date DESC');
    return result.map((json) => Transaction.fromMap(json)).toList();
  }
  
  Future<Map<String, double>> getAccountSummary(int accountId) async {
    final db = await instance.database;
    final result = await db.rawQuery('''
      SELECT 
        SUM(CASE WHEN type = 'income' THEN amount ELSE 0 END) as totalIncome,
        SUM(CASE WHEN type = 'expense' THEN amount ELSE 0 END) as totalExpense
      FROM transactions
      WHERE accountId = ?
    ''', [accountId]);
    return {
      'totalIncome': (result.first['totalIncome'] as num?)?.toDouble() ?? 0.0,
      'totalExpense': (result.first['totalExpense'] as num?)?.toDouble() ?? 0.0,
    };
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}