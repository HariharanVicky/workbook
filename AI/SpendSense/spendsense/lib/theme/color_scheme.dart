import 'package:flutter/material.dart';

class AppColorScheme {
  static const Color _primaryLight = Color(0xFF2196F3);
  static const Color _primaryDark = Color(0xFF90CAF9);

  static const Color _secondaryLight = Color(0xFF03DAC6);
  static const Color _secondaryDark = Color(0xFF03DAC6);

  static const Color _errorLight = Color(0xFFB00020);
  static const Color _errorDark = Color(0xFFCF6679);

  static const Color _backgroundLight = Color(0xFFF5F5F5);
  static const Color _backgroundDark = Color(0xFF121212);

  static const Color _surfaceLight = Colors.white;
  static const Color _surfaceDark = Color(0xFF1E1E1E);

  static const ColorScheme lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: _primaryLight,
    onPrimary: Colors.white,
    secondary: _secondaryLight,
    onSecondary: Colors.black,
    error: _errorLight,
    onError: Colors.white,
    background: _backgroundLight,
    onBackground: Colors.black,
    surface: _surfaceLight,
    onSurface: Colors.black,
  );

  static const ColorScheme darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: _primaryDark,
    onPrimary: Colors.black,
    secondary: _secondaryDark,
    onSecondary: Colors.black,
    error: _errorDark,
    onError: Colors.black,
    background: _backgroundDark,
    onBackground: Colors.white,
    surface: _surfaceDark,
    onSurface: Colors.white,
  );

  // Category Colors
  static const Map<String, Color> categoryColors = {
    'Food': Color(0xFFFFA726),
    'Transport': Color(0xFF42A5F5),
    'Shopping': Color(0xFFAB47BC),
    'Bills': Color(0xFFEF5350),
    'Entertainment': Color(0xFF66BB6A),
    'Other': Color(0xFF9E9E9E),
  };

  // Amount Colors
  static const Color incomeColor = Color(0xFF4CAF50);
  static const Color expenseColor = Color(0xFFF44336);
} 