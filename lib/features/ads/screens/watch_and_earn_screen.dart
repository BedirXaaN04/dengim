import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/credit_provider.dart';
import '../../../core/providers/subscription_provider.dart';
import '../../../core/services/credit_service.dart';
import '../services/ad_service.dart';

/// İzle & Kazan Ekranı
/// Kullanıcılar reklam izleyerek kredi kazanabilir
class WatchAndEarnScreen extends StatefulWidget {
  const WatchAndEarnScreen({super.key});

  @override
  State<WatchAndEarnScreen> createState() => _WatchAndEarnScreenState();
}

class _WatchAndEarnScreenState extends State<WatchAndEarnScreen>
    with SingleTickerProviderStateMixin {
  bool _isAdLoading = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _watchAd() {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reklamlar sadece mobilde gösterilir.')),
      );
      return;
    }

    final creditProvider = context.read<CreditProvider>();
    if (!creditProvider.canWatchAd) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Günlük reklam limitine ulaştın! Yarın tekrar gel. 🎬',
            style: GoogleFonts.plusJakartaSans(),
          ),
          backgroundColor: Colors.orange.shade800,
        ),
      );
      return;
    }

    setState(() => _isAdLoading = true);
    
    final tier = context.read<SubscriptionProvider>().currentTier;
    
    AdService().showRewardedAd(
      tier: tier,
      onReward: (amount) async {
        final success = await creditProvider.rewardAdWatch();
        if (mounted) {
          setState(() => _isAdLoading = false);
          if (success) {
            _showRewardDialog();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Ödül verilemedi. Tekrar dene.')),
            );
          }
        }
      },
    );

    // Reklam yüklenemezse 5 sn sonra loading'i kapat
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && _isAdLoading) {
        setState(() => _isAdLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Reklam yüklenemedi. Biraz sonra tekrar dene.',
              style: GoogleFonts.plusJakartaSans(),
            ),
          ),
        );
      }
    });
  }

  void _showRewardDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.2),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppColors.goldGradient,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.monetization_on_rounded, 
                    color: Colors.black, size: 48),
              ),
              const SizedBox(height: 24),
              Text(
                'KREDİ KAZANDIN! 🎉',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '+${CreditService.rewardWatchAd} Kredi',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Kredilerini super like, boost ve daha fazlası için kullanabilirsin!',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: Colors.white54,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'HARIKA!',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: Stack(
        children: [
          // Background Glow
          Positioned(
            top: -100,
            right: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -120,
            left: -100,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF6C63FF).withOpacity(0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Consumer<CreditProvider>(
              builder: (context, creditProvider, _) {
                return Column(
                  children: [
                    _buildAppBar(creditProvider),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            // Kredi Bakiye Kartı
                            _buildBalanceCard(creditProvider),
                            const SizedBox(height: 24),

                            // İzle & Kazan Butonu
                            _buildWatchButton(creditProvider),
                            const SizedBox(height: 24),

                            // Günlük Giriş Ödülü
                            _buildDailyRewardCard(creditProvider),
                            const SizedBox(height: 24),

                            // Kredi Harcama Seçenekleri
                            _buildSpendingSection(),
                            const SizedBox(height: 24),

                            // Kazanım Yolları
                            _buildEarningWays(),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(CreditProvider creditProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white70),
          ),
          Expanded(
            child: Text(
              'İzle & Kazan',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          // Bakiye badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              gradient: AppColors.goldGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.monetization_on_rounded, 
                    color: Colors.black, size: 18),
                const SizedBox(width: 6),
                Text(
                  '${creditProvider.balance}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(CreditProvider creditProvider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1E1E1E),
            const Color(0xFF252525),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'KREDİ BAKİYEN',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white38,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Icon(Icons.monetization_on_rounded,
                  color: AppColors.primary, size: 36),
              const SizedBox(width: 12),
              Text(
                '${creditProvider.balance}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.local_fire_department, 
                    color: creditProvider.streak > 0 ? Colors.orange : Colors.white24, 
                    size: 18),
                const SizedBox(width: 6),
                Text(
                  '${creditProvider.streak} gün streak 🔥',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: Colors.white54,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWatchButton(CreditProvider creditProvider) {
    final canWatch = creditProvider.canWatchAd;
    
    return ScaleTransition(
      scale: canWatch ? _pulseAnimation : const AlwaysStoppedAnimation(1.0),
      child: GestureDetector(
        onTap: canWatch && !_isAdLoading ? _watchAd : null,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: canWatch 
                ? LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.8),
                    ],
                  )
                : null,
            color: canWatch ? null : const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(24),
            boxShadow: canWatch ? [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ] : null,
          ),
          child: Column(
            children: [
              _isAdLoading
                  ? const SizedBox(
                      width: 48, height: 48,
                      child: CircularProgressIndicator(
                        color: Colors.black, strokeWidth: 3),
                    )
                  : Icon(
                      canWatch ? Icons.play_circle_filled_rounded : Icons.lock_clock,
                      size: 48,
                      color: canWatch ? Colors.black : Colors.white24,
                    ),
              const SizedBox(height: 12),
              Text(
                canWatch ? 'REKLAM İZLE' : 'BUGÜNLÜK LİMİTE ULAŞTIN',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: canWatch ? Colors.black : Colors.white38,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                canWatch 
                    ? '+${CreditService.rewardWatchAd} Kredi Kazan!'
                    : 'Yarın tekrar gel!',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: canWatch ? Colors.black54 : Colors.white24,
                ),
              ),
              const SizedBox(height: 12),
              // İlerleme çubuğu
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: creditProvider.todayAdWatches / CreditService.maxDailyAdWatches,
                  backgroundColor: canWatch 
                      ? Colors.black.withOpacity(0.15) 
                      : Colors.white.withOpacity(0.05),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    canWatch ? Colors.black.withOpacity(0.4) : AppColors.primary.withOpacity(0.3),
                  ),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${creditProvider.todayAdWatches}/${CreditService.maxDailyAdWatches} reklam izlendi',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: canWatch ? Colors.black54 : Colors.white24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDailyRewardCard(CreditProvider creditProvider) {
    final claimed = creditProvider.dailyRewardClaimed;

    return GestureDetector(
      onTap: claimed ? null : () async {
        final success = await creditProvider.claimDailyReward();
        if (mounted && success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '🎁 Günlük giriş ödülün alındı! +${CreditService.rewardDailyLogin} Kredi',
                style: GoogleFonts.plusJakartaSans(),
              ),
              backgroundColor: Colors.green.shade800,
            ),
          );
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: claimed ? Colors.green.withOpacity(0.3) : const Color(0xFF6C63FF).withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: claimed 
                    ? Colors.green.withOpacity(0.15) 
                    : const Color(0xFF6C63FF).withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                claimed ? Icons.check_circle_rounded : Icons.calendar_today_rounded,
                color: claimed ? Colors.green : const Color(0xFF6C63FF),
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'GÜNLÜK GİRİŞ ÖDÜLÜ',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    claimed 
                        ? '✅ Bugünkü ödül alındı!'
                        : '+${CreditService.rewardDailyLogin} Kredi • Tıkla ve al!',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: claimed ? Colors.green.shade300 : Colors.white54,
                    ),
                  ),
                ],
              ),
            ),
            if (!claimed)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF6C63FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'AL',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpendingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'KREDİ HARCA',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: Colors.white38,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        _buildSpendItem(
          icon: Icons.star_rounded,
          title: 'Super Like',
          subtitle: 'Dikkatini hemen çek!',
          cost: CreditService.costSuperLike,
          color: const Color(0xFF00BFFF),
        ),
        _buildSpendItem(
          icon: Icons.rocket_launch_rounded,
          title: 'Boost',
          subtitle: '30 dakika herkesin önünde görün!',
          cost: CreditService.costBoost,
          color: const Color(0xFFFF6B6B),
        ),
        _buildSpendItem(
          icon: Icons.visibility_rounded,
          title: 'Beğenenleri Gör',
          subtitle: 'Seni kimlerin beğendiğini öğren!',
          cost: CreditService.costSeeWhoLikedYou,
          color: const Color(0xFFFFD700),
        ),
        _buildSpendItem(
          icon: Icons.replay_rounded,
          title: 'Geri Al',
          subtitle: 'Son kaydırmayı geri al!',
          cost: CreditService.costUndoSwipe,
          color: const Color(0xFF9B59B6),
        ),
        _buildSpendItem(
          icon: Icons.swipe_rounded,
          title: '+10 Ekstra Beğenme',
          subtitle: 'Daha fazla beğen, daha fazla eşleş!',
          cost: CreditService.costExtraSwipes10,
          color: Colors.teal,
        ),
      ],
    );
  }

  Widget _buildSpendItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required int cost,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: Colors.white38,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.monetization_on_rounded, 
                    color: AppColors.primary, size: 16),
                const SizedBox(width: 4),
                Text(
                  '$cost',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEarningWays() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'KREDİ KAZANMA YOLLARI',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: Colors.white38,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        _buildEarnItem('🎬', 'Reklam İzle', '+${CreditService.rewardWatchAd} / reklam', 'Günde ${CreditService.maxDailyAdWatches} kez'),
        _buildEarnItem('📅', 'Günlük Giriş', '+${CreditService.rewardDailyLogin} / gün', 'Her gün gir, streak kazan'),
        _buildEarnItem('🔥', '7 Gün Streak', '+${CreditService.rewardStreakBonus} bonus', 'Arka arkaya 7 gün boyunca'),
        _buildEarnItem('📸', 'Profil Tamamla', '+${CreditService.rewardProfileComplete}', 'Bio + 3 fotoğraf ekle'),
        _buildEarnItem('💕', 'İlk Eşleşme', '+${CreditService.rewardFirstMatch}', 'Tek seferlik ödül'),
        _buildEarnItem('👥', 'Arkadaş Davet', '+${CreditService.rewardInviteFriend}', 'Her davet başına'),
      ],
    );
  }

  Widget _buildEarnItem(String emoji, String title, String reward, String description) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  description,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: Colors.white38,
                  ),
                ),
              ],
            ),
          ),
          Text(
            reward,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
