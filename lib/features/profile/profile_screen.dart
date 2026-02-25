import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../auth/services/auth_service.dart';
import '../auth/login_screen.dart';
import 'settings_screen.dart';
import 'edit_profile_screen.dart';
import 'visitors_screen.dart';

import 'package:provider/provider.dart';
import '../../core/providers/user_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import 'widgets/video_player_modal.dart';
import '../../core/providers/credit_provider.dart';
import '../../core/providers/subscription_provider.dart';
import '../payment/premium_offer_screen.dart';
import '../ads/screens/watch_and_earn_screen.dart';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Sayfa açıldığında veri yoksa yükle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      if (userProvider.currentUser == null) {
        userProvider.loadCurrentUser();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final profile = userProvider.currentUser;

        if (userProvider.isLoading && profile == null) {
          return const Scaffold(
            backgroundColor: AppColors.scaffold,
            body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
          );
        }

        final name = profile?.name ?? 'Kullanıcı';
        final age = profile?.age ?? 18;
        final photoUrl = (profile?.photoUrls != null && profile!.photoUrls!.isNotEmpty)
            ? profile!.photoUrls!.first
            : 'https://images.unsplash.com/photo-1511367461989-f85a21fda167?w=500';
        final location = profile?.country ?? 'Konum Belirtilmedi';
        final bio = profile?.bio ?? 'Henüz bir biyografi eklenmemiş.';
        final job = profile?.job ?? 'Belirtilmedi';
        final education = profile?.education ?? 'Belirtilmedi';
        final interests = profile?.interests.join(', ') ?? 'Belirtilmedi';


        return Scaffold(
          backgroundColor: AppColors.scaffold,
          body: SingleChildScrollView(
            child: Column(
              children: [
                // Header Image with Soft Fade
                Stack(
                  children: [
                    CachedNetworkImage(
                      imageUrl: photoUrl,
                      height: 560,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(color: AppColors.surface),
                      errorWidget: (context, url, error) => const Icon(Icons.error),
                    ),
                    // Header Border
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 4,
                        color: Colors.black,
                      ),
                    ),
                    // Buttons at Top
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildCircleIcon(
                              Icons.settings,
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
                            ),
                            _buildCircleIcon(
                              Icons.edit,
                              onTap: () {
                                if (profile != null) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => EditProfileScreen(profile: profile),
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // Profile Info
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '$name, $age'.toUpperCase(),
                            style: GoogleFonts.outfit(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: Colors.black,
                              letterSpacing: -1.0,
                            ),
                          ),
                          const SizedBox(width: 12),
                          if (profile?.isVerified == true)
                            const Padding(
                              padding: EdgeInsets.only(top: 4),
                              child: Icon(Icons.verified, color: AppColors.primary, size: 28),
                            ),
                          if (profile?.isPremium == true) ...[
                            const SizedBox(width: 8),
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: _buildPremiumBadge(profile?.subscriptionTier ?? 'gold'),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.black, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            location.toUpperCase(),
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              color: Colors.black.withOpacity(0.6),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),
                      _buildProfileCompletionCard(profile),
                      
                      const SizedBox(height: 40),
                      _buildSectionHeader('HAKKINDA'),
                      _buildBioCard(bio),

                      const SizedBox(height: 40),
                      _buildSectionHeader('DETAYLAR'),
                      _buildDetailsCard(job, education, interests),

                      if (profile?.videoUrl != null) ...[
                        const SizedBox(height: 40),
                        _buildSectionHeader('VİDEO PROFİL'),
                        _buildVideoPreview(profile!.videoUrl!),
                      ],

                      const SizedBox(height: 48),

                      _buildCreditAndTierCard(profile),
                      const SizedBox(height: 24),

                      _buildActionBtn(
                        icon: Icons.visibility_outlined,
                        label: 'PROFİL ZİYARETÇİLERİ',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const VisitorsScreen()),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildActionBtn(
                        icon: Icons.share_outlined,
                        label: 'PROFİLİ PAYLAŞ',
                        onTap: () {
                          if (profile != null) {
                            Share.share('DENGİM uygulamasında beni bul! Kullanıcı Adım: ${profile.name} \n\nHemen indir: https://dengimapp.com');
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildActionBtn(
                        icon: Icons.logout,
                        label: 'ÇIKIŞ YAP',
                        color: AppColors.red,
                        textColor: Colors.black,
                        borderColor: Colors.black,
                        onTap: () async {
                          await AuthService().signOut();
                          if (context.mounted) {
                            context.read<UserProvider>().clearUser();
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (c) => const LoginScreen()),
                              (route) => false,
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  Widget _buildCircleIcon(IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black, width: 2),
          boxShadow: const [
            BoxShadow(color: Colors.black, offset: Offset(2, 2)),
          ],
        ),
        child: Icon(icon, color: Colors.black, size: 20),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: GoogleFonts.outfit(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          color: Colors.black,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildBioCard(String bio) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppColors.neoRadius),
        border: Border.all(color: Colors.black, width: AppColors.neoBorderWidthSmall),
        boxShadow: const [
          BoxShadow(color: Colors.black, offset: Offset(4, 4)),
        ],
      ),
      child: Text(
        bio,
        style: GoogleFonts.outfit(
          fontSize: 16,
          color: Colors.black,
          fontWeight: FontWeight.w500,
          height: 1.6,
        ),
      ),
    );
  }

  Widget _buildDetailsCard(String job, String education, String interests) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppColors.neoRadius),
        border: Border.all(color: Colors.black, width: AppColors.neoBorderWidthSmall),
        boxShadow: const [
          BoxShadow(color: Colors.black, offset: Offset(4, 4)),
        ],
      ),
      child: Column(
        children: [
          _buildDetailRow('MESLEK', job),
          _buildDetailRow('EĞİTİM', education),
          _buildDetailRow('İLGİ ALANLARI', interests, isLast: true),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isLast = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        border: isLast ? null : Border(bottom: BorderSide(color: Colors.black.withOpacity(0.1), width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.outfit(fontSize: 14, color: Colors.black.withOpacity(0.5), fontWeight: FontWeight.w800)),
          Text(value, style: GoogleFonts.outfit(fontSize: 14, color: Colors.black, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  Widget _buildActionBtn({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
    Color? textColor,
    Color? borderColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: color ?? Colors.white,
          borderRadius: BorderRadius.circular(AppColors.neoRadiusSmall),
          border: Border.all(color: Colors.black, width: AppColors.neoBorderWidthSmall),
          boxShadow: const [
            BoxShadow(color: Colors.black, offset: Offset(4, 4)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: textColor ?? Colors.black),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: textColor ?? Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPreview(String videoUrl) {
    return GestureDetector(
      onTap: () {
        _showVideoPlayer(videoUrl);
      },
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppColors.neoRadius),
          border: Border.all(color: Colors.black, width: AppColors.neoBorderWidthSmall),
          boxShadow: const [
            BoxShadow(color: Colors.black, offset: Offset(4, 4)),
          ],
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1a1a2e),
              Color(0xFF16213e),
              Color(0xFF0f3460),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 3),
                boxShadow: const [
                  BoxShadow(color: Colors.black, offset: Offset(3, 3)),
                ],
              ),
              child: const Icon(Icons.play_arrow_rounded, color: Colors.black, size: 36),
            ),
            const SizedBox(height: 16),
            Text(
              'VİDEO PROFİLİNİ İZLE',
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showVideoPlayer(String videoUrl) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      builder: (context) => VideoPlayerModal(videoUrl: videoUrl),
    );
  }

  // Profile Completion Calculator
  int _calculateCompletionPercentage(dynamic profile) {
    if (profile == null) return 0;
    
    int completed = 0;
    const int total = 9; // Name, photos, bio, job, education, interests, goal, country, video
    
    if (profile.name?.isNotEmpty ?? false) completed++;
    if ((profile.photoUrls?.length ?? 0) >= 3) completed++; // Has 3+ photos
    if (profile.bio?.isNotEmpty ?? false) completed++;
    if (profile.job?.isNotEmpty ?? false) completed++;
    if (profile.education?.isNotEmpty ?? false) completed++;
    if ((profile.interests?.length ?? 0) >= 3) completed++; // Has 3+ interests
    if (profile.relationshipGoal != null) completed++;
    if (profile.country?.isNotEmpty ?? false) completed++;
    if (profile.videoUrl != null) completed++;

    return ((completed / total) * 100).round();
  }

  String _getCompletionMessage(int percentage) {
    if (percentage == 100) return '🎉 Profilin mükemmel!';
    if (percentage >= 80) return '✨ Neredeyse tamamlandı!';
    if (percentage >= 60) return '👍 İyi gidiyorsun!';
    if (percentage >= 40) return '📝 Devam et!';
    return '🚀 Profilini tamamla!';
  }

  Widget _buildProfileCompletionCard(dynamic profile) {
    final percentage = _calculateCompletionPercentage(profile);
    final message = _getCompletionMessage(percentage);
    
    // Tam profil ise gösterme
    if (percentage == 100) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(16),
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
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 2),
              ),
              child: const Icon(Icons.verified, color: Colors.black, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                    message.toUpperCase(),
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'PROFİLİN TAMAMEN DOLU VE KEŞFEDİLMEYE HAZIR!',
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.black.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
    
    // Eksik profil
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black, width: 3),
        boxShadow: const [
          BoxShadow(color: Colors.black, offset: Offset(4, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'PROFİL TAMAMLANMA',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),
              Text(
                '%$percentage',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.black, width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: percentage / 100,
                minHeight: 12,
                backgroundColor: Colors.transparent,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  message.toUpperCase(),
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    color: Colors.black,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  if (profile != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditProfileScreen(profile: profile),
                      ),
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                  child: Text(
                    'TAMAMLA',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumBadge(String tier) {
    final isPlatinum = tier == 'platinum';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isPlatinum ? Colors.white : AppColors.primary,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black, width: 2),
        boxShadow: const [
          BoxShadow(color: Colors.black, offset: Offset(3, 3)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPlatinum ? Icons.workspace_premium_rounded : Icons.star_rounded,
            color: Colors.black,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            tier.toUpperCase(),
            style: GoogleFonts.outfit(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreditAndTierCard(dynamic profile) {
    return Consumer2<CreditProvider, SubscriptionProvider>(
      builder: (context, creditProvider, subProvider, _) {
        final tier = subProvider.currentTier;
        final isPremium = tier != 'free';

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black, width: 3),
            boxShadow: const [
              BoxShadow(color: Colors.black, offset: Offset(4, 4)),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.black, width: 2),
                          ),
                          child: const Icon(Icons.monetization_on_rounded, color: Colors.black, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${creditProvider.balance}',
                              style: GoogleFonts.outfit(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              'KREDİ',
                              style: GoogleFonts.outfit(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: Colors.black.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (creditProvider.streak > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.orange,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.black, width: 1.5),
                        boxShadow: const [
                          BoxShadow(color: Colors.black, offset: Offset(2, 2)),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.local_fire_department, color: Colors.black, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '${creditProvider.streak}',
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildMiniBtn(
                      icon: Icons.play_circle_filled_rounded,
                      label: 'İZLE & KAZAN',
                      color: const Color(0xFF6C63FF),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const WatchAndEarnScreen()),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMiniBtn(
                      icon: isPremium ? Icons.workspace_premium_rounded : Icons.star_rounded,
                      label: isPremium ? tier.toUpperCase() : 'PREMIUM AL',
                      color: AppColors.primary,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PremiumOfferScreen()),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMiniBtn({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.black, width: 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.black, size: 18),
            const SizedBox(width: 6),
            Text(
              label.toUpperCase(),
              style: GoogleFonts.outfit(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
