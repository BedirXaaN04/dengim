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

/// İzle & Kazan Ekranı - Neo-Brutalist Design
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
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
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
        SnackBar(
          content: Text(
            'REKLAMLAR SADECE MOBİLDE GÖSTERİLİR.',
            style: GoogleFonts.outfit(fontWeight: FontWeight.w800, color: Colors.black),
          ),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final creditProvider = context.read<CreditProvider>();
    if (!creditProvider.canWatchAd) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'GÜNLÜK REKLAM LİMİTİNE ULAŞTIN! YARIN TEKRAR GEL. 🎬',
            style: GoogleFonts.outfit(fontWeight: FontWeight.w800, color: Colors.white),
          ),
          backgroundColor: Colors.black,
          behavior: SnackBarBehavior.floating,
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
              SnackBar(
                content: Text('ÖDÜL VERİLEMEDİ. TEKRAR DENE.', style: GoogleFonts.outfit(fontWeight: FontWeight.w800, color: Colors.white)),
                backgroundColor: AppColors.error,
              ),
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
              'REKLAM YÜKLENEMEDİ. BİRAZ SONRA TEKRAR DENE.',
              style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w800),
            ),
            backgroundColor: AppColors.error,
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
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.black, width: 4),
            boxShadow: const [
              BoxShadow(
                color: Colors.black,
                offset: Offset(8, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black, width: 4),
                  boxShadow: const [
                    BoxShadow(color: Colors.black, offset: Offset(4, 4)),
                  ],
                ),
                child: const Icon(Icons.monetization_on_rounded, 
                    color: Colors.black, size: 48),
              ),
              const SizedBox(height: 32),
              Text(
                'KREDİ KAZANDIN! 🎉',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.green,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.black, width: 3),
                  boxShadow: const [
                    BoxShadow(color: Colors.black, offset: Offset(4, 4)),
                  ],
                ),
                child: Text(
                  '+${CreditService.rewardWatchAd} KREDİ',
                  style: GoogleFonts.outfit(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Kredilerini super like, boost ve daha fazlası için kullanabilirsin!',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 32),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: double.infinity,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.black, width: 4),
                    boxShadow: const [
                      BoxShadow(color: Colors.black, offset: Offset(4, 4)),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'HARİKA!',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                        color: Colors.black,
                        letterSpacing: 1.0,
                      ),
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
        ),
        title: Text(
          'İZLE & KAZAN',
          style: GoogleFonts.outfit(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: Colors.black,
            letterSpacing: -1,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: Container(color: Colors.black, height: 4),
        ),
        actions: [
          Consumer<CreditProvider>(
            builder: (context, creditProvider, _) {
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black, width: 2),
                      boxShadow: const [
                        BoxShadow(color: Colors.black, offset: Offset(2, 2)),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.monetization_on_rounded, 
                            color: Colors.black, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          '${creditProvider.balance}',
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Consumer<CreditProvider>(
          builder: (context, creditProvider, _) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Kredi Bakiye Kartı
                  _buildBalanceCard(creditProvider),
                  const SizedBox(height: 32),

                  // İzle & Kazan Butonu
                  _buildWatchButton(creditProvider),
                  const SizedBox(height: 32),

                  // Günlük Giriş Ödülü
                  _buildDailyRewardCard(creditProvider),
                  const SizedBox(height: 32),

                  // Kredi Harcama Seçenekleri
                  _buildSpendingSection(),
                  const SizedBox(height: 32),

                  // Kazanım Yolları
                  _buildEarningWays(),
                  const SizedBox(height: 40),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBalanceCard(CreditProvider creditProvider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black, width: 4),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            offset: Offset(6, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'KREDİ BAKİYEN',
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: Colors.black,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Icon(Icons.monetization_on_rounded,
                  color: Colors.black, size: 48),
              const SizedBox(width: 12),
              Text(
                '${creditProvider.balance}',
                style: GoogleFonts.outfit(
                  fontSize: 64,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                  height: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black, width: 3),
              boxShadow: const [
                BoxShadow(color: Colors.black, offset: Offset(2, 2)),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.local_fire_department, 
                    color: creditProvider.streak > 0 ? Colors.orange : Colors.grey, 
                    size: 24),
                const SizedBox(width: 8),
                Text(
                  '${creditProvider.streak} GÜN STREAK 🔥',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    color: Colors.black,
                    fontWeight: FontWeight.w900,
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
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: canWatch ? AppColors.primary : Colors.grey.shade400,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.black, width: 4),
            boxShadow: [
              BoxShadow(
                color: Colors.black,
                offset: const Offset(6, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              _isAdLoading
                  ? const SizedBox(
                      width: 56, height: 56,
                      child: CircularProgressIndicator(
                        color: Colors.black, strokeWidth: 5),
                    )
                  : Icon(
                      canWatch ? Icons.play_circle_filled_rounded : Icons.lock_clock,
                      size: 64,
                      color: Colors.black,
                    ),
              const SizedBox(height: 16),
              Text(
                canWatch ? 'REKLAM İZLE' : 'LİMİT DOLDU',
                style: GoogleFonts.outfit(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                canWatch 
                    ? '+${CreditService.rewardWatchAd} KREDİ KAZAN!'
                    : 'YARIN TEKRAR GEL!',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  color: Colors.black87,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 24),
              // İlerleme çubuğu
              Container(
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black, width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: creditProvider.todayAdWatches / CreditService.maxDailyAdWatches,
                    backgroundColor: Colors.transparent,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.black),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '${creditProvider.todayAdWatches}/${CreditService.maxDailyAdWatches} REKLAM İZLENDİ',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: Colors.black87,
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
                '🎁 GÜNLÜK ÖDÜLÜN ALINDI! +${CreditService.rewardDailyLogin} KREDİ',
                style: GoogleFonts.outfit(fontWeight: FontWeight.w800, color: Colors.black),
              ),
              backgroundColor: AppColors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: claimed ? Colors.grey.shade300 : AppColors.green,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black, width: 4),
          boxShadow: [
            BoxShadow(
              color: Colors.black,
              offset: claimed ? const Offset(2, 2) : const Offset(6, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black, width: 3),
                boxShadow: const [
                  BoxShadow(color: Colors.black, offset: Offset(2, 2)),
                ],
              ),
              child: Icon(
                claimed ? Icons.check_circle_rounded : Icons.calendar_today_rounded,
                color: Colors.black,
                size: 32,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'GÜNLÜK GİRİŞ',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    claimed 
                        ? 'BUGÜNLÜK ALINDI ✅'
                        : '+${CreditService.rewardDailyLogin} KREDİ • TIKLA AL',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            if (!claimed)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black, width: 3),
                  boxShadow: const [
                    BoxShadow(color: Colors.black, offset: Offset(2, 2)),
                  ],
                ),
                child: Text(
                  'AL',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
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
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: Colors.black,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 16),
        _buildSpendItem(
          icon: Icons.star_rounded,
          title: 'SUPER LİKE',
          subtitle: 'DİKKATİNİ HEMEN ÇEK!',
          cost: CreditService.costSuperLike,
          color: AppColors.blue,
        ),
        _buildSpendItem(
          icon: Icons.rocket_launch_rounded,
          title: 'BOOST',
          subtitle: '30 DAKİKA ÖNE ÇIK!',
          cost: CreditService.costBoost,
          color: AppColors.primary,
        ),
        _buildSpendItem(
          icon: Icons.visibility_rounded,
          title: 'BEĞENENLERİ GÖR',
          subtitle: 'KİMLERİN BEĞENDİĞİNİ ÖĞREN!',
          cost: CreditService.costSeeWhoLikedYou,
          color: AppColors.green,
        ),
        _buildSpendItem(
          icon: Icons.replay_rounded,
          title: 'GERİ AL',
          subtitle: 'SON KAYDIRMAYI GERİ AL!',
          cost: CreditService.costUndoSwipe,
          color: AppColors.secondary,
        ),
        _buildSpendItem(
          icon: Icons.swipe_rounded,
          title: '+10 EKSTRA BEĞENME',
          subtitle: 'DAHA FAZLA EŞLEŞ!',
          cost: CreditService.costExtraSwipes10,
          color: AppColors.red,
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
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black, width: 3),
        boxShadow: const [
          BoxShadow(color: Colors.black, offset: Offset(4, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black, width: 3),
            ),
            child: Icon(icon, color: Colors.black, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black, width: 3),
              boxShadow: const [
                BoxShadow(color: Colors.black, offset: Offset(2, 2)),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.monetization_on_rounded, 
                    color: Colors.black, size: 18),
                const SizedBox(width: 6),
                Text(
                  '$cost',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
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

  Widget _buildEarningWays() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'KREDİ KAZANMA YOLLARI',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: Colors.black,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 16),
        _buildEarnItem('🎬', 'REKLAM İZLE', '+${CreditService.rewardWatchAd}', 'GÜNDE ${CreditService.maxDailyAdWatches} KEZ'),
        _buildEarnItem('📅', 'GÜNLÜK GİRİŞ', '+${CreditService.rewardDailyLogin}', 'HER GÜN GİR, STREAK KAZAN'),
        _buildEarnItem('🔥', '7 GÜN STREAK', '+${CreditService.rewardStreakBonus}', 'ARKA ARKAYA 7 GÜN BOYUNCA'),
        _buildEarnItem('📸', 'PROFİL TAMAMLA', '+${CreditService.rewardProfileComplete}', 'BİO + 3 FOTOĞRAF EKLE'),
        _buildEarnItem('💕', 'İLK EŞLEŞME', '+${CreditService.rewardFirstMatch}', 'TEK SEFERLİK ÖDÜL'),
        _buildEarnItem('👥', 'ARKADAŞ DAVET', '+${CreditService.rewardInviteFriend}', 'HER DAVET BAŞINA'),
      ],
    );
  }

  Widget _buildEarnItem(String emoji, String title, String reward, String description) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black, width: 3),
        boxShadow: const [
          BoxShadow(color: Colors.black, offset: Offset(4, 4)),
        ],
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.green,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.black, width: 2),
                      ),
                      child: Text(
                        reward,
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
