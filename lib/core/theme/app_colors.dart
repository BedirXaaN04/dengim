import 'package:flutter/material.dart';

/// DENGİM Renk Paleti - Neo-Brutalism Teması
class AppColors {
  AppColors._();

  // Ana Renkler (Neo-Brutalism)
  static const Color scaffold = Color(0xFFF4F4F0);      // Krem Arka Plan
  static const Color primary = Color(0xFFFFD500);       // Neo Yellow
  static const Color secondary = Color(0xFFFF90E8);     // Neo Pink
  static const Color blue = Color(0xFF38DBFF);          // Neo Blue
  static const Color green = Color(0xFF00E676);         // Neo Green
  static const Color red = Color(0xFFFF3366);           // Neo Red
  
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);

  // Metin Renkleri
  static const Color textPrimary = Color(0xFF000000);   // Siyah
  static const Color textSecondary = Color(0xFF4B5563); // Gri
  
  // Yüzey Renkleri
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFF9FAFB);
  
  // Durum Renkleri
  static const Color success = Color(0xFF00E676);
  static const Color error = Color(0xFFFF3366);
  static const Color warning = Color(0xFFFFD500);
  
  // Neo Shadows
  static const BoxShadow neoShadow = BoxShadow(
    color: Colors.black,
    offset: Offset(4, 4),
    blurRadius: 0,
  );

  static const BoxShadow neoShadowLarge = BoxShadow(
    color: Colors.black,
    offset: Offset(8, 8),
    blurRadius: 0,
  );

  static const BoxShadow neoShadowSmall = BoxShadow(
    color: Colors.black,
    offset: Offset(3, 3),
    blurRadius: 0,
  );
}
