import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFFE50914); // Netflix Red
  static const Color backgroundColor = Color(0xFF000000); // Netflix Black
  static const Color secondaryColor = Color(0xFF121212); // Slightly lighter black
  static const Color textColor = Colors.white;
  static const Color accentColor = Color(0xFFE50914);

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      secondary: accentColor,
      surface: secondaryColor,
      onPrimary: Colors.white,
      onSurface: Colors.white,
    ),
    textTheme: TextTheme(
      headlineMedium: GoogleFonts.bebasNeue(
        color: textColor,
        fontSize: 34,
        letterSpacing: 2,
      ),
      titleLarge: GoogleFonts.montserrat(
        color: textColor,
        fontWeight: FontWeight.w700,
        fontSize: 20,
      ),
      bodyLarge: GoogleFonts.montserrat(
        color: Colors.white70,
        fontSize: 14,
        fontWeight: FontWeight.w400,
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
      backgroundColor: Colors.black,
      selectedItemColor: primaryColor,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      elevation: 10,
    ),
    drawerTheme: const DrawerThemeData(
      backgroundColor: backgroundColor,
    ),
  );
}
