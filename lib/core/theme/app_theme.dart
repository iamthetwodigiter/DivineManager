import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Colors.teal;
  static const Color secondaryColor = Colors.orangeAccent;
  static const Color lightBackgroundColor = Colors.white;
  static const Color darkBackgroundColor = Colors.black;

  static const Color primaryGreen = Colors.green;
  static const Color primaryBrown = Colors.brown;
  static const Color primaryOrange = Colors.orange;
  static const Color primaryBlue = Colors.blue;
  static const Color primaryPurple = Colors.purple;
  static const Color primaryGrey = Colors.grey;
  static const Color primaryRed = Colors.red;
  static const Color primaryTeal = Colors.teal;

  static const Color successColor = Color(0xFF4CAF50);
  static const Color errorColor = Color(0xFFE53E3E);
  static const Color warningColor = Color(0xFFFF9800);
  static const Color infoColor = Color(0xFF2196F3);
  static const Color surfaceColor = Color(0xFFF5F5F5);
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color textPrimaryColor = Color(0xFF1D1D1D);
  static const Color textSecondaryColor = Color(0xFF757575);
  static const Color vegColor = Color(0xFF4CAF50);
  static const Color nonVegColor = Color.fromARGB(255, 105, 0, 0);

  static final AppBarThemeData _appBarTheme = AppBarThemeData(
    backgroundColor: lightBackgroundColor,
    elevation: 0,
    shadowColor: primaryColor.withValues(alpha: 0.1),
    surfaceTintColor: primaryColor.withValues(alpha: 0.1),
    centerTitle: true,
  );

  static ThemeData get lightTheme => ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: lightBackgroundColor,
    fontFamily: 'Lato',
    appBarTheme: _appBarTheme,
  );

  static ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: darkBackgroundColor,
    fontFamily: 'Lato',
    appBarTheme: _appBarTheme.copyWith(backgroundColor: darkBackgroundColor),
  );
}
