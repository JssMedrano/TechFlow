import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Paleta e tema TechFlow
class AppTheme {
  static const Color bg = Color(0xFF12141C);
  static const Color surface = Color(0xFF1C1F2E);
  static const Color surfaceAlt = Color(0xFF242836);
  static const Color sidebar = Color(0xFF161822);
  static const Color border = Color(0xFF2C3142);
  static const Color textPrimary = Color(0xFFF4F6FB);
  static const Color textMuted = Color(0xFF93A0B8);
  static const Color accent = Color(0xFFB8F574);
  static const Color accentDark = Color(0xFF0F1410);
  static const Color gold = Color(0xFFE8B86D);
  static const Color open = Color(0xFFF0A04B);
  static const Color inProgress = Color(0xFF5B8DEF);
  static const Color urgent = Color(0xFFEF5B5B);
  static const Color delayed = Color(0xFF9B2226);
  static const Color success = Color(0xFF4ADE80);
  static const Color warning = Color(0xFFFBBF24);

  static ThemeData dark() {
    final baseText = GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme);
    final scheme = const ColorScheme.dark(
      primary: accent,
      onPrimary: accentDark,
      secondary: gold,
      surface: surface,
      onSurface: textPrimary,
      error: urgent,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: bg,
      textTheme: baseText.apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.outfit(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: border),
        ),
      ),
      dividerColor: border,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceAlt,
        hintStyle: const TextStyle(color: textMuted),
        labelStyle: const TextStyle(color: textMuted),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accent, width: 1.2),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: accentDark,
          textStyle: GoogleFonts.outfit(fontWeight: FontWeight.w700),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          side: const BorderSide(color: border),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return success;
          return surfaceAlt;
        }),
        checkColor: WidgetStateProperty.all(accentDark),
        side: const BorderSide(color: border),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: surfaceAlt,
        contentTextStyle: TextStyle(color: textPrimary),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      drawerTheme: const DrawerThemeData(backgroundColor: sidebar),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: accent.withValues(alpha: 0.18),
        labelTextStyle: WidgetStateProperty.all(
          GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
