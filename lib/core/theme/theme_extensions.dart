import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:powerhouse/core/theme/theme_provider.dart';

extension ThemeExtensions on BuildContext {
  // ✅ Easy access to dark mode status
  bool get isDarkMode {
    try {
      return watch<ThemeProvider>().isDarkMode;
    } catch (e) {
      return false;
    }
  }

  // ✅ Quick theme colors
  Color get primaryText => isDarkMode ? Colors.white : Colors.black;
  Color get secondaryText => isDarkMode ? Colors.white70 : const Color(0xFF7E7E7E);
  Color get cardBackground => isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
  Color get surfaceColor => isDarkMode ? const Color(0xFF121212) : Colors.white;
  Color get dividerColor => isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300;
  Color get inputBackground => isDarkMode ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F5);
  
  // ✅ App colors (always same)
  Color get primaryColor => const Color(0xFF1DAB87);
  Color get accentColor => const Color(0xFFF97316);
}