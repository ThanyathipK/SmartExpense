import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:se/models/budget.dart';
import 'package:se/services/database_helper.dart';
import 'package:se/theme.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<List<Budget>> _budgets;
  final dbHelper = DatabaseHelper.instance;
  final formatter = NumberFormat("#,##0.00", "en_US");
  final _budgetController = TextEditingController();

  final List<String> _categories = ['Food', 'Transport', 'Rent', 'Bills', 'Shopping', 'Entertainment', 'Savings', 'Other'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this, initialIndex: 2);
    _loadBudgets();
    
   
    DatabaseHelper.instance.dbChangeNotifier.addListener(_loadBudgets);
  }

  @override
  void dispose() {
    DatabaseHelper.instance.dbChangeNotifier.removeListener(_loadBudgets);
    _tabController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  void _loadBudgets() {
    setState(() {
      _budgets = dbHelper.getBudgetsWithSpending();
    });
  }

 
  Future<void> _showBudgetDialog(String category, [double? currentAmount]) async {
    _budgetController.text = currentAmount?.toStringAsFixed(0) ?? '';
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Set Budget for $category'),
          content: TextField(
            controller: _budgetController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(hintText: 'Enter amount', prefixText: '\$'),
          ),
          actions: <Widget>[
            TextButton(child: const Text('Cancel'), onPressed: () => Navigator.of(context).pop()),
            TextButton(
              child: const Text('Save'),
              onPressed: () async {
                final double amount = double.tryParse(_budgetController.text) ?? 0.0;
                if (amount > 0) {
                  final newBudget = Budget(category: category, amount: amount);
                  await dbHelper.upsertBudget(newBudget);
                  
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TabBar(
        controller: _tabController,
        tabs: const [Tab(text: "DAILY"), Tab(text: "WEEKLY"), Tab(text: "MONTHLY"), Tab(text: "YEARLY")],
        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBudgetView(context, "Daily"),
          _buildBudgetView(context, "Weekly"),
          _buildBudgetView(context, "Monthly"),
          _buildBudgetView(context, "Yearly"),
        ],
      ),
    );
  }

  Widget _buildBudgetView(BuildContext context, String period) {
    if (period != "Monthly") return Center(child: Text("$period view not yet implemented"));

    return FutureBuilder<List<Budget>>(
      future: _budgets,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        
        final budgets = snapshot.data ?? [];
        final Map<String, double> allCategories = { for (var c in _categories) c: 0.0 };
        final Map<String, double> spentMap = {};
        
        for (var budget in budgets) {
          allCategories[budget.category] = budget.amount;
          spentMap[budget.category] = budget.spent;
        }

        return ListView(
          padding: const EdgeInsets.all(16.0),
          children: allCategories.entries.map<Widget>((entry) {
            final category = entry.key;
            final amount = entry.value;
            final spent = spentMap[category] ?? 0.0;

            if (amount == 0.0) return _buildAddBudgetCard(category);
            return _buildBudgetCard(context, icon: _getIconForCategory(category), category: category, spent: spent, budget: amount);
          }).toList(),
        );
      },
    );
  }
  
  Widget _buildAddBudgetCard(String category) {
     return Card(
        margin: const EdgeInsets.only(bottom: 12.0),
        child: ListTile(
          leading: Icon(_getIconForCategory(category), color: AppTheme.lightText),
          title: Text(category),
          subtitle: const Text('No budget set'),
          trailing: const Icon(Icons.add, color: AppTheme.primaryGreen),
          onTap: () => _showBudgetDialog(category),
        ),
      );
  }

  Widget _buildBudgetCard(BuildContext context, {required IconData icon, required String category, required double spent, required double budget}) {
    double progress = 0.0;
    if (budget > 0) progress = (spent / budget).clamp(0.0, 1.0);
    Color progressColor = AppTheme.primaryGreen;
    if (progress > 0.75) progressColor = Colors.orange;
    if (progress >= 1.0) progressColor = AppTheme.primaryRed;

    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: () => _showBudgetDialog(category, budget),
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [Icon(icon, color: AppTheme.lightText), const SizedBox(width: 12), Text(category, style: Theme.of(context).textTheme.titleLarge)]),
                  Text("\$${formatter.format(spent)} / \$${formatter.format(budget)}", style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: progressColor, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(value: progress, minHeight: 10, backgroundColor: Colors.grey.shade200, valueColor: AlwaysStoppedAnimation<Color>(progressColor)),
              ),
            ],
          ),
        ),
      ),
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
      default: return Icons.category_outlined;
    }
  }
}