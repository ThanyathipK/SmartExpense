import 'package:flutter/material.dart';
import 'package:se/theme.dart';

class TransactionListItem extends StatelessWidget {
  final String title;
  final String category;
  final double amount;
  final bool isExpense;
  final IconData icon;
  final VoidCallback? onMoreTap;

  const TransactionListItem({
    super.key,
    required this.title,
    required this.category,
    required this.amount,
    required this.isExpense,
    required this.icon,
    this.onMoreTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        leading: CircleAvatar(
          backgroundColor: (isExpense ? AppTheme.primaryRed : AppTheme.primaryGreen).withOpacity(0.1),
          child: Icon(
            icon,
            color: isExpense ? AppTheme.primaryRed : AppTheme.primaryGreen,
          ),
        ),
        title: Text(title, style: Theme.of(context).textTheme.bodyLarge),
        subtitle: Text(category, style: Theme.of(context).textTheme.bodyMedium),
        
        trailing: Wrap(
          spacing: 8, 
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              "${isExpense ? '-' : '+'}\$${amount.abs().toStringAsFixed(2)}",
              style: TextStyle(
                color: isExpense ? AppTheme.primaryRed : AppTheme.primaryGreen,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            GestureDetector(
              onTap: onMoreTap,
              child: const Icon(Icons.more_vert, size: 30, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}