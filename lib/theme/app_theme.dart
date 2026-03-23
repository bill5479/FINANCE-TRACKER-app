import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ─── Dark Theme Colors (Primary) ───
  static const Color darkBg = Color(0xFF0A0E27);
  static const Color darkSurface = Color(0xFF111638);
  static const Color darkCard = Color(0xFF1A1F4A);
  static const Color darkAccent = Color(0xFF6C63FF);
  static const Color darkAccentSecondary = Color(0xFF00D9FF);
  static const Color darkSuccess = Color(0xFF00E5A0);
  static const Color darkWarning = Color(0xFFFFB547);
  static const Color darkError = Color(0xFFFF6B6B);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFB0B3D6);
  static const Color darkTextTertiary = Color(0xFF6B6F9A);
  static const Color darkGlassOverlay = Color(0x15FFFFFF);
  static const Color darkGlassBorder = Color(0x20FFFFFF);

  // ─── Light Theme Colors ───
  static const Color lightBg = Color(0xFFF0F2FF);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFF8F9FF);
  static const Color lightAccent = Color(0xFF6C63FF);
  static const Color lightAccentSecondary = Color(0xFF00B4D8);
  static const Color lightSuccess = Color(0xFF00C48C);
  static const Color lightWarning = Color(0xFFFF9F43);
  static const Color lightError = Color(0xFFFF5252);
  static const Color lightTextPrimary = Color(0xFF1A1D3E);
  static const Color lightTextSecondary = Color(0xFF6B6F9A);
  static const Color lightTextTertiary = Color(0xFFA0A4C8);
  static const Color lightGlassOverlay = Color(0x12000000);
  static const Color lightGlassBorder = Color(0x15000000);

  // ─── Gradient Palettes ───
  static const List<Color> incomeGradient = [
    Color(0xFF00E5A0),
    Color(0xFF00D9FF),
  ];

  static const List<Color> expenseGradient = [
    Color(0xFFFF6B6B),
    Color(0xFFFF9F43),
  ];

  static const List<Color> accentGradient = [
    Color(0xFF6C63FF),
    Color(0xFF00D9FF),
  ];

  static const List<Color> businessGradient = [
    Color(0xFFFF6B6B),
    Color(0xFF6C63FF),
  ];

  // ─── Text Styles ───
  static TextStyle get displayLarge => GoogleFonts.inter(
        fontSize: 40,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.5,
      );

  static TextStyle get displayMedium => GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.0,
      );

  static TextStyle get headlineLarge => GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
      );

  static TextStyle get headlineMedium => GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get titleLarge => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get titleMedium => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
      );

  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
      );

  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
      );

  static TextStyle get bodySmall => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
      );

  static TextStyle get labelLarge => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      );

  static TextStyle get labelSmall => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      );

  static TextStyle get amountLarge => GoogleFonts.inter(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.0,
      );

  static TextStyle get amountMedium => GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      );

  static TextStyle get amountSmall => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
      );

  // ─── Theme Data ───
  static ThemeData get darkTheme => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: darkBg,
        colorScheme: ColorScheme.dark(
          primary: darkAccent,
          secondary: darkAccentSecondary,
          surface: darkSurface,
          error: darkError,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: darkTextPrimary,
          onError: Colors.white,
        ),
        textTheme: TextTheme(
          displayLarge: displayLarge.copyWith(color: darkTextPrimary),
          displayMedium: displayMedium.copyWith(color: darkTextPrimary),
          headlineLarge: headlineLarge.copyWith(color: darkTextPrimary),
          headlineMedium: headlineMedium.copyWith(color: darkTextPrimary),
          titleLarge: titleLarge.copyWith(color: darkTextPrimary),
          titleMedium: titleMedium.copyWith(color: darkTextPrimary),
          bodyLarge: bodyLarge.copyWith(color: darkTextPrimary),
          bodyMedium: bodyMedium.copyWith(color: darkTextSecondary),
          bodySmall: bodySmall.copyWith(color: darkTextTertiary),
          labelLarge: labelLarge.copyWith(color: darkTextPrimary),
          labelSmall: labelSmall.copyWith(color: darkTextTertiary),
        ),
        useMaterial3: true,
      );

  static ThemeData get lightTheme => ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: lightBg,
        colorScheme: ColorScheme.light(
          primary: lightAccent,
          secondary: lightAccentSecondary,
          surface: lightSurface,
          error: lightError,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: lightTextPrimary,
          onError: Colors.white,
        ),
        textTheme: TextTheme(
          displayLarge: displayLarge.copyWith(color: lightTextPrimary),
          displayMedium: displayMedium.copyWith(color: lightTextPrimary),
          headlineLarge: headlineLarge.copyWith(color: lightTextPrimary),
          headlineMedium: headlineMedium.copyWith(color: lightTextPrimary),
          titleLarge: titleLarge.copyWith(color: lightTextPrimary),
          titleMedium: titleMedium.copyWith(color: lightTextPrimary),
          bodyLarge: bodyLarge.copyWith(color: lightTextPrimary),
          bodyMedium: bodyMedium.copyWith(color: lightTextSecondary),
          bodySmall: bodySmall.copyWith(color: lightTextTertiary),
          labelLarge: labelLarge.copyWith(color: lightTextPrimary),
          labelSmall: labelSmall.copyWith(color: lightTextTertiary),
        ),
        useMaterial3: true,
      );

  // ─── Helpers ───
  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color bg(BuildContext context) =>
      isDark(context) ? darkBg : lightBg;

  static Color surface(BuildContext context) =>
      isDark(context) ? darkSurface : lightSurface;

  static Color card(BuildContext context) =>
      isDark(context) ? darkCard : lightCard;

  static Color accent(BuildContext context) =>
      isDark(context) ? darkAccent : lightAccent;

  static Color accentSecondary(BuildContext context) =>
      isDark(context) ? darkAccentSecondary : lightAccentSecondary;

  static Color success(BuildContext context) =>
      isDark(context) ? darkSuccess : lightSuccess;

  static Color warning(BuildContext context) =>
      isDark(context) ? darkWarning : lightWarning;

  static Color error(BuildContext context) =>
      isDark(context) ? darkError : lightError;

  static Color textPrimary(BuildContext context) =>
      isDark(context) ? darkTextPrimary : lightTextPrimary;

  static Color textSecondary(BuildContext context) =>
      isDark(context) ? darkTextSecondary : lightTextSecondary;

  static Color textTertiary(BuildContext context) =>
      isDark(context) ? darkTextTertiary : lightTextTertiary;

  static Color glassOverlay(BuildContext context) =>
      isDark(context) ? darkGlassOverlay : lightGlassOverlay;

  static Color glassBorder(BuildContext context) =>
      isDark(context) ? darkGlassBorder : lightGlassBorder;
}
