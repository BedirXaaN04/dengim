import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import 'services/purchase_service.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../ads/services/ad_service.dart';
import '../auth/services/profile_service.dart';
import '../../core/providers/user_provider.dart';
import 'package:provider/provider.dart';

class PremiumOfferScreen extends StatefulWidget {
  const PremiumOfferScreen({super.key});

  @override
  State<PremiumOfferScreen> createState() => _PremiumOfferScreenState();
}

class _PremiumOfferScreenState extends State<PremiumOfferScreen> {
  bool _isLoading = true;
  Offerings? _offerings;
  Package? _selectedPackage;

  @override
  void initState() {
    super.initState();
    _loadOfferings();
    AdService().init(); // Reklam servisini başlat
  }

  void _watchAd() {
    AdService().showRewardedAd(onReward: (amount) async {
       // Kredi Ekle (Varsayılan 10 kredi)
       await ProfileService().addCredits(10);
       
       if (mounted) {
         // Update provider to reflect new credits
         await context.read<UserProvider>().loadCurrentUser();
         
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('Tebrikler! 10 Kredi Kazandınız. 🎉')),
         );
       }
    });
  }

  Future<void> _loadOfferings() async {
    // Gerçek API Key olmadığı için loading'de kalmasın diye mock data ile simüle edelim (Geliştirme Amaçlı)
    // Gerçekte: 
    // var offerings = await PurchaseService().getOfferings();
    
    // Simülasyon:
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() {
        _isLoading = false;
        // _offerings = offerings; (Mock data olmadığı için UI'da manuel göstereceğiz)
      });
    }
  }

  Future<void> _buy() async {
    setState(() => _isLoading = true);
    
    // Simüle edilmiş satın alma
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
       setState(() => _isLoading = false);
       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text('Demo Modu: Satın alma başarılı (Simülasyon)')),
       );
       Navigator.pop(context, true); // Başarılı döndür
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: Stack(
        children: [
          // Background Glow
          Positioned(
            top: -150,
            left: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.vibrantGold.withOpacity(0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                // Close Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Logo / Header
                         Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [AppColors.primary, AppColors.secondary],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(color: AppColors.primary.withOpacity(0.5), blurRadius: 30),
                            ],
                          ),
                          child: const Icon(Icons.star_rounded, color: Colors.white, size: 48),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'DENGİM PREMİUM',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2.0,
                            color: AppColors.secondary,
                            shadows: [
                              Shadow(color: AppColors.secondary.withOpacity(0.5), blurRadius: 20),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Sınırları kaldır, ayrıcalıklı dünyanın kapılarını arala.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            color: Colors.white70,
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 48),

                        // Features List
                        _buildFeatureRow(Icons.visibility_rounded, 'Kimlerin Seni Beğendiğini Gör'),
                        _buildFeatureRow(Icons.history_rounded, 'Yanlışlıkla Geçtiklerini Geri Al'),
                        _buildFeatureRow(Icons.flash_on_rounded, 'Haftada 5 Super Like'),
                        _buildFeatureRow(Icons.location_on_rounded, 'Dünyanın Her Yerinde Kaydır'),
                        _buildFeatureRow(Icons.favorite_rounded, 'Sınırsız Beğeni Hakkı'),

                        const SizedBox(height: 48),

                        // Pricing Plans
                        Row(
                          children: [
                            Expanded(child: _buildPlanCard('1 Ay', '₺99.99', false)),
                            const SizedBox(width: 16),
                            Expanded(child: _buildPlanCard('12 Ay', '₺599.99', true)), // Best value
                          ],
                        ),

                        const SizedBox(height: 24),
                        
                        // Watch Ad Button (Alternative)
                        GestureDetector(
                          onTap: _watchAd,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.play_circle_filled_rounded, color: AppColors.secondary, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Reklam İzle & 10 Kredi Kazan',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),
                        
                        // Subscribe Button
                        GestureDetector(
                          onTap: _buy,
                          child: Container(
                            height: 64,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppColors.secondary, AppColors.primary],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.4),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (_isLoading)
                                   const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                else ...[
                                  Text(
                                    'DENGİNİ BULMAYA BAŞLA',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.arrow_forward_rounded, color: Colors.white),
                                ],
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        Text(
                          'İstediğin zaman iptal edebilirsin.',
                          style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.white30),
                        ),
                        const SizedBox(height: 48),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(String duration, String price, bool isBest) {
    final isSelected = isBest; // Şimdilik sadece Best Value seçili gelsin
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isSelected ? AppColors.primary : Colors.white.withOpacity(0.1),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          if (isBest)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'EN İYİ FİYAT',
                style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ),
          Text(
            duration,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            price,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
