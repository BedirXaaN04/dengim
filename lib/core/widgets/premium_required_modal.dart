import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../providers/credit_provider.dart';
import '../providers/subscription_provider.dart';
import '../constants/tier_limits.dart';
import '../../features/payment/premium_offer_screen.dart';
import '../../features/ads/screens/watch_and_earn_screen.dart';

/// Premium veya Kredi gerektiren özellikler için modal
class PremiumRequiredModal extends StatelessWidget {
  final String featureName;
  final String requiredTier; // 'gold' or 'platinum'
  final int? creditCost; // Kredi ile satın alınabilecek özellikler için

  const PremiumRequiredModal({
    super.key,
    required this.featureName,
    this.requiredTier = 'gold',
    this.creditCost,
  });

  static void show(BuildContext context, {
    required String featureName, 
    String requiredTier = 'gold',
    int? creditCost,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => PremiumRequiredModal(
        featureName: featureName,
        requiredTier: requiredTier,
        creditCost: creditCost,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPlatinum = requiredTier == 'platinum';
    final color = isPlatinum ? const Color(0xFFE5E4E2) : AppColors.primary;
    final creditProvider = context.watch<CreditProvider>();

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPlatinum ? Icons.workspace_premium_rounded : Icons.star_rounded,
              color: color,
              size: 48,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            featureName.toUpperCase(),
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Bu özelliği kullanmak için ${requiredTier.toUpperCase()} üyeliğine sahip olmalısın.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white60,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          
          _buildBenefitRow(Icons.check_circle_rounded, 'Daha fazla eşleşme şansı', color),
          _buildBenefitRow(Icons.check_circle_rounded, 'Öncelikli görünürlük', color),
          _buildBenefitRow(Icons.check_circle_rounded, 'Sınırları kaldır', color),
          
          const SizedBox(height: 24),

          // Kredi ile satın alınabilir
          if (creditCost != null) ...[
            GestureDetector(
              onTap: () async {
                final success = await creditProvider.spend(creditCost!, featureName.toLowerCase());
                if (context.mounted) {
                  if (success) {
                    Navigator.pop(context, true);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '✅ $featureName aktif edildi! (-$creditCost kredi)',
                          style: GoogleFonts.plusJakartaSans(),
                        ),
                        backgroundColor: Colors.green.shade800,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '❌ Yetersiz kredi. ${creditCost! - creditProvider.balance} kredi daha lazım.',
                          style: GoogleFonts.plusJakartaSans(),
                        ),
                        backgroundColor: Colors.red.shade800,
                      ),
                    );
                  }
                }
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.monetization_on_rounded, 
                        color: AppColors.primary, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      '$creditCost Kredi ile Kullan',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Bakiye: ${creditProvider.balance}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            // İzle & Kazan butonu
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const WatchAndEarnScreen()),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF6C63FF),
                      const Color(0xFF6C63FF).withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.play_circle_filled_rounded, 
                        color: Colors.white, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      'Reklam İzle & Kredi Kazan',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            // VEYA ayırıcı
            Row(
              children: [
                Expanded(child: Divider(color: Colors.white10)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'VEYA',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: Colors.white24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(child: Divider(color: Colors.white10)),
              ],
            ),
            const SizedBox(height: 12),
          ],

          // Premium yükselt butonu
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PremiumOfferScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(
                'HEMEN YÜKSELT',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Daha Sonra',
              style: GoogleFonts.plusJakartaSans(color: Colors.white38),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitRow(IconData icon, String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Text(
            text,
            style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
