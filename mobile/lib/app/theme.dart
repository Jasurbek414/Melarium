import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MelariumTheme {
  // Colors
  static const Color honey400 = Color(0xFFFBBF24);
  static const Color honey500 = Color(0xFFF59E0B);
  static const Color honey600 = Color(0xFFD97706);
  static const Color dark950  = Color(0xFF0A0E12);
  static const Color dark900  = Color(0xFF111827);
  static const Color dark800  = Color(0xFF1F2937);
  static const Color forest700 = Color(0xFF1A3520);
  static const Color success  = Color(0xFF10B981);
  static const Color error    = Color(0xFFEF4444);

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: dark950,
    colorScheme: const ColorScheme.dark(
      primary: honey500,
      secondary: honey400,
      surface: dark800,
      error: error,
    ),
    textTheme: TextTheme(
      headlineLarge: TextStyle(
        fontFamily: 'serif',
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
      headlineMedium: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
      bodyLarge: const TextStyle(fontSize: 16, color: Colors.white),
      bodyMedium: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.7)),
      labelSmall: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.5)),
    ),
    cardTheme: CardTheme(
      color: dark800,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.white.withOpacity(0.08)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: honey500,
        foregroundColor: forest700,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: honey500),
      ),
      hintStyle: TextStyle(color: Colors.white.withOpacity(0.35)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: dark950.withOpacity(0.9),
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
      iconTheme: const IconThemeData(color: Colors.white),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: dark900,
      selectedItemColor: honey400,
      unselectedItemColor: Colors.white.withOpacity(0.4),
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
  );
}
