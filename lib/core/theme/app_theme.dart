import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// DENGİM Ana Tema Yapılandırması - Neo-Brutalism
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      // Renk Şeması
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        error: AppColors.error,
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onSurface: AppColors.textPrimary,
        onError: Colors.white,
      ),
      
      // Scaffold Arka Plan
      scaffoldBackgroundColor: AppColors.scaffold,
      
      // AppBar Teması
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        shape: const Border(
          bottom: BorderSide(color: Colors.black, width: 3),
        ),
        titleTextStyle: GoogleFonts.outfit(
          color: AppColors.textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w900,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.textPrimary,
          size: 28,
        ),
      ),
      
      // Tipografi - Outfit (Sert ve Net)
      textTheme: GoogleFonts.outfitTextTheme(
        const TextTheme(
          displayLarge: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w900),
          displayMedium: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w900),
          displaySmall: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w900),
          headlineLarge: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w900),
          headlineMedium: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w900),
          headlineSmall: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w900),
          titleLarge: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800),
          titleMedium: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800),
          titleSmall: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800),
          bodyLarge: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
          bodyMedium: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
          bodySmall: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w500),
          labelLarge: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
          labelMedium: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w700),
          labelSmall: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w700),
        ),
      ),
      
      // Bottom Navigation Bar Teması
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        showUnselectedLabels: true,
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
      
      // Elevated Button Teması (Neo-Brutalism Button)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          minimumSize: const Size(double.infinity, 60),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Colors.black, width: 3),
          ),
          textStyle: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      
      // Text Button Teması
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: Colors.black,
          textStyle: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
      
      // Outlined Button Teması
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.black,
          side: const BorderSide(color: Colors.black, width: 3),
          minimumSize: const Size(double.infinity, 60),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      
      // Card Teması
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Colors.black, width: 3),
        ),
      ),
      
      // Input Decoration Teması
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        hintStyle: GoogleFonts.outfit(
          color: AppColors.textSecondary,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 20,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.black, width: 3),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.black, width: 3),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.blue, width: 4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.error, width: 3),
        ),
      ),
      
      // Divider Teması
      dividerTheme: const DividerThemeData(
        color: Colors.black,
        thickness: 3,
        space: 24,
      ),
      
      // Icon Teması
      iconTheme: const IconThemeData(
        color: Colors.black,
        size: 24,
      ),
      
      // Floating Action Button Teması
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.black,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Colors.black, width: 3),
        ),
      ),
    );
  }

  // Geriye dönük uyumluluk için static getter
  static ThemeData get darkTheme => lightTheme; 
}
