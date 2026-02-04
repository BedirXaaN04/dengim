import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../auth/services/auth_service.dart';
import '../auth/login_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "AYARLAR",
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader("HESAP"),
            _buildSettingItem(context, "E-posta Adresi", Icons.email_outlined, trailing: "user@example.com"),
            _buildSettingItem(context, "Telefon Numarası", Icons.phone_outlined),
            _buildSettingItem(context, "Şifre ve Güvenlik", Icons.lock_outline),
            
            const SizedBox(height: 32),
            _buildSectionHeader("UYGULAMA"),
            _buildSettingItem(context, "Bildirimler", Icons.notifications_none),
            _buildSettingItem(context, "Gizlilik ve Güvenlik", Icons.privacy_tip_outlined),
            _buildSettingItem(context, "Dil Seçeneği", Icons.language, trailing: "Türkçe"),
            
            const SizedBox(height: 32),
            _buildSectionHeader("HUKUKİ"),
            _buildSettingItem(context, "Kullanım Koşulları", Icons.description_outlined),
            _buildSettingItem(context, "Gizlilik Politikası", Icons.policy_outlined),
            
            const SizedBox(height: 48),
            
            // Delete Account Button
            GestureDetector(
              onTap: () => _showDeleteConfirmation(context),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.error.withOpacity(0.2)),
                ),
                child: Center(
                  child: Text(
                    "HESABIMI SİL",
                    style: GoogleFonts.plusJakartaSans(
                      color: AppColors.error,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
             Center(
              child: Text(
                "v1.0.0 (Build 100)",
                style: GoogleFonts.plusJakartaSans(color: Colors.white24, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildSettingItem(BuildContext context, String title, IconData icon, {String? trailing}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 14),
            ),
          ),
          if (trailing != null)
            Text(
              trailing,
              style: GoogleFonts.plusJakartaSans(color: Colors.white30, fontSize: 12),
            )
          else
            const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 14),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F2937),
        title: const Text("Hesabını Sil?", style: TextStyle(color: Colors.white)),
        content: const Text(
          "Bu işlem geri alınamaz. Profilin, eşleşmelerin ve mesajların kalıcı olarak silinecektir.",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            child: const Text("İptal", style: TextStyle(color: Colors.white54)),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text("Evet, Sil", style: TextStyle(color: AppColors.error)),
            onPressed: () async {
              Navigator.pop(context); // Dialog kapa
              await _deleteAccount(context);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount(BuildContext context) async {
    // Loading gösterilebilir
    try {
      await AuthService().deleteAccount();
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (c) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Hata: $e")),
        );
      }
    }
  }
}
