import 'dart:async';
import 'package:flutter/material.dart';
import 'package:se/main_navigation.dart';
import 'package:se/theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(
      const Duration(seconds: 2),
      () => Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.shield_outlined,
              size: 100,
              color: AppTheme.primaryGreen,
            ),
            const SizedBox(height: 20),
            Text(
              'SmartExpense',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppTheme.primaryGreen,
                  ),
            ),
            const SizedBox(height: 10),
            Text(
              'Control Your Finances, Offline.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}