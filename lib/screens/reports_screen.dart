import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:se/services/database_helper.dart';
import 'package:se/theme.dart';

class CategorySpending {
  final String category;
  final double total;
  CategorySpending(this.category, this.total);
}

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<List<CategorySpending>> _spendingData;
  final dbHelper = DatabaseHelper.instance;
  final formatter = NumberFormat("#,##0.00", "en_US");
  String _selectedPeriod = 'monthly';

  final List<Color> _chartColors = [
    AppTheme.primaryRed,
    Colors.blue.shade400,
    Colors.amber.shade600,
    Colors.purple.shade400,
    Colors.green.shade400,
    Colors.orange.shade400,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this, initialIndex: 2); 
    _tabController.addListener(_onTabChanged);
    _loadData();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      int index = _tabController.index;
      String period = 'monthly';
      if (index == 0) period = 'daily';
      if (index == 1) period = 'weekly';
      if (index == 2) period = 'monthly';
      if (index == 3) period = 'yearly';
      
      if (period != _selectedPeriod) {
        setState(() {
          _selectedPeriod = period;
        });
        _loadData();
      }
    }
  }

  void _loadData() {
    setState(() {
      _spendingData = _fetchSpendingData(_selectedPeriod);
    });
  }

  Future<List<CategorySpending>> _fetchSpendingData(String period) async {
    final result = await dbHelper.getCategorySpending(period: period);
    return result.map((item) {
      return CategorySpending(
        item['category'] as String,
        item['total'] as double,
      );
    }).toList();
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TabBar(
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
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildReportsView(context, "Daily"),
          _buildReportsView(context, "Weekly"),
          _buildReportsView(context, "Monthly"),
          _buildReportsView(context, "Yearly"),
        ],
      ),
    );
  }

  Widget _buildReportsView(BuildContext context, String period) {
    return FutureBuilder<List<CategorySpending>>(
      future: _spendingData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No expenses recorded for this period."));
        }

        final spendingList = snapshot.data!;
        final double totalExpense = spendingList.fold(0.0, (sum, item) => sum + item.total);

        return ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            SizedBox(
              height: 250,
              child: _buildPieChart(spendingList, totalExpense),
            ),
            const SizedBox(height: 24),
            Center(
              child: Column(
                children: [
                  Text(
                    "Total Expense",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    "\$${formatter.format(totalExpense)}",
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Top Categories",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            ..._buildCategoryList(spendingList, totalExpense),
          ],
        );
      },
    );
  }

  Widget _buildPieChart(List<CategorySpending> spendingList, double totalExpense) {
    return PieChart(
      PieChartData(
        sectionsSpace: 4,
        centerSpaceRadius: 60,
        sections: List.generate(spendingList.length, (index) {
          final item = spendingList[index];
          final percentage = (item.total / totalExpense) * 100;
          return PieChartSectionData(
            color: _chartColors[index % _chartColors.length],
            value: item.total,
            title: '${percentage.toStringAsFixed(0)}%',
            radius: 50,
            titleStyle: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          );
        }),
      ),
    );
  }

  List<Widget> _buildCategoryList(List<CategorySpending> spendingList, double totalExpense) {
    return spendingList.map((item) {
      final percentage = (item.total / totalExpense) * 100;
      final color = _chartColors[spendingList.indexOf(item) % _chartColors.length];
      
      return Card(
        margin: const EdgeInsets.only(bottom: 8.0),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: color.withOpacity(0.1),
            child: Icon(_getIconForCategory(item.category), color: color, size: 20),
          ),
          title: Text(item.category, style: Theme.of(context).textTheme.bodyLarge),
          subtitle: Text("${percentage.toStringAsFixed(1)}% of spending"),
          trailing: Text(
            "-\$${formatter.format(item.total)}",
            style: const TextStyle(
              color: AppTheme.primaryRed,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      );
    }).toList();
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