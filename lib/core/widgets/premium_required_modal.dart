import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../../features/payment/premium_offer_screen.dart';

class PremiumRequiredModal extends StatelessWidget {
  final String featureName;
  final String requiredTier; // 'gold' or 'platinum'

  const PremiumRequiredModal({
    super.key,
    required this.featureName,
    this.requiredTier = 'gold',
  });

  static void show(BuildContext context, {required String featureName, String requiredTier = 'gold'}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => PremiumRequiredModal(
        featureName: featureName,
        requiredTier: requiredTier,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPlatinum = requiredTier == 'platinum';
    final color = isPlatinum ? const Color(0xFFE5E4E2) : AppColors.primary;

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
          const SizedBox(height: 32),
          _buildBenefitRow(Icons.check_circle_rounded, 'Daha fazla eşleşme şansı', color),
          _buildBenefitRow(Icons.check_circle_rounded, 'Öncelikli görünürlük', color),
          _buildBenefitRow(Icons.check_circle_rounded, 'Sınırları kaldır', color),
          const SizedBox(height: 32),
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
