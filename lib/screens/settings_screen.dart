import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:se/screens/recurring_transactions_screen.dart';
import 'package:se/services/database_helper.dart';
import 'package:se/theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _exportDataToCSV(BuildContext context) async {
    //Check permissions (Stuck here TT) 
    var status = await Permission.storage.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Storage permission is required to export data.")),
      );
      return;
    }

    //Get data from database
    final dbHelper = DatabaseHelper.instance;
    final accounts = await dbHelper.getAccountsWithBalance();
    final transactions = await dbHelper.getAllTransactions();
    
    if (transactions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No transactions to export.")),
      );
      return;
    }

    //Format data to CSV
    final accountMap = {for (var acc in accounts) acc.id: acc.name};
    List<List<dynamic>> rows = [];
    rows.add(["ID", "Date", "Account Name", "Type", "Category", "Amount", "Notes"]);
    for (var tx in transactions) {
      rows.add([
        tx.id,
        tx.date.toIso8601String(),
        accountMap[tx.accountId] ?? tx.accountId.toString(),
        tx.type,
        tx.category,
        tx.amount,
        tx.notes,
      ]);
    }
    String csv = const ListToCsvConverter().convert(rows);
    try {
      Directory? directory;
      if (Platform.isAndroid) {
         directory = await getExternalStorageDirectory();
      } else {
         directory = await getApplicationDocumentsDirectory();
      }

      if (directory == null) {
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text("Could not find storage directory.")),
         );
         return;
      }
      
      final path = "${directory.path}/SmartExpense_Export_${DateTime.now().toIso8601String()}.csv";
      final file = File(path);
      await file.writeAsString(csv);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Data exported successfully! Path: ${file.path}"),
          duration: const Duration(seconds: 5), 
          action: SnackBarAction(label: "OK", onPressed: () {}),
        ),
      );
    } catch (e) {
       ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error exporting data: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildSettingsCard(
          context,
          title: "Recurring Transactions",
          icon: Icons.autorenew,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const RecurringTransactionsScreen(),
              ),
            );
          },
        ),
        _buildSettingsCard(
          context,
          title: "Export Data (CSV)",
          icon: Icons.file_download_outlined,
          onTap: () {
            _exportDataToCSV(context);
          },
        ),
        _buildSettingsCard(
          context,
          title: "Currency",
          icon: Icons.attach_money,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Currency selection not implemented.")),
            );
          },
        ),
        _buildSettingsCard(
          context,
          title: "About",
          icon: Icons.info_outline,
          onTap: () {
            showAboutDialog(
              context: context,
              applicationName: "SmartExpense",
              applicationVersion: "1.0.0",
              applicationIcon: const Icon(Icons.shield_outlined, color: AppTheme.primaryGreen, size: 48),
              children: [
                const Text("A simple, offline-first expense tracker built with Flutter and SQLite.")
              ]
            );
          },
        ),
      ],
    );
  }

  Widget _buildSettingsCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.lightText),
        title: Text(title, style: Theme.of(context).textTheme.bodyLarge),
        trailing: const Icon(Icons.chevron_right, color: AppTheme.lightText),
        onTap: onTap,
      ),
    );
  }

}