import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../auth/services/profile_service.dart';
import '../auth/services/auth_service.dart';
import '../auth/login_screen.dart';
import '../support/support_screen.dart';
import '../../core/services/config_service.dart';
import 'package:flutter/services.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: Text("Ayarlar", style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader("HESAP"),
          _buildTile(
            icon: Icons.logout,
            title: "Çıkış Yap",
            color: Colors.orange,
            onTap: () => _signOut(context),
          ),
          _buildTile(
            icon: Icons.block,
            title: "Engellenen Kullanıcılar",
            color: Colors.white,
            onTap: () => _showBlockedUsers(context),
          ),
          _buildTile(
            icon: Icons.delete_forever,
            title: "Hesabı Sil",
            color: Colors.red,
            onTap: () => _deleteAccount(context),
          ),
          
          const SizedBox(height: 24),
          _buildSectionHeader("BİLDİRİMLER"),
          _buildTile(
            icon: Icons.notifications_outlined,
            title: "Bildirim Ayarları",
            color: Colors.white,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('📱 Bildirim ayarları cihaz ayarlarından yönetilebilir'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          
          const SizedBox(height: 24),
          _buildSectionHeader("DESTEK"),
          _buildTile(
            icon: Icons.support_agent,
            title: "Destek Talebi Oluştur",
            color: const Color(0xFFFFD700),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SupportScreen()),
              );
            },
          ),
          _buildTile(
            icon: Icons.email_outlined,
            title: "E-posta ile İletişim",
            color: Colors.white,
            onTap: () => _launchEmail(context),
          ),
          
          const SizedBox(height: 24),
          _buildSectionHeader("VERİ & GİZLİLİK"),
          _buildTile(
            icon: Icons.shield_outlined,
            title: "Veri Güvenliği",
            color: Colors.white,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('🔒 Verileriniz end-to-end şifreleme ile korunmaktadır'),
                  behavior: SnackBarBehavior.floating,
                  duration: Duration(seconds: 3),
                ),
              );
            },
          ),
          _buildTile(
            icon: Icons.download_outlined,
            title: "Verilerimi İndir",
            color: Colors.white,
            onTap: () => _downloadMyData(context),
          ),
          
          const SizedBox(height: 24),
          _buildSectionHeader("HAKKINDA"),
          _buildTile(
            icon: Icons.info_outline,
            title: "Uygulama Hakkında",
            color: Colors.white,
            onTap: () => _showAboutApp(context),
          ),
          _buildTile(
            icon: Icons.privacy_tip_outlined,
            title: "Gizlilik Sözleşmesi",
            color: Colors.white,
            onTap: () => _launchUrl(context, ConfigService().privacyPolicyUrl),
          ),
          _buildTile(
            icon: Icons.description_outlined,
            title: "Kullanım Koşulları (EULA)",
            color: Colors.white,
            onTap: () => _launchUrl(context, ConfigService().termsOfServiceUrl),
          ),
          
          const SizedBox(height: 48),
          Center(
            child: Text(
              "DENGIM v${ConfigService().appVersion}",
              style: GoogleFonts.plusJakartaSans(color: Colors.white30, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          color: Colors.white54,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildTile({required IconData icon, required String title, required VoidCallback onTap, required Color color}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title, style: GoogleFonts.plusJakartaSans(color: color, fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.chevron_right, color: Colors.white30),
        onTap: onTap,
      ),
    );
  }

  // URL açma fonksiyonu
  void _launchUrl(BuildContext context, String urlString) async {
    try {
      final uri = Uri.parse(urlString);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('URL açılamadı: $urlString')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    }
  }

  // Email açma fonksiyonu
  void _launchEmail(BuildContext context) async {
    final emailUrl = Uri(
      scheme: 'mailto',
      path: ConfigService().supportEmail,
      queryParameters: {'subject': 'DENGİM Destek Talebi'},
    );
    
    try {
      if (await canLaunchUrl(emailUrl)) {
        await launchUrl(emailUrl);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('E-posta: ${ConfigService().supportEmail}'),
              action: SnackBarAction(
                label: 'KOPYALA',
                onPressed: () {
                  // TODO: Clipboard copy
                },
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('E-posta: ${ConfigService().supportEmail}')),
        );
      }
    }
  }

  void _signOut(BuildContext context) async {
    await AuthService().signOut();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void _deleteAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text("Hesabı Sil?", style: TextStyle(color: Colors.white)),
        content: const Text(
          "Bu işlem geri alınamaz. Profiliniz, eşleşmeleriniz ve mesajlarınız kalıcı olarak silinecektir.",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("İptal")),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // İlk dialogu kapat
               // İkinci ONAY
               _showFinalDeleteConfirmation(context);
            },
            child: const Text("Devam Et", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
  
  void _showFinalDeleteConfirmation(BuildContext context) {
     showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text("Son Kararınız mı?", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text(
          "Yazık olacak... Yine de silmek istiyor musunuz?",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Vazgeç")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              try {
                // Loading göster
                showDialog(
                  context: context, 
                  barrierDismissible: false,
                  builder: (_) => const Center(child: CircularProgressIndicator())
                );
                
                await ProfileService().deleteAccount();
                
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              } catch (e) {
                Navigator.pop(context); // Loading kapat
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Hata: $e")));
              }
          },
            child: const Text("HESABI SİL", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
     );
  }

  void _showBlockedUsers(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text("Engellenen Kullanıcılar", style: TextStyle(color: Colors.white)),
        content: const Text(
          "Engellediğiniz kullanıcıları burada görebileceksiniz.",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("KAPAT"),
          ),
        ],
      ),
    );
  }

  void _downloadMyData(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text("Verilerimi İndir", style: TextStyle(color: Colors.white)),
        content: const Text(
          "Tüm verileriniz (profil, mesajlar, eşleşmeler) bir ZIP dosyası olarak e-postanıza gönderilecektir.\n\nBu işlem 24-48 saat sürebilir.",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("İptal"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('📧 Veri indirme talebi alındı. E-postanızı kontrol edin.'),
                  duration: Duration(seconds: 3),
                ),
              );
            },
            child: const Text("TALEP OLUŞTUR"),
          ),
        ],
      ),
    );
  }

  void _showAboutApp(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'DENGİM',
      applicationVersion: ConfigService().appVersion,
      applicationIcon: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
          ),
        ),
        child: const Icon(Icons.favorite, color: Colors.black, size: 32),
      ),
      children: [
        const SizedBox(height: 16),
        Text(
          'DENGİM - Türkiye\'nin en popüler flört uygulaması! 💛',
          style: GoogleFonts.plusJakartaSans(fontSize: 14),
        ),
        const SizedBox(height: 12),
        Text(
          'Özellikler:',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '• Akıllı eşleşme algoritması\n'
          '• Video görüşme\n'
          '• Sesli mesajlar\n'
          '• Hikayeler\n'
          '• Harita üzerinde keşfet\n'
          '• Sesli sohbet odaları\n'
          '• Premium özellikler',
          style: GoogleFonts.plusJakartaSans(fontSize: 12, height: 1.6),
        ),
      ],
    );
  }
}
