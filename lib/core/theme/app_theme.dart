import 'package:flutter/material.dart';

class AppTheme {
  // Wildberry Purple Theme
  static const Color primaryColor = Color(0xFF8B2F8B); // Wildberry Purple
  static const Color primaryDark = Color(0xFF6B1F6B);
  static const Color primaryLight = Color(0xFFAB4FAB);
  
  // Telegram UI Colors
  static const Color backgroundColor = Color(0xFFFFFFFF);
  static const Color chatBackground = Color(0xFFE6EBEE);
  static const Color surfaceColor = Colors.white;
  static const Color dividerColor = Color(0xFFD1D1D6);
  
  // Dark Theme Colors (Telegram Dark)
  static const Color darkBackground = Color(0xFF0E1621);
  static const Color darkSurface = Color(0xFF17212B);
  static const Color darkCard = Color(0xFF1E2A35);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF000000);
  static const Color textSecondary = Color(0xFF707579);
  static const Color textLight = Color(0xFF999999);
  
  // Message Bubble Colors
  static const Color outgoingBubble = Color(0xFF8B2F8B);
  static const Color incomingBubble = Color(0xFFFFFFFF);
  
  // Status Colors
  static const Color onlineColor = Color(0xFF00C853);
  static const Color successColor = Color(0xFF00C853);
  static const Color errorColor = Color(0xFFE53935);
  static const Color warningColor = Color(0xFFFFA726);
  
  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF8B2F8B), Color(0xFFAB4FAB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
      primary: primaryColor,
      secondary: primaryLight,
      surface: surfaceColor,
      background: backgroundColor,
      error: errorColor,
    ),
    scaffoldBackgroundColor: backgroundColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.white),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: primaryColor,
      unselectedItemColor: textSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
    ),
    cardTheme: const CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
      color: surfaceColor,
      margin: EdgeInsets.zero,
    ),
    dividerTheme: const DividerThemeData(color: dividerColor, thickness: 0.5),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        elevation: 0,
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.dark,
      primary: primaryColor,
      secondary: primaryLight,
      surface: darkSurface,
      background: darkBackground,
      error: errorColor,
    ),
    scaffoldBackgroundColor: darkBackground,
    appBarTheme: const AppBarTheme(
      backgroundColor: darkSurface,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.white),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: darkSurface,
      selectedItemColor: primaryColor,
      unselectedItemColor: textLight,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    cardTheme: const CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
      color: darkCard,
    ),
    dividerTheme: const DividerThemeData(color: Color(0xFF2C3847), thickness: 0.5),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        elevation: 0,
      ),
    ),
  );
}