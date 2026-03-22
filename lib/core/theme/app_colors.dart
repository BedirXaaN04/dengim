import 'package:flutter/material.dart';

/// DENGİM Renk Paleti - Premium Siyah-Beyaz Teması
class AppColors {
  AppColors._();

  // Ana Renkler (Soft & Premium)
  static const Color scaffold = Color(0xFFFAFAFA);      // Lüks Açık Gri / Neredeyse Beyaz
  static const Color primary = Color(0xFFFF6B6B);       // Soft Coral (Sıcak, davetkar, premium)
  static const Color secondary = Color(0xFF6B7280);     // Kaliteli Gri (Orta-Koyu)
  
  // Soft Accent Colors
  static const Color blue = Color(0xFF4FA8D1);          // Daha yumuşak mavi
  static const Color green = Color(0xFF10B981);         // Sakin, koyu başarı yeşili
  static const Color red = Color(0xFFEF4444);           // Sofistike Hata Kırmızısı
  static const Color orange = Color(0xFFF59E0B);        // Uyarı Turuncusu
  static const Color vibrantGold = Color(0xFFD4AF37);   // Canlı Altın (Vurgu)
  
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);

  // Gold Gradient (VIP/Premium hissiyatı için daha şık, metalik/altın ton)
  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFD4AF37), Color(0xFFA67C00)], // Metalik daha soğuk Altın
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Metin Renkleri
  static const Color textPrimary = Color(0xFF111111);   // Çok Koyu Gri/Siyah
  static const Color textSecondary = Color(0xFF6B7280); // Sofistike Gri
  
  // Yüzey Renkleri
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFF3F4F6);
  
  // Durum Renkleri
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  
  // Minimalist Styling Tokens
  static const double neoBorderWidth = 1.0;
  static const double neoBorderWidthPixels = 1.0;
  static const double neoBorderWidthSmall = 0.5;
  static const double neoBorderWidthSmallPixels = 0.5;
  static const double neoBorderWidthLarge = 1.5;
  static const double neoBorderWidthLargePixels = 1.5;
  static const double neoRadius = 12.0;          // Biraz daha modern/köşeli
  static const double neoRadiusSmall = 8.0;
  static const double neoRadiusLarge = 20.0;     // Yuvarlak ama abartısız

  // Premium Soft Shadows
  static BoxShadow neoShadow = BoxShadow(
    color: Colors.black.withValues(alpha: 0.05),
    offset: const Offset(0, 4),
    blurRadius: 12,
    spreadRadius: 0,
  );

  static BoxShadow neoShadowLarge = BoxShadow(
    color: Colors.black.withValues(alpha: 0.08),
    offset: const Offset(0, 8),
    blurRadius: 20,
    spreadRadius: 2,
  );

  static BoxShadow neoShadowSmall = BoxShadow(
    color: Colors.black.withValues(alpha: 0.03),
    offset: const Offset(0, 2),
    blurRadius: 6,
    spreadRadius: 0,
  );
}
