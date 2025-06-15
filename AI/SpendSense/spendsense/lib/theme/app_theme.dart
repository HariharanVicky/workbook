import 'package:flutter/material.dart';
import 'color_scheme.dart';
import 'text_theme.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: AppColorScheme.lightColorScheme,
      textTheme: AppTextTheme.textTheme,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
      cardTheme: const CardThemeData(
        color: Colors.white,
        elevation: 2,
        margin: EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 2,
      ),
      iconTheme: const IconThemeData(
        size: 24,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: AppColorScheme.darkColorScheme,
      textTheme: AppTextTheme.textTheme,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
      cardTheme: const CardThemeData(
        color: Colors.white,
        elevation: 2,
        margin: EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 2,
      ),
      iconTheme: const IconThemeData(
        size: 24,
      ),
    );
  }
} 