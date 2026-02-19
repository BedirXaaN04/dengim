import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/subscription_provider.dart';
import '../../core/providers/credit_provider.dart';
import '../../core/providers/user_provider.dart';
import '../../core/constants/tier_limits.dart';
import '../../core/utils/log_service.dart';
import '../ads/screens/watch_and_earn_screen.dart';

class PremiumOfferScreen extends StatefulWidget {
  const PremiumOfferScreen({super.key});

  @override
  State<PremiumOfferScreen> createState() => _PremiumOfferScreenState();
}

class _PremiumOfferScreenState extends State<PremiumOfferScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.85);
  int _currentPage = 0;

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
                    AppColors.vibrantGold.withOpacity(0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          
          SafeArea(
            child: Consumer<SubscriptionProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                }

                return Column(
                  children: [
                    // Top Bar
                    _buildHeader(context, provider),

                    // Promo Banner
                    _buildPromoBanner(),

                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        onPageChanged: (index) => setState(() => _currentPage = index),
                        children: [
                          _buildPlanCard(
                            title: 'GOLD',
                            color: AppColors.primary,
                            icon: Icons.star_rounded,
                            features: TierLimits.getFeaturesFor('gold'),
                            products: provider.products.where((p) => p.id.contains('gold')).toList(),
                            provider: provider,
                          ),
                          _buildPlanCard(
                            title: 'PLATINUM',
                            color: const Color(0xFFE5E4E2), // Platinum silver
                            icon: Icons.workspace_premium_rounded,
                            features: TierLimits.getFeaturesFor('platinum'),
                            products: provider.products.where((p) => p.id.contains('platinum')).toList(),
                            provider: provider,
                          ),
                        ],
                      ),
                    ),

                    // Page Indicator
                    _buildIndicator(),

                    // İzle & Kazan butonu (Freemium için)
                    Consumer<SubscriptionProvider>(
                      builder: (context, sub, _) {
                        if (sub.currentTier != 'free') return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: GestureDetector(
                            onTap: () => Navigator.push(
                              context, 
                              MaterialPageRoute(builder: (_) => const WatchAndEarnScreen()),
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFF6C63FF),
                                    const Color(0xFF6C63FF).withOpacity(0.7),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.play_circle_filled_rounded, color: Colors.white, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'REKLAM İZLE & KREDİ KAZAN',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),

                    // Restore Button
                    TextButton(
                      onPressed: () => provider.restorePurchases(),
                      child: Text(
                        'SATIN ALIMLARI GERİ YÜKLE',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: Colors.white38,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, SubscriptionProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: Colors.white70),
          ),
          Row(
            children: [
              // Mevcut Plan Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.wallet, color: AppColors.primary, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      TierLimits.getTierDisplayName(provider.currentTier),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Kredi Bakiye Badge
              Consumer<CreditProvider>(
                builder: (context, credit, _) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: AppColors.goldGradient,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.monetization_on_rounded, color: Colors.black, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${credit.balance}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPromoBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      padding: const EdgeInsets.symmetric(vertical: 10),
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.7)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          '🔥 İLK AY %50 İNDİRİM FIRSATI!',
          style: GoogleFonts.plusJakartaSans(
            color: Colors.black,
            fontWeight: FontWeight.w900,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildPlanCard({
    required String title,
    required Color color,
    required IconData icon,
    required List<String> features,
    required List<ProductDetails> products,
    required SubscriptionProvider provider,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 32),
          Icon(icon, color: color, size: 48),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: color,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              itemCount: features.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_rounded, color: color, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          features[index],
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          
          // Pricing Options
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: products.map((p) => _buildPriceButton(p, color, provider)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceButton(ProductDetails product, Color color, SubscriptionProvider provider) {
    String period = 'Ay';
    if (product.id.contains('3')) period = '3 Ay';
    if (product.id.contains('6')) period = '6 Ay';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () => provider.buyProduct(product),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                period,
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                product.price,
                style: GoogleFonts.plusJakartaSans(
                  color: color,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(2, (index) {
          return Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _currentPage == index ? AppColors.primary : Colors.white12,
            ),
          );
        }),
      ),
    );
  }
}
