import 'dart:io'; 
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:se/models/transaction.dart' as tx_model;
import 'package:se/screens/splash_screen.dart';
import 'package:se/services/database_helper.dart';
import 'package:se/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.instance.database;
  await _processRecurringTransactions();
  runApp(const SmartExpenseApp());
}


Future<void> _processRecurringTransactions() async {
  final dbHelper = DatabaseHelper.instance;
  final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
  
  
  final dueTransactions = await dbHelper.getDueRecurringTransactions(today);

  for (var tx in dueTransactions) {
    final newTransaction = tx_model.Transaction(
      accountId: tx.accountId,
      type: tx.type,
      category: tx.category,
      amount: tx.amount,
      date: tx.nextDate, 
      notes: tx.notes,
    );
    await dbHelper.insertTransaction(newTransaction);

    DateTime nextDate;
    if (tx.frequency == 'monthly') {
      nextDate = DateTime(tx.nextDate.year, tx.nextDate.month + 1, tx.nextDate.day);
    } else if (tx.frequency == 'weekly') {
      nextDate = tx.nextDate.add(const Duration(days: 7));
    } else {
    
      nextDate = DateTime(tx.nextDate.year, tx.nextDate.month + 1, tx.nextDate.day);
    }
    
    await dbHelper.updateRecurringTransactionNextDate(tx.id!, nextDate);
  }
}

class SmartExpenseApp extends StatelessWidget {
  const SmartExpenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartExpense',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}