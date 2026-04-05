import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // --- Updated Colors based on Mandala Image ---
  static const Color primaryColor = Color(0xFFD4AF37); // Golden Metallic
  static const Color accentColor = Color(0xFFC9A227);  // Golden Amber
  static const Color backgroundColor = Color(0xFF040412); // Deep Space Navy
  static const Color secondaryColor = Color(0xFF0F0F3D); // Navy Shade
  static const Color maroonColor = Color(0xFF2D0D22); // Spiritual Maroon
  
  static const Color textColor = Colors.white;
  static const Color mutedTextColor = Colors.white70;

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      secondary: accentColor,
      surface: Color(0xFF08081E),
      onPrimary: Colors.black,
      onSurface: Colors.white,
    ),
    textTheme: TextTheme(
      headlineLarge: GoogleFonts.cinzel(
        color: primaryColor,
        fontSize: 30,
        fontWeight: FontWeight.bold,
        letterSpacing: 2.0,
      ),
      headlineMedium: GoogleFonts.cinzel(
        color: primaryColor,
        fontSize: 24,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
      ),
      titleLarge: GoogleFonts.cinzel(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.0,
      ),
      bodyLarge: GoogleFonts.lato(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      bodyMedium: GoogleFonts.lato(
        color: mutedTextColor,
        fontSize: 14,
      ),
      labelLarge: GoogleFonts.lato(
        color: primaryColor,
        fontSize: 12,
        fontWeight: FontWeight.w900,
        letterSpacing: 2.0,
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: primaryColor,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF040412),
      selectedItemColor: primaryColor,
      unselectedItemColor: Colors.white30,
      type: BottomNavigationBarType.fixed,
      elevation: 10,
    ),
    cardTheme: CardThemeData(
      color: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
  );

  // --- Background Gradient ---
  static BoxDecoration buildBackgroundDecoration() {
    return const BoxDecoration(
      gradient: RadialGradient(
        center: Alignment.center,
        radius: 1.2,
        colors: [
           Color(0xFF0F0F3D), // Soft Blue Navy
           Color(0xFF040412), // Deep Space Navy
        ],
      ),
    );
  }
}
