import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_colors.dart';
import '../auth/services/auth_service.dart';
import '../auth/login_screen.dart';
import '../auth/models/user_profile.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;
  UserProfile? _userProfile;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final authService = AuthService();
      final userProfile = await authService.getUserProfile();
      if (mounted) {
        setState(() {
          _userProfile = userProfile;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.scaffold,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    final name = _userProfile?.name ?? 'Kullanıcı';
    final age = _userProfile?.age ?? 18;
    final photoUrl = (_userProfile?.photoUrls != null && _userProfile!.photoUrls!.isNotEmpty)
        ? _userProfile!.photoUrls!.first
        : 'https://images.unsplash.com/photo-1511367461989-f85a21fda167?w=500';
    final location = _userProfile?.country ?? 'Konum Belirtilmedi';
    final bio = _userProfile?.bio ?? 'Henüz bir biyografi eklenmemiş.';
    final job = _userProfile?.job ?? 'Belirtilmedi';
    final education = _userProfile?.education ?? 'Belirtilmedi';
    final interests = _userProfile?.interests.join(', ') ?? 'Belirtilmedi';

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Image with Soft Fade
            Stack(
              children: [
                Container(
                  height: 560,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(photoUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
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
                        _buildCircleIcon(Icons.edit),
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
                    onTap: () {},
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
}
