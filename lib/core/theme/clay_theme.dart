import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'clay_colors.dart';

class ClayTheme {
  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.plusJakartaSansTextTheme();

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: ClayColors.canvas,
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: ClayColors.primary,
        onPrimary: Colors.white,
        primaryContainer: ClayColors.primaryContainer,
        onPrimaryContainer: ClayColors.textPrimary,
        secondary: ClayColors.secondary,
        onSecondary: Colors.white,
        secondaryContainer: ClayColors.secondaryContainer,
        onSecondaryContainer: ClayColors.textPrimary,
        tertiary: ClayColors.mint,
        onTertiary: Colors.white,
        surface: ClayColors.canvas,
        onSurface: ClayColors.textPrimary,
        error: ClayColors.error,
        onError: ClayColors.onError,
        outline: ClayColors.outline,
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: GoogleFonts.plusJakartaSans(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          color: ClayColors.textPrimary,
          letterSpacing: -0.5,
        ),
        headlineLarge: GoogleFonts.plusJakartaSans(
          fontSize: 26,
          fontWeight: FontWeight.w800,
          color: ClayColors.textPrimary,
          letterSpacing: -0.4,
        ),
        headlineMedium: GoogleFonts.plusJakartaSans(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: ClayColors.textPrimary,
          letterSpacing: -0.2,
        ),
        headlineSmall: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: ClayColors.textPrimary,
        ),
        titleLarge: GoogleFonts.plusJakartaSans(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: ClayColors.textPrimary,
        ),
        titleMedium: GoogleFonts.plusJakartaSans(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: ClayColors.textPrimary,
        ),
        bodyLarge: GoogleFonts.plusJakartaSans(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: ClayColors.textPrimary,
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.plusJakartaSans(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: ClayColors.textSecondary,
          height: 1.4,
        ),
        bodySmall: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.w400,
          color: ClayColors.textTertiary,
        ),
        labelLarge: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
        labelMedium: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
        labelSmall: GoogleFonts.plusJakartaSans(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: ClayColors.canvas,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: ClayColors.textPrimary,
        ),
        iconTheme: const IconThemeData(color: ClayColors.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: ClayColors.cardSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
    );
  }

  // Common Claymorphic Box Shadow stacks
  static List<BoxShadow> get cardShadow => [
        const BoxShadow(
          color: Color(0x128B5CF6),
          offset: Offset(0, 10),
          blurRadius: 28,
          spreadRadius: 0,
        ),
        const BoxShadow(
          color: Color(0x082E1065),
          offset: Offset(0, 4),
          blurRadius: 10,
          spreadRadius: 0,
        ),
      ];

  static List<BoxShadow> get buttonShadow => [
        const BoxShadow(
          color: Color(0x408B5CF6),
          offset: Offset(0, 8),
          blurRadius: 20,
          spreadRadius: 0,
        ),
        const BoxShadow(
          color: Color(0x208B5CF6),
          offset: Offset(0, 2),
          blurRadius: 6,
          spreadRadius: 0,
        ),
      ];

  static List<BoxShadow> get subtlePillShadow => [
        const BoxShadow(
          color: Color(0x0C8B5CF6),
          offset: Offset(0, 3),
          blurRadius: 8,
          spreadRadius: 0,
        ),
      ];
}
