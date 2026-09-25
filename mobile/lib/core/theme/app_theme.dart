import 'package:flutter/material.dart';

/// Low-literacy, high-contrast design system tokens for Kabadiwala Connect
/// Non-negotiable principles:
/// 1. Min 56dp touch targets
/// 2. Consistent semantic color meaning (Green = Go/Earn, Red = Danger, Yellow = Pending)
/// 3. High contrast text and pictograms
class AppTheme {
  AppTheme._();

  // Semantic color palette
  static const Color greenGoEarn = Color(0xFF047857); // Green = go / earn / verified
  static const Color greenGoEarnLight = Color(0xFFD1FAE5);
  static const Color yellowPending = Color(0xFFD97706); // Yellow = pending / syncing
  static const Color yellowPendingLight = Color(0xFFFEF3C7);
  static const Color dangerRed = Color(0xFFDC2626); // Red = danger / hazard / stop
  static const Color dangerRedLight = Color(0xFFFEE2E2);

  // Background and surface
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color textHighContrast = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF475569);
  static const Color borderColor = Color(0xFFCBD5E1);

  // Touch target & accessibility constants
  static const double minTouchTargetSize = 56.0;
  static const double largeTouchTargetSize = 68.0;
  static const double keypadButtonHeight = 72.0;
  static const double actionCardMinHeight = 110.0;
  static const double iconSizeMedium = 32.0;
  static const double iconSizeLarge = 48.0;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: greenGoEarn,
      scaffoldBackgroundColor: backgroundLight,
      colorScheme: const ColorScheme.light(
        primary: greenGoEarn,
        onPrimary: Colors.white,
        primaryContainer: greenGoEarnLight,
        onPrimaryContainer: Color(0xFF064E3B),
        secondary: yellowPending,
        onSecondary: Colors.white,
        secondaryContainer: yellowPendingLight,
        onSecondaryContainer: Color(0xFF78350F),
        error: dangerRed,
        onError: Colors.white,
        errorContainer: dangerRedLight,
        onErrorContainer: Color(0xFF7F1D1D),
        surface: surfaceLight,
        onSurface: textHighContrast,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceLight,
        foregroundColor: textHighContrast,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: textHighContrast,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(minTouchTargetSize, minTouchTargetSize),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(minTouchTargetSize, minTouchTargetSize),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          side: const BorderSide(color: borderColor, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceLight,
        selectedItemColor: greenGoEarn,
        unselectedItemColor: textMuted,
        selectedLabelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        unselectedLabelStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}
