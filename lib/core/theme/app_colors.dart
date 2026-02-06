import 'package:flutter/material.dart';

/// DENGİM Renk Paleti - Midnight Luxury Teması
class AppColors {
  AppColors._();

  // Ana Renkler
  static const Color scaffold = Color(0xFF0F1115);      // Kömür Siyahı - Zemin
  static const Color primary = Color(0xFFD4AF37);       // DENGIM Luxury Gold (#D4AF37)
  static const Color secondary = Color(0xFFFFD900);     // DENGIM Vibrant Gold (#FFD900)
  static const Color vibrantGold = Color(0xFFFFD900);   // Parlak Altın
  
  // Metin Renkleri
  static const Color textPrimary = Color(0xFFFFFFFF);   // Beyaz
  static const Color textSecondary = Color(0xFF9CA3AF); // Gri
  
  // Yüzey Renkleri
  static const Color surface = Color(0xFF1C1F26);       // Charcoal Gray (#1C1F26)
  static const Color surfaceLight = Color(0xFF2C303A);  // Hafif Açık Gri
  
  // Durum Renkleri
  static const Color success = Color(0xFF10B981);       // Yeşil
  static const Color error = Color(0xFFEF4444);         // Kırmızı
  static const Color warning = Color(0xFFF59E0B);       // Turuncu
  
  // Luxury Gradient
  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFD4AF37), Color(0xFFF5E6AD), Color(0xFFC5A059)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient storyGradient = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)], // Purple to Pink
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

}
