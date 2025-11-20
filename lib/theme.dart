import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryGreen = Color(0xFF1DD1A1);
  static const Color primaryRed = Color(0xFFE57373);
  static const Color darkText = Color(0xFF333333);
  static const Color lightText = Color(0xFF757575);
  static const Color background = Color(0xFFF5F5F5);
  static const Color cardBackground = Color(0xFFFFFFFF);

  static final ThemeData lightTheme = ThemeData(
    primaryColor: primaryGreen,
    scaffoldBackgroundColor: background,
    fontFamily: 'Roboto',
    
    appBarTheme: const AppBarTheme(
      backgroundColor: background,
      elevation: 0,
      iconTheme: IconThemeData(color: darkText),
      titleTextStyle: TextStyle(
        color: darkText,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),

    textTheme: const TextTheme(
      headlineMedium: TextStyle(color: darkText, fontWeight: FontWeight.bold, fontSize: 24),
      titleLarge: TextStyle(color: darkText, fontWeight: FontWeight.bold, fontSize: 18),
      bodyLarge: TextStyle(color: darkText, fontSize: 16),
      bodyMedium: TextStyle(color: lightText, fontSize: 14),
    ),


    cardTheme: const CardThemeData(
      color: cardBackground,
      elevation: 1,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12.0)),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16.0),
      ),
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: primaryGreen,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryGreen,
      foregroundColor: Colors.white,
    ),
    
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryGreen,
      primary: primaryGreen,
      secondary: primaryGreen,
      error: primaryRed,
      background: background,
    ),
  );
}