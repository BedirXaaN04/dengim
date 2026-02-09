import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../auth/services/auth_service.dart';
import '../auth/login_screen.dart';
import 'settings_screen.dart';
import 'edit_profile_screen.dart';

import 'package:provider/provider.dart';
import '../../core/providers/user_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';


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
                    // Soft Fade Gradient
                    Container(
                      height: 560,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            AppColors.scaffold.withOpacity(0.0),
                            AppColors.scaffold.withOpacity(0.6),
                            AppColors.scaffold,
                          ],
                          stops: const [0.0, 0.4, 0.7, 1.0],
                        ),
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '$name, $age',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 32,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Icon(Icons.verified, color: AppColors.primary, size: 24),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.white54, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            location,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              color: Colors.white54,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),
                      // Profile Completion Indicator
                      _buildProfileCompletionCard(profile),
                      
                      const SizedBox(height: 40),
                      _buildSectionTitle('HAKKINDA'),
                      const SizedBox(height: 12),
                      Text(
                        bio,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w300,
                          height: 1.6,
                        ),
                      ),

                      const SizedBox(height: 40),
                      _buildSectionTitle('DETAYLAR'),
                      const SizedBox(height: 8),
                      _buildDetailRow('Meslek', job),
                      _buildDetailRow('Eğitim', education),
                      _buildDetailRow('İlgi Alanları', interests, isLast: true),

                      const SizedBox(height: 48),
                      // Buttons
                      _buildActionBtn(
                        icon: Icons.share_outlined,
                        label: 'Profili Paylaş',
                        onTap: () {
                          if (profile != null) {
                            Share.share('DENGİM uygulamasında beni bul! Kullanıcı Adım: ${profile.name} \n\nHemen indir: https://dengimapp.com');
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildActionBtn(
                        icon: Icons.logout,
                        label: 'Çıkış Yap',
                        color: Colors.redAccent.withOpacity(0.1),
                        textColor: Colors.redAccent.withOpacity(0.8),
                        borderColor: Colors.redAccent.withOpacity(0.1),
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
                      const SizedBox(height: 120), // Bottom nav space
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
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.2),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Icon(icon, color: Colors.white.withOpacity(0.9), size: 20),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 10,
        fontWeight: FontWeight.bold,
        color: Colors.white.withOpacity(0.4),
        letterSpacing: 3.0,
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isLast = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        border: isLast ? null : Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 14, color: Colors.white54, fontWeight: FontWeight.w300)),
          Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 14, color: Colors.white, fontWeight: FontWeight.normal)),
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
          color: color ?? Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor ?? Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: textColor ?? Colors.white.withOpacity(0.9)),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: textColor ?? Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Profile Completion Calculator
  int _calculateCompletionPercentage(dynamic profile) {
    if (profile == null) return 0;
    
    int completed = 0;
    int total = 8;
    
    if (profile.name?.isNotEmpty ?? false) completed++;
    if ((profile.photoUrls?.length ?? 0) >= 3) completed++; // Has 3+ photos
    if (profile.bio?.isNotEmpty ?? false) completed++;
    if (profile.job?.isNotEmpty ?? false) completed++;
    if (profile.education?.isNotEmpty ?? false) completed++;
    if ((profile.interests?.length ?? 0) >= 3) completed++; // Has 3+ interests
    if (profile.relationshipGoal != null) completed++;
    if (profile.country?.isNotEmpty ?? false) completed++;
    
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
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withOpacity(0.2),
              AppColors.primary.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.verified, color: Colors.black, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Profilin tamamen dolu ve keşfedilmeye hazır!',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: Colors.white70,
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
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'PROFİL TAMAMLANMA',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white54,
                  letterSpacing: 2.0,
                ),
              ),
              Text(
                '%$percentage',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: percentage / 100,
              minHeight: 8,
              backgroundColor: Colors.white.withOpacity(0.1),
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  message,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  if (profile != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditProfileScreen(profile: profile),
                      ),
                    );
                  }
                },
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                ),
                child: Text(
                  'Tamamla',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
