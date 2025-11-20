import 'package:flutter/material.dart';
import 'package:se/screens/add_transaction_screen.dart';
import 'package:se/screens/budget_screen.dart';
import 'package:se/screens/dashboard_screen.dart';
import 'package:se/screens/reports_screen.dart';
import 'package:se/screens/settings_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

 
  final List<Widget> _widgetOptions = <Widget>[
    const DashboardScreen(),
    const ReportsScreen(), 
    const BudgetScreen(),
    const SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _navigateToAddTransaction() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddTransactionScreen(),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("SmartExpense")),
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddTransaction,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBottomNavItem(Icons.dashboard, 'Dashboard', 0),
                _buildBottomNavItem(Icons.pie_chart, 'Reports', 1),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBottomNavItem(Icons.track_changes, 'Budget', 2),
                _buildBottomNavItem(Icons.settings, 'Settings', 3),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildBottomNavItem(IconData icon, String label, int index) {
    return MaterialButton(
      minWidth: 40,
      onPressed: () => _onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: _selectedIndex == index ? Theme.of(context).primaryColor : Colors.grey),
          Text(label, style: TextStyle(color: _selectedIndex == index ? Theme.of(context).primaryColor : Colors.grey)),
        ],
      ),
    );
  }
}