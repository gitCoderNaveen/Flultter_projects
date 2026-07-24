import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextTheme {
  AppTextTheme._();

  static TextTheme get textTheme => TextTheme(
        displayLarge: GoogleFonts.inter(
          fontWeight: FontWeight.bold,
        ),

        displayMedium: GoogleFonts.inter(
          fontWeight: FontWeight.bold,
        ),

        headlineLarge: GoogleFonts.inter(
          fontWeight: FontWeight.w700,
        ),

        headlineMedium: GoogleFonts.inter(
          fontWeight: FontWeight.w700,
        ),

        titleLarge: GoogleFonts.inter(
          fontWeight: FontWeight.w700,
        ),

        titleMedium: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
        ),

        bodyLarge: GoogleFonts.inter(),

        bodyMedium: GoogleFonts.inter(),

        labelLarge: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
        ),
      );
}