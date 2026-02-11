import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/error_handler.dart';
import '../auth/services/auth_service.dart';
import '../auth/login_screen.dart';
import 'blocked_users_screen.dart';
import 'package:provider/provider.dart';
import '../../core/providers/user_provider.dart';
import 'verification_screen.dart';
import '../auth/services/profile_service.dart';
import '../payment/premium_offer_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDeleting = false;
  bool _notificationsEnabled = true;

  String get _userEmail => FirebaseAuth.instance.currentUser?.email ?? 'E-posta bağlı değil';

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
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader("HESAP"),
                _buildSettingItem(
                  context, 
                  "E-posta Adresi", 
                  Icons.email_outlined, 
                  trailing: _userEmail,
                  onTap: () => _showInfoDialog("E-posta Adresi", "E-posta adresinizi değiştirmek için çıkış yapıp yeni hesap oluşturmanız gerekmektedir."),
                ),
                _buildSettingItem(
                  context, 
                  "Hesap Doğrulama (Mavi Tik)", 
                  Icons.verified_user_outlined,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const VerificationScreen()),
                  ),
                ),
                _buildSettingItem(
                  context, 
                  "Şifre Değiştir", 
                  Icons.lock_outline,
                  onTap: _showChangePasswordDialog,
                ),
                
                const SizedBox(height: 32),
                _buildSectionHeader("GİZLİLİK"),
                _buildSettingItem(
                  context, 
                  "Engellenen Kullanıcılar", 
                  Icons.block,
                  onTap: () => Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (_) => const BlockedUsersScreen()),
                  ),
                ),
                
                const SizedBox(height: 32),
                _buildSectionHeader("KEŞFET"),
                _buildSettingItem(
                  context, 
                  "Seyahat Modu (Pasaport)", 
                  Icons.public_rounded,
                  trailing: "Mevcut Konumun",
                  onTap: _onPassportTap,
                ),
                
                const SizedBox(height: 32),
                _buildSectionHeader("GİZLİLİK MODLARI (PREMIUM)"),
                Consumer<UserProvider>(
                  builder: (context, provider, _) {
                    final user = provider.currentUser;
                    final isPremium = user?.isPremium ?? false;
                    
                    return Column(
                      children: [
                        _buildSwitchItem(
                          context,
                          "Hayalet Modu",
                          Icons.visibility_off_outlined,
                          user?.isGhostMode ?? false,
                          (value) async {
                            if (!isPremium) {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const PremiumOfferScreen()));
                              return;
                            }
                            await ProfileService().updateProfile(isGhostMode: value);
                          },
                        ),
                        _buildSwitchItem(
                          context,
                          "Gizli Mod (Incognito)",
                          Icons.security_outlined,
                          user?.isIncognitoMode ?? false,
                          (value) async {
                            if (!isPremium) {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const PremiumOfferScreen()));
                              return;
                            }
                            await ProfileService().updateProfile(isIncognitoMode: value);
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            "Hayalet Modu: Çevrimiçi durumunuzu gizler. Gizli Mod: Sadece beğendiğiniz kişiler sizi görebilir.",
                            style: GoogleFonts.plusJakartaSans(fontSize: 11, color: Colors.white24),
                          ),
                        ),
                      ],
                    );
                  }
                ),
                
                const SizedBox(height: 32),
                _buildSectionHeader("UYGULAMA"),
                _buildSwitchItem(
                  context,
                  "Bildirimler",
                  Icons.notifications_none,
                  _notificationsEnabled,
                  (value) {
                    setState(() => _notificationsEnabled = value);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(value ? 'Bildirimler açıldı' : 'Bildirimler kapatıldı'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                ),
                _buildSettingItem(context, "Dil Seçeneği", Icons.language, trailing: "Türkçe"),
                
                const SizedBox(height: 32),
                _buildSectionHeader("HUKUKİ"),
                _buildSettingItem(
                  context, 
                  "Kullanım Koşulları", 
                  Icons.description_outlined,
                  onTap: () => _launchUrl("https://www.dengimapp.com/terms"),
                ),
                _buildSettingItem(
                  context, 
                  "Gizlilik Politikası", 
                  Icons.policy_outlined,
                  onTap: () => _launchUrl("https://www.dengimapp.com/privacy"),
                ),

                const SizedBox(height: 32),
                _buildSectionHeader("DESTEK"),
                _buildSettingItem(
                  context,
                  "Yardım ve Destek",
                  Icons.help_outline,
                  onTap: () => _launchUrl("mailto:destek@dengim.app?subject=Destek Talebi"),
                ),
                _buildSettingItem(
                  context,
                  "Bizi Değerlendir",
                  Icons.star_outline,
                  onTap: () => _showInfoDialog("Değerlendirme", "Uygulama mağazada yayınlandıktan sonra değerlendirme yapabileceksiniz."),
                ),
                
                const SizedBox(height: 48),
                
                // Logout Button
                GestureDetector(
                  onTap: _logout,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Center(
                      child: Text(
                        "ÇIKIŞ YAP",
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white70,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
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
                const SizedBox(height: 32),
              ],
            ),
          ),
          
          // Loading overlay
          if (_isDeleting)
            Container(
              color: Colors.black.withOpacity(0.7),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: AppColors.error),
                    const SizedBox(height: 16),
                    Text(
                      'Hesap siliniyor...',
                      style: GoogleFonts.plusJakartaSans(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
        ],
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

  Widget _buildSettingItem(
    BuildContext context, 
    String title, 
    IconData icon, 
    {String? trailing, VoidCallback? onTap}
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
              Flexible(
                child: Text(
                  trailing,
                  style: GoogleFonts.plusJakartaSans(color: Colors.white30, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              )
            else
              const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchItem(
    BuildContext context,
    String title,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F2937),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        content: Text(message, style: TextStyle(color: Colors.white.withOpacity(0.7))),
        actions: [
          TextButton(
            child: const Text("Tamam", style: TextStyle(color: AppColors.primary)),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F2937),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Şifre Sıfırla", style: TextStyle(color: Colors.white)),
        content: Text(
          "E-posta adresinize şifre sıfırlama bağlantısı gönderilsin mi?\n\n$_userEmail",
          style: TextStyle(color: Colors.white.withOpacity(0.7)),
        ),
        actions: [
          TextButton(
            child: const Text("İptal", style: TextStyle(color: Colors.white54)),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              Navigator.pop(context);
              try {
                await AuthService().resetPassword(_userEmail);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Şifre sıfırlama e-postası gönderildi!')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ErrorHandler.showError(context, "Hata: $e");
                }
              }
            },
            child: const Text("Gönder"),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bağlantı açılamadı')),
        );
      }
    }
  }

  Future<void> _logout() async {
    try {
      await AuthService().signOut();
      if (mounted) {
        context.read<UserProvider>().clearUser();
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (c) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showError(context, "Çıkış yapılamadı: $e");
      }
    }
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F2937),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.warning_rounded, color: AppColors.error, size: 28),
            const SizedBox(width: 12),
            const Text("Hesabını Sil?", style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Bu işlem geri alınamaz!\n",
              style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold),
            ),
            Text(
              "• Profilin kalıcı olarak silinecek\n• Tüm eşleşmelerin kaybolacak\n• Mesaj geçmişin silinecek\n• Tüm veriler kaldırılacak",
              style: TextStyle(color: Colors.white.withOpacity(0.7), height: 1.6),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text("İptal", style: TextStyle(color: Colors.white54)),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              Navigator.pop(context); // Dialog kapa
              await _deleteAccount();
            },
            child: const Text("Evet, Sil"),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount() async {
    setState(() => _isDeleting = true);
    
    try {
      await AuthService().deleteAccount();
      
      if (mounted) {
        // Provider'ı temizle
        context.read<UserProvider>().clearUser();
        
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (c) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isDeleting = false);
        ErrorHandler.showError(context, "Hesap silinemedi: $e");
      }
    }
  }

  void _onPassportTap() {
    final userProvider = context.read<UserProvider>();
    final isPremium = userProvider.currentUser?.isPremium ?? false;

    if (!isPremium) {
       Navigator.push(context, MaterialPageRoute(builder: (_) => const PremiumOfferScreen()));
       return;
    }

    _showPassportDialog();
  }

  void _showPassportDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: AppColors.scaffold,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            Text(
              "Dengim Pasaport",
              style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              "İstediğin şehre ışınlan ve oradaki kişilerle eşleş!",
              style: GoogleFonts.plusJakartaSans(fontSize: 13, color: Colors.white54),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                   _buildCityItem("Mevcut Konumum", Icons.my_location, isSelected: true),
                   _buildCityItem("İstanbul", Icons.location_city),
                   _buildCityItem("Ankara", Icons.location_city),
                   _buildCityItem("İzmir", Icons.location_city),
                   _buildCityItem("Antalya", Icons.location_city),
                   _buildCityItem("Londra", Icons.public),
                   _buildCityItem("New York", Icons.public),
                   _buildCityItem("Paris", Icons.public),
                   _buildCityItem("Tokyo", Icons.public),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildCityItem(String name, IconData icon, {bool isSelected = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isSelected ? AppColors.primary : Colors.white10),
      ),
      child: ListTile(
        leading: Icon(icon, color: isSelected ? AppColors.primary : Colors.white54),
        title: Text(name, style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
        trailing: isSelected ? const Icon(Icons.check_circle, color: AppColors.primary) : null,
        onTap: () {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$name bölgesine ışınlanılıyor...'))
          );
          // Gerçek uygulamada koordinat güncellenir
        },
      ),
    );
  }
}
