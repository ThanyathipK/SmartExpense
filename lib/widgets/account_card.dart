import 'package:flutter/material.dart';
import 'package:se/theme.dart';

class AccountCard extends StatelessWidget {
  final String accountName;
  final String balance;
  final String change;
  final Color changeColor;
  final VoidCallback onTap;

  const AccountCard({
    super.key,
    required this.accountName,
    required this.balance,
    required this.change,
    required this.changeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    accountName,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "\$$balance",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              if (change.isNotEmpty)
                Text(
                  change,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: changeColor,
                        fontWeight: FontWeight.bold,
                      ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}