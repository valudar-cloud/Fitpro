import 'package:flutter/material.dart';

// ════════════════════════════════════════════════════════
// THÈME — Dark sportif, orange énergique
// ════════════════════════════════════════════════════════

class AppTheme {
  AppTheme._();

  // ── Palette ───────────────────────────────────────────
  static const Color primary      = Color(0xFFFF6B35); // Orange énergique
  static const Color secondary    = Color(0xFF2ED573); // Vert succès
  static const Color accent       = Color(0xFFFFD700); // Or XP
  static const Color danger       = Color(0xFFFF4757); // Rouge alerte
  static const Color info         = Color(0xFF4ECDC4); // Cyan info

  static const Color bgDark       = Color(0xFF0D0D0D); // Fond principal
  static const Color surface      = Color(0xFF1A1A1A); // Cartes
  static const Color surfaceLight = Color(0xFF242424); // Cartes secondaires
  static const Color border       = Color(0xFF2A2A2A); // Bordures

  static const Color textPrimary   = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF9E9E9E);
  static const Color textHint      = Color(0xFF5A5A5A);

  // ── Thème sombre ─────────────────────────────────────
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: bgDark,
    primaryColor: primary,
    fontFamily: 'Poppins',

    colorScheme: const ColorScheme.dark(
      primary: primary,
      secondary: secondary,
      surface: surface,
      error: danger,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: textPrimary,
    ),

    // AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: bgDark,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: 0.5,
      ),
      iconTheme: IconThemeData(color: textPrimary),
    ),

    // Cards
    cardTheme: CardTheme(
      color: surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: border, width: 1),
      ),
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
    ),

    // ElevatedButton
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
        elevation: 0,
      ),
    ),

    // OutlinedButton
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primary,
        side: const BorderSide(color: primary, width: 1.5),
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // TextButton
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primary,
        textStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // Input fields
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: danger),
      ),
      labelStyle: const TextStyle(color: textSecondary, fontFamily: 'Poppins'),
      hintStyle: const TextStyle(color: textHint, fontFamily: 'Poppins'),
      errorStyle: const TextStyle(color: danger, fontFamily: 'Poppins'),
    ),

    // BottomNavBar
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: surface,
      selectedItemColor: primary,
      unselectedItemColor: textHint,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      selectedLabelStyle: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 11,
      ),
    ),

    // TabBar
    tabBarTheme: const TabBarTheme(
      labelColor: primary,
      unselectedLabelColor: textHint,
      indicatorColor: primary,
      labelStyle: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    ),

    // Textes
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32, fontWeight: FontWeight.w700,
        color: textPrimary, letterSpacing: -0.5,
      ),
      displayMedium: TextStyle(
        fontSize: 26, fontWeight: FontWeight.w700,
        color: textPrimary,
      ),
      headlineLarge: TextStyle(
        fontSize: 22, fontWeight: FontWeight.w700,
        color: textPrimary,
      ),
      headlineMedium: TextStyle(
        fontSize: 18, fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      titleLarge: TextStyle(
        fontSize: 16, fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      titleMedium: TextStyle(
        fontSize: 14, fontWeight: FontWeight.w500,
        color: textPrimary,
      ),
      bodyLarge: TextStyle(
        fontSize: 15, fontWeight: FontWeight.w400,
        color: textPrimary,
      ),
      bodyMedium: TextStyle(
        fontSize: 14, fontWeight: FontWeight.w400,
        color: textSecondary,
      ),
      bodySmall: TextStyle(
        fontSize: 12, fontWeight: FontWeight.w400,
        color: textHint,
      ),
      labelLarge: TextStyle(
        fontSize: 14, fontWeight: FontWeight.w600,
        color: textPrimary, letterSpacing: 0.5,
      ),
    ),
  );

  // ── Thème clair (optionnel) ───────────────────────────
  static ThemeData get lightTheme => darkTheme; // Pour l'instant, dark uniquement
}
