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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(color: Colors.black, width: 4),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black, width: 2),
              boxShadow: const [
                BoxShadow(color: Colors.black, offset: Offset(4, 4)),
              ],
            ),
            child: Icon(
              isPlatinum ? Icons.workspace_premium_rounded : Icons.star_rounded,
              color: Colors.black,
              size: 48,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            featureName.toUpperCase(),
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Colors.black,
              letterSpacing: -1.0,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'BU ÖZELLİĞİ KULLANMAK İÇİN ${requiredTier.toUpperCase()} ÜYELİĞİNE SAHİP OLMALISIN.',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              color: Colors.black.withOpacity(0.6),
              fontSize: 14,
              fontWeight: FontWeight.w800,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 24),
          
          _buildBenefitRow(Icons.check_circle_outline_rounded, 'DAHA FAZLA EŞLEŞME ŞANSI', Colors.black),
          _buildBenefitRow(Icons.check_circle_outline_rounded, 'ÖNCELİKLİ GÖRÜNÜRLÜK', Colors.black),
          _buildBenefitRow(Icons.check_circle_outline_rounded, 'SINIRLARI KALDIR', Colors.black),
          
          const SizedBox(height: 32),

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
                          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                        ),
                        backgroundColor: AppColors.green,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '❌ Yetersiz kredi. ${creditCost! - creditProvider.balance} kredi daha lazım.',
                          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                        ),
                        backgroundColor: AppColors.red,
                      ),
                    );
                  }
                }
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black, width: 2.5),
                  boxShadow: const [
                    BoxShadow(color: Colors.black, offset: Offset(4, 4)),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.monetization_on_rounded, color: Colors.black, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      '$creditCost KREDİ İLE KULLAN',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
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
                  color: const Color(0xFF6C63FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black, width: 2.5),
                  boxShadow: const [
                    BoxShadow(color: Colors.black, offset: Offset(4, 4)),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.play_circle_filled_rounded, color: Colors.black, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      'REKLAM İZLE & KREDİ KAZAN',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
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
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Colors.black, width: 2.5),
                ),
              ).copyWith(
                overlayColor: WidgetStateProperty.all(Colors.black.withOpacity(0.1)),
              ),
              child: Text(
                'HEMEN YÜKSELT',
                style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.black),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'DAHA SONRA',
              style: GoogleFonts.outfit(color: Colors.black.withOpacity(0.4), fontWeight: FontWeight.w900),
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
          Icon(icon, color: Colors.black, size: 18),
          const SizedBox(width: 8),
          Text(
            text.toUpperCase(),
            style: GoogleFonts.outfit(color: Colors.black, fontSize: 12, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}
