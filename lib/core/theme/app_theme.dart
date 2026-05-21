import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_typography.dart';

ThemeData buildEidTheme() {
  final ColorScheme colorScheme = ColorScheme.fromSeed(
    seedColor: EidColors.green,
    primary: EidColors.green,
    onPrimary: EidColors.textOnGreen,
    secondary: EidColors.gold,
    onSecondary: EidColors.darkGreen,
    surface: EidColors.cardBackground,
    onSurface: EidColors.textPrimary,
    error: EidColors.error,
    brightness: Brightness.light,
  );

  final TextTheme textTheme = buildCairoTextTheme();

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: EidColors.cream,
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: EidColors.green,
      foregroundColor: EidColors.textOnGreen,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: textTheme.titleLarge?.copyWith(
        color: EidColors.textOnGreen,
        fontWeight: FontWeight.w700,
      ),
      iconTheme: const IconThemeData(color: EidColors.gold),
    ),
    cardTheme: CardTheme(
      color: EidColors.cardBackground,
      elevation: 1.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: EidColors.divider, width: 0.6),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: EidColors.green,
        foregroundColor: EidColors.textOnGreen,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        textStyle: eidButtonStyle(),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: EidColors.darkGreen,
        side: const BorderSide(color: EidColors.gold, width: 1.4),
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        textStyle: eidButtonStyle(),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: EidColors.darkGreen,
        textStyle: eidButtonStyle().copyWith(fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: EidColors.cardBackground,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: EidColors.divider, width: 0.8),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: EidColors.divider, width: 0.8),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: EidColors.gold, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: EidColors.error, width: 1.2),
      ),
      labelStyle: eidBodyStyle().copyWith(color: EidColors.textSecondary),
    ),
    dividerTheme: const DividerThemeData(
      color: EidColors.divider,
      thickness: 0.6,
      space: 24,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: EidColors.darkGreen,
      contentTextStyle: textTheme.bodyMedium?.copyWith(
        color: EidColors.textOnGreen,
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );
}
