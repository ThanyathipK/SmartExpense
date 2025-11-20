import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:se/models/recurring_transaction.dart';
import 'package:se/services/database_helper.dart';
import 'package:se/theme.dart';

class RecurringTransactionsScreen extends StatefulWidget {
  const RecurringTransactionsScreen({super.key});

  @override
  State<RecurringTransactionsScreen> createState() =>
      _RecurringTransactionsScreenState();
}

class _RecurringTransactionsScreenState
    extends State<RecurringTransactionsScreen> {
  late Future<List<RecurringTransaction>> _recurringTransactions;
  final dbHelper = DatabaseHelper.instance;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _recurringTransactions = dbHelper.getRecurringTransactions();
    });
  }
  
  void _showAddDialog() {
    final notesController = TextEditingController();
    final amountController = TextEditingController();
    String category = 'Rent';
    String frequency = 'monthly';
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Recurring Expense"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: notesController, decoration: const InputDecoration(labelText: 'Notes (e.g., Netflix)')),
                TextField(controller: amountController, decoration: const InputDecoration(labelText: 'Amount', prefixText: '\$'), keyboardType: TextInputType.number),
                Text("Category: $category (Hardcoded)"),
                Text("Frequency: $frequency (Hardcoded)"),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text("Cancel")),
            TextButton(
              onPressed: () async {
                final double amount = double.tryParse(amountController.text) ?? 0.0;
                if (amount == 0) return;

                final newTx = RecurringTransaction(
                  accountId: 1, 
                  type: 'expense',
                  category: category,
                  amount: amount,
                  notes: notesController.text,
                  frequency: frequency,
                  
                  nextDate: DateTime(DateTime.now().year, DateTime.now().month + 1, DateTime.now().day), 
                );
                
                await dbHelper.addRecurringTransaction(newTx);
                _loadData(); 
                Navigator.of(context).pop();
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Recurring Transactions"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<RecurringTransaction>>(
        future: _recurringTransactions,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "No recurring transactions added yet. Tap the '+' to add one.",
                  textAlign: TextAlign.center,
                  ),
              ),
            );
          }
          
          final transactions = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final tx = transactions[index];
              final isExpense = tx.type == 'expense';
              return Card(
                margin: const EdgeInsets.only(bottom: 12.0),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: (isExpense ? AppTheme.primaryRed : AppTheme.primaryGreen).withOpacity(0.1),
                    child: Icon(
                      isExpense ? Icons.arrow_downward : Icons.arrow_upward,
                      color: isExpense ? AppTheme.primaryRed : AppTheme.primaryGreen,
                    ),
                  ),
                  title: Text(tx.notes.isEmpty ? tx.category : tx.notes),
                  subtitle: Text(
                      "Next due: ${DateFormat.yMd().format(tx.nextDate)} (${tx.frequency})"),
                  trailing: Text(
                    "${isExpense ? '-' : '+'}\$${tx.amount.toStringAsFixed(2)}",
                    style: TextStyle(
                      color: isExpense ? AppTheme.primaryRed : AppTheme.primaryGreen,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}