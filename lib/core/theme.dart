import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Color Palette
  static const Color primaryTeal = Color(0xFF00897B);
  static const Color primaryTealDark = Color(0xFF00564D);
  static const Color primaryTealLight = Color(0xFFE0F2F1);
  static const Color primaryTealAccent = Color(0xFF4DB6AC);

  static const Color secondaryBlue = Color(0xFF1E88E5);
  static const Color secondaryBlueDark = Color(0xFF1565C0);
  static const Color secondaryBlueLight = Color(0xFFE3F2FD);

  static const Color emergencyRed = Color(0xFFD32F2F);
  static const Color emergencyRedLight = Color(0xFFFFEBEE);

  static const Color successGreen = Color(0xFF2E7D32);
  static const Color successGreenLight = Color(0xFFE8F5E9);

  static const Color warningAmber = Color(0xFFF57F17);
  static const Color warningAmberLight = Color(0xFFFFF8E1);

  static const Color lightBg = Color(0xFFF5F9FA);
  static const Color darkBg = Color(0xFF12181B);
  static const Color darkSurface = Color(0xFF1E262B);
  static const Color darkCard = Color(0xFF263238);

  static const double cardRadius = 16.0;
  static const double buttonRadius = 12.0;

  // Box shadows
  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> mediumShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 20,
      offset: const Offset(0, 6),
    ),
  ];

  static List<BoxShadow> emergencyShadow = [
    BoxShadow(
      color: emergencyRed.withValues(alpha: 0.35),
      blurRadius: 18,
      spreadRadius: 2,
      offset: const Offset(0, 4),
    ),
  ];

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: GoogleFonts.poppins().fontFamily,
      primaryColor: primaryTeal,
      scaffoldBackgroundColor: lightBg,
      colorScheme: const ColorScheme.light(
        primary: primaryTeal,
        onPrimary: Colors.white,
        primaryContainer: primaryTealLight,
        onPrimaryContainer: primaryTealDark,
        secondary: secondaryBlue,
        onSecondary: Colors.white,
        secondaryContainer: secondaryBlueLight,
        onSecondaryContainer: secondaryBlueDark,
        error: emergencyRed,
        onError: Colors.white,
        surface: Colors.white,
        onSurface: Color(0xFF1C2731),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1C2731),
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.poppins(
          color: const Color(0xFF1C2731),
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(color: Color(0xFF1C2731)),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          side: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryTeal,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonRadius),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryTeal,
          side: const BorderSide(color: primaryTeal, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonRadius),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(buttonRadius),
          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(buttonRadius),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(buttonRadius),
          borderSide: const BorderSide(color: primaryTeal, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(buttonRadius),
          borderSide: const BorderSide(color: emergencyRed),
        ),
        labelStyle: GoogleFonts.poppins(color: const Color(0xFF64748B)),
        hintStyle: GoogleFonts.poppins(color: const Color(0xFF94A3B8), fontSize: 14),
      ),
      navigationRailTheme: const NavigationRailThemeData(
        backgroundColor: Colors.white,
        selectedIconTheme: IconThemeData(color: primaryTeal),
        unselectedIconTheme: IconThemeData(color: Color(0xFF64748B)),
        indicatorColor: primaryTealLight,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primaryTeal,
        unselectedItemColor: Color(0xFF64748B),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: GoogleFonts.poppins().fontFamily,
      primaryColor: primaryTealAccent,
      scaffoldBackgroundColor: darkBg,
      colorScheme: const ColorScheme.dark(
        primary: primaryTealAccent,
        onPrimary: Colors.black,
        primaryContainer: primaryTealDark,
        onPrimaryContainer: Colors.white,
        secondary: secondaryBlueLight,
        onSecondary: Colors.black,
        secondaryContainer: secondaryBlueDark,
        onSecondaryContainer: Colors.white,
        error: emergencyRed,
        onError: Colors.white,
        surface: darkSurface,
        onSurface: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: darkSurface,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          side: const BorderSide(color: Color(0xFF334155), width: 1),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryTealAccent,
          foregroundColor: Colors.black,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonRadius),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryTealAccent,
          side: const BorderSide(color: primaryTealAccent, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonRadius),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(buttonRadius),
          borderSide: const BorderSide(color: Color(0xFF475569)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(buttonRadius),
          borderSide: const BorderSide(color: Color(0xFF334155)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(buttonRadius),
          borderSide: const BorderSide(color: primaryTealAccent, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(buttonRadius),
          borderSide: const BorderSide(color: emergencyRed),
        ),
        labelStyle: GoogleFonts.poppins(color: const Color(0xFF94A3B8)),
        hintStyle: GoogleFonts.poppins(color: const Color(0xFF64748B), fontSize: 14),
      ),
      navigationRailTheme: const NavigationRailThemeData(
        backgroundColor: darkSurface,
        selectedIconTheme: IconThemeData(color: primaryTealAccent),
        unselectedIconTheme: IconThemeData(color: Color(0xFF94A3B8)),
        indicatorColor: primaryTealDark,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: darkSurface,
        selectedItemColor: primaryTealAccent,
        unselectedItemColor: Color(0xFF94A3B8),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}
