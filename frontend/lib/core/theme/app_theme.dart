import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Luminous Luxury Coastal Minimalist Palette
  static const Color primaryNavy = Color(0xFF0F172A); // Slate Midnight
  static const Color primaryBlue = Color(0xFF1E293B); // Deep Charcoal Slate
  static const Color primaryAccent = Color(0xFF2563EB); // Royal Ocean Blue
  static const Color accentOcean = Color(0xFF2563EB);
  static const Color accentAzure = Color(0xFF0284C7); // Sky Azure
  static const Color accentEmerald = Color(0xFF059669); // Emerald Green
  static const Color secondaryTeal = Color(0xFF059669); // Emerald Teal
  static const Color caribbeanTeal = Color(0xFF059669); // Caribbean Teal
  static const Color accentGold = Color(0xFF2563EB); // Modern Sapphire Accent
  static const Color accentGoldLight = Color(0xFF38BDF8); // Sky Light Accent
  static const Color accentSand = Color(0xFFD97706); // Warm Amber Sand

  // Surfaces & Clean Canvas
  static const Color bgCanvas = Color(0xFFF8FAFC); // Clean Pure Slate Canvas
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceWhite = Color(0xFFFFFFFF); // Pure White
  static const Color surfaceCard = Color(0xFFFFFFFF);
  static const Color surfaceSubtle = Color(0xFFF1F5F9);

  // Borders & Dividers
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color borderSubtle = Color(0xFFEEF2F6);

  // Typography Colors
  static const Color textDark = Color(0xFF0F172A);
  static const Color textBody = Color(0xFF334155);
  static const Color textMuted = Color(0xFF64748B);
  static const Color textLight = Color(0xFF94A3B8);

  // Status Colors
  static const Color successGreen = Color(0xFF059669);
  static const Color warningOrange = Color(0xFFD97706);
  static const Color errorRed = Color(0xFFDC2626);
  static const Color infoBlue = Color(0xFF2563EB);

  // Clean Gradients
  static const LinearGradient navyHeroGradient = LinearGradient(
    colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Ambient Shadows
  static List<BoxShadow> get cleanCardShadow => [
        BoxShadow(
          color: const Color(0xFF0F172A).withAlpha(8),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: const Color(0xFF0F172A).withAlpha(4),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get luxuryCardShadow => cleanCardShadow;

  static List<BoxShadow> get goldGlowShadow => [
        BoxShadow(
          color: primaryAccent.withAlpha(40),
          blurRadius: 14,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get heroShadow => [
        BoxShadow(
          color: const Color(0xFF0F172A).withAlpha(25),
          blurRadius: 20,
          offset: const Offset(0, 6),
        ),
      ];

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryAccent,
        primary: primaryNavy,
        secondary: primaryAccent,
        surface: surfaceWhite,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: bgCanvas,
      textTheme: GoogleFonts.plusJakartaSansTextTheme().copyWith(
        displayLarge: GoogleFonts.plusJakartaSans(
          fontSize: 30,
          fontWeight: FontWeight.w800,
          color: primaryNavy,
          letterSpacing: -0.8,
        ),
        displayMedium: GoogleFonts.plusJakartaSans(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: primaryNavy,
          letterSpacing: -0.5,
        ),
        displaySmall: GoogleFonts.plusJakartaSans(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: primaryNavy,
        ),
        headlineMedium: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: textDark,
        ),
        titleLarge: GoogleFonts.plusJakartaSans(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: textDark,
        ),
        titleMedium: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textDark,
        ),
        titleSmall: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textMuted,
        ),
        bodyLarge: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          color: textBody,
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.plusJakartaSans(
          fontSize: 13,
          color: textBody,
          height: 1.4,
        ),
        bodySmall: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          color: textMuted,
          height: 1.4,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceWhite,
        foregroundColor: primaryNavy,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: Color(0x0F000000),
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: primaryNavy,
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderLight, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryAccent, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorRed),
        ),
        labelStyle: const TextStyle(color: textMuted, fontSize: 13.5),
        hintStyle: const TextStyle(color: textLight, fontSize: 13.5),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryNavy,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryNavy,
        foregroundColor: Colors.white,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      dividerTheme: const DividerThemeData(
        color: borderLight,
        thickness: 1,
      ),
    );
  }
}
