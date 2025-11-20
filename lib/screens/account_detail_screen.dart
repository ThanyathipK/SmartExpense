import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:se/models/account.dart';
import 'package:se/models/transaction.dart' as tx_model; 
import 'package:se/services/database_helper.dart';
import 'package:se/theme.dart';
import 'package:se/widgets/transaction_list_item.dart';

class AccountDetailScreen extends StatefulWidget {
  final Account account;
  const AccountDetailScreen({super.key, required this.account});

  @override
  State<AccountDetailScreen> createState() => _AccountDetailScreenState();
}

class _AccountDetailScreenState extends State<AccountDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<Map<String, dynamic>> _accountData;
  late Future<List<tx_model.Transaction>> _transactions;
  final dbHelper = DatabaseHelper.instance;
  final formatter = NumberFormat("#,##0.00", "en_US");

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this, initialIndex: 2);
    _loadData();
  }
  
  void _loadData() {
    if (widget.account.id == null) {
      setState(() {
        _accountData = Future.value({'totalIncome': 0.0, 'totalExpense': 0.0});
        _transactions = Future.value([]);
      });
      return;
    }

    setState(() {
      _accountData = dbHelper.getAccountSummary(widget.account.id!);
      _transactions = _loadTransactions();
    });
  }

  Future<List<tx_model.Transaction>> _loadTransactions() async {
    if (widget.account.id == null) {
      return [];
    }
    return dbHelper.getTransactionsForAccount(widget.account.id!);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.account.name),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "DAILY"),
            Tab(text: "WEEKLY"),
            Tab(text: "MONTHLY"),
            Tab(text: "YEARLY"),
          ],
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTransactionView(context, "Daily"),
          _buildTransactionView(context, "Weekly"),
          _buildTransactionView(context, "Monthly"),
          _buildTransactionView(context, "Yearly"),
        ],
      ),
    );
  }

  Widget _buildTransactionView(BuildContext context, String period) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        FutureBuilder<Map<String, dynamic>>(
          future: _accountData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Card(child: Padding(padding: EdgeInsets.all(20), child: Center(child: CircularProgressIndicator())));
            }
            
            final summary = snapshot.data ?? {'totalIncome': 0.0, 'totalExpense': 0.0};
            final totalIncome = summary['totalIncome'];
            final totalExpense = summary['totalExpense'];
            final balance = widget.account.balance; 

            return _buildBalanceSummaryCard(
                context, totalIncome, totalExpense, balance);
          },
        ),
        
        const SizedBox(height: 24),
        Text(
          "Recent Transactions",
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
      
        FutureBuilder<List<tx_model.Transaction>>(
          future: _transactions,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                  child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Text("No transactions yet."),
              ));
            }

            final transactions = snapshot.data!;
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final tx = transactions[index];
                return TransactionListItem(
                  title: tx.notes.isEmpty ? tx.category : tx.notes,
                  category: tx.category, 
                  amount: tx.amount,
                  isExpense: tx.type == 'expense',
                  icon: _getIconForCategory(tx.category),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildBalanceSummaryCard(
      BuildContext context, double totalIncome, double totalExpense, double balance) {
    
    double progress = 0.0;
    if (totalIncome > 0) {
      progress = (totalExpense / totalIncome).clamp(0.0, 1.0);
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            SizedBox(
              width: 100,
              height: 100,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    "${(progress * 100).toStringAsFixed(0)}%",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 8,
                      backgroundColor: Colors.grey.shade200,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(progress > 0.8 ? AppTheme.primaryRed : AppTheme.primaryGreen),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildIncomeExpenseRow(
                    context,
                    "Income:",
                    "\$${formatter.format(totalIncome)}",
                    AppTheme.primaryGreen,
                  ),
                  const SizedBox(height: 8),
                  _buildIncomeExpenseRow(
                    context,
                    "Expenses:",
                    "-\$${formatter.format(totalExpense)}",
                    AppTheme.primaryRed,
                  ),
                  const Divider(height: 20),
                  _buildIncomeExpenseRow(
                    context,
                    "Balance:",
                    "\$${formatter.format(balance)}",
                    AppTheme.darkText,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncomeExpenseRow(
      BuildContext context, String label, String amount, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        Text(
          amount,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
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
}