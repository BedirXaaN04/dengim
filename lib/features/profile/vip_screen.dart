import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../payment/premium_offer_screen.dart';

class VipScreen extends StatelessWidget {
  const VipScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: CustomScrollView(
        slivers: [
          // Top Bar
          SliverAppBar(
            backgroundColor: AppColors.scaffold.withOpacity(0.8),
            floating: true,
            pinned: true,
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              "DENGIM VIP",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                letterSpacing: 4.0,
                color: Colors.white,
              ),
            ),
          ),

          // 3D Metallic Card Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
              child: _buildMetallicVipCard(),
            ),
          ),

          // Benefits Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "VIP Ayrıcalıkları",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildBenefitItem("Sınırsız Beğeni"),
                  _buildBenefitItem("Seni Kimlerin Beğendiğini Gör"),
                  _buildBenefitItem("Sınırsız Geri Sarma (Rewind)"),
                  _buildBenefitItem("Günde 5 Ücretsiz Öne Çıkarma"),
                ],
              ),
            ),
          ),

          // Pricing Grid
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
              child: Row(
                children: [
                  Expanded(child: _buildPriceCard("1 AY", "₺199", "aylık", false)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildPriceCard("12 AY", "₺125", "aylık", true, savings: "%40 TASARRUF")),
                  const SizedBox(width: 12),
                  Expanded(child: _buildPriceCard("6 AY", "₺149", "aylık", false)),
                ],
              ),
            ),
          ),

          // CTA & Footer
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 64,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFF9D406), Color(0xFFB89B05)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFF9D406).withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const PremiumOfferScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text(
                          "Devam Et",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "Abonelik otomatik olarak yenilenir. İstediğiniz zaman ayarlardan iptal edebilirsiniz.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.3),
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetallicVipCard() {
    return AspectRatio(
      aspectRatio: 1.586,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1E2128), Color(0xFF2C303A)],
          ),
          border: Border.all(color: const Color(0xFFF9D406).withOpacity(0.3), width: 1),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFF9D406).withOpacity(0.1),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "DENGIM PREMIUM",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 3,
                              color: const Color(0xFFF9D406),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "VIP",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 36,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              height: 1,
                            ),
                          ),
                        ],
                      ),
                      const Icon(Icons.workspace_premium_rounded, color: Color(0xFFF9D406), size: 48),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "EXCLUSIVE MEMBERSHIP",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                      Container(
                        width: 48,
                        height: 32,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [const Color(0xFFF9D406).withOpacity(0.4), const Color(0xFFF9D406).withOpacity(0.1)],
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitItem(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFF9D406).withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFF9D406).withOpacity(0.2)),
            ),
            child: const Icon(Icons.check, color: Color(0xFFF9D406), size: 14),
          ),
          const SizedBox(width: 16),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceCard(String duration, String price, String period, bool highlighted, {String? savings}) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: highlighted ? const Color(0xFFF9D406).withOpacity(0.05) : Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: highlighted ? const Color(0xFFF9D406) : Colors.white.withOpacity(0.1),
          width: highlighted ? 1.5 : 1,
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (highlighted)
            Positioned(
              top: -12,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFFF9D406), Color(0xFFB89B05)]),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "EN İYİ DEĞER",
                    style: GoogleFonts.plusJakartaSans(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  duration,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: highlighted ? const Color(0xFFF9D406) : Colors.white.withOpacity(0.6),
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  price,
                  style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white),
                ),
                Text(
                  period,
                  style: GoogleFonts.plusJakartaSans(fontSize: 10, color: Colors.white.withOpacity(0.3)),
                ),
                if (savings != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    savings,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFF9D406).withOpacity(0.8),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
