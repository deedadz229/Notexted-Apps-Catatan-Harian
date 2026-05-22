import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppTheme {
  static const notesYellow = Color(0xFFFFD76A);
  static const softYellow = Color(0xFFFFF6D8);
  static const ink = Color(0xFF1D1D1F);
  static const greyText = Color(0xFF6E6E73);

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: notesYellow,
      brightness: Brightness.light,
      primary: notesYellow,
      surface: Colors.white,
    );
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'SF Pro Display',
      scaffoldBackgroundColor: const Color(0xFFFAFAFA),
      colorScheme: scheme,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: Colors.transparent,
        foregroundColor: ink,
        titleTextStyle: TextStyle(
          color: ink,
          fontSize: 32,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
      ),
      inputDecorationTheme: _inputDecoration(false),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: notesYellow,
        foregroundColor: ink,
        elevation: 4,
        shape: CircleBorder(),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  static ThemeData get dark {
    final scheme = ColorScheme.fromSeed(
      seedColor: notesYellow,
      brightness: Brightness.dark,
      primary: notesYellow,
      surface: const Color(0xFF1C1C1E),
    );
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'SF Pro Display',
      scaffoldBackgroundColor: const Color(0xFF111113),
      colorScheme: scheme,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 32,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
      ),
      inputDecorationTheme: _inputDecoration(true),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: notesYellow,
        foregroundColor: ink,
        elevation: 4,
        shape: CircleBorder(),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  static InputDecorationTheme _inputDecoration(bool isDark) {
    return InputDecorationTheme(
      filled: true,
      fillColor: isDark ? const Color(0xFF242426) : Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: isDark ? const Color(0xFF38383A) : const Color(0xFFE8E8ED),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: isDark ? const Color(0xFF38383A) : const Color(0xFFE8E8ED),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: notesYellow, width: 1.6),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
    );
  }
}

class ThemeService extends GetxService {
  static ThemeService get to => Get.find<ThemeService>();

  final isDarkMode = false.obs;

  void toggleTheme() {
    isDarkMode.toggle();
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }
}
