import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:se/models/account.dart';
import 'package:se/models/transaction.dart' as tx_model;
import 'package:se/screens/add_transaction_screen.dart';
import 'package:se/services/database_helper.dart';
import 'package:se/theme.dart';
import 'package:se/widgets/transaction_list_item.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<Map<String, dynamic>> _dashboardData;
  final dbHelper = DatabaseHelper.instance;
  final formatter = NumberFormat("#,##0.00", "en_US");

  @override
  void initState() {
    super.initState();
    _dashboardData = _loadData();
    
    DatabaseHelper.instance.dbChangeNotifier.addListener(_refreshData);
  }

  @override
  void dispose() {
    DatabaseHelper.instance.dbChangeNotifier.removeListener(_refreshData);
    super.dispose();
  }

  void _refreshData() {
    setState(() {
      _dashboardData = _loadData();
    });
  }

  Future<Map<String, dynamic>> _loadData() async {
    final totalBalance = await dbHelper.getOverallBalance();
    final monthlyTransactions = await dbHelper.getMonthlyTransactions(); 
    
    return {
      'totalBalance': totalBalance,
      'transactions': monthlyTransactions,
    };
  }
  
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _dashboardData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return const Center(child: Text("No data found."));
        }

        final double totalBalance = snapshot.data!['totalBalance'];
        final List<tx_model.Transaction> transactions = 
            List<tx_model.Transaction>.from(snapshot.data!['transactions'] ?? []);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTotalBalanceCard(context, totalBalance),
              const SizedBox(height: 24),
              Text(
                "This Month's Transactions",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              _buildTransactionList(transactions),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTransactionList(List<tx_model.Transaction> transactions) {
    if (transactions.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Center(
            child: Text(
              "No transactions for this month yet.",
              style: TextStyle(color: AppTheme.lightText, fontSize: 16),
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final tx = transactions[index];
        
        return TransactionListItem(
          title: tx.notes.isEmpty ? tx.category : tx.notes,
          category: DateFormat.yMd().format(tx.date),
          amount: tx.amount,
          isExpense: tx.type == 'expense',
          icon: _getIconForCategory(tx.category),
          onMoreTap: () => _showTransactionOptions(context, tx),
        );
      },
    );
  }

  void _showTransactionOptions(BuildContext context, tx_model.Transaction tx) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.blue),
                title: const Text('Edit'),
                onTap: () async {
                  Navigator.pop(context); 
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => AddTransactionScreen(transactionToEdit: tx),
                      fullscreenDialog: true,
                    ),
                  );
                  
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete'),
                onTap: () async {
                  Navigator.pop(context); 
                  bool confirm = await showDialog(
                    context: context, 
                    builder: (ctx) => AlertDialog(
                      title: const Text("Delete Transaction?"),
                      content: const Text("This cannot be undone."),
                      actions: [
                        TextButton(child: const Text("Cancel"), onPressed: () => Navigator.pop(ctx, false)),
                        TextButton(child: const Text("Delete", style: TextStyle(color: Colors.red)), onPressed: () => Navigator.pop(ctx, true)),
                      ],
                    )
                  ) ?? false;

                  if (confirm) {
                    await dbHelper.deleteTransaction(tx.id!);
                    
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  IconData _getIconForCategory(String category) {
    switch (category) {
      case 'Food': return Icons.fastfood_outlined;
      case 'Transport': return Icons.directions_bus_outlined;
      case 'Rent': return Icons.home_outlined;
      case 'Bills': return Icons.receipt_long_outlined;
      case 'Shopping': return Icons.shopping_bag_outlined;
      case 'Entertainment': return Icons.movie_outlined;
      case 'Savings': return Icons.savings_outlined;
      case 'Salary': return Icons.work_outline;
      case 'Gifts': return Icons.card_giftcard_outlined;
      default: return Icons.category_outlined;
    }
  }

  Widget _buildTotalBalanceCard(BuildContext context, double balance) {
    final isNegative = balance < 0;
    return Card(
      color: isNegative ? AppTheme.primaryRed : AppTheme.primaryGreen,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Total Balance",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white.withOpacity(0.8),
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              "\$${formatter.format(balance)}",
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}