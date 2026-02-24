import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../auth/services/profile_service.dart';
import '../auth/services/auth_service.dart';
import '../auth/login_screen.dart';
import '../support/support_screen.dart';
import '../../core/services/config_service.dart';
import '../../core/theme/app_colors.dart';
import 'package:flutter/services.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("AYARLAR", style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Center(
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 2.5),
                boxShadow: const [
                  BoxShadow(color: Colors.black, offset: Offset(2, 2)),
                ],
              ),
              child: const Icon(Icons.arrow_back, color: Colors.black, size: 18),
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader("HESAP"),
          _buildTile(
            icon: Icons.logout,
            title: "ÇIKIŞ YAP",
            color: Colors.orange,
            onTap: () => _signOut(context),
          ),
          _buildTile(
            icon: Icons.block,
            title: "ENGELLENEN KULLANICILAR",
            color: Colors.black,
            onTap: () => _showBlockedUsers(context),
          ),
          _buildTile(
            icon: Icons.delete_forever,
            title: "HESABI SİL",
            color: Colors.red,
            onTap: () => _deleteAccount(context),
          ),
          
          const SizedBox(height: 24),
          _buildSectionHeader("BİLDİRİMLER"),
          _buildTile(
            icon: Icons.notifications_outlined,
            title: "BİLDİRİM AYARLARI",
            color: Colors.black,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('📱 BİLDİRİM AYARLARI CİHAZ AYARLARINDAN YÖNETİLEBİLİR', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, color: Colors.white)),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Colors.black,
                ),
              );
            },
          ),
          
          const SizedBox(height: 24),
          _buildSectionHeader("DESTEK"),
          _buildTile(
            icon: Icons.support_agent,
            title: "DESTEK TALEBİ OLUŞTUR",
            color: Colors.black,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SupportScreen()),
              );
            },
          ),
          _buildTile(
            icon: Icons.email_outlined,
            title: "E-POSTA İLE İLETİŞİM",
            color: Colors.black,
            onTap: () => _launchEmail(context),
          ),
          
          const SizedBox(height: 24),
          _buildSectionHeader("VERİ & GİZLİLİK"),
          _buildTile(
            icon: Icons.shield_outlined,
            title: "VERİ GÜVENLİĞİ",
            color: Colors.black,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('🔒 VERİLERİNİZ END-TO-END ŞİFRELEME İLE KORUNMAKTADIR', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, color: Colors.white)),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Colors.black,
                  duration: const Duration(seconds: 3),
                ),
              );
            },
          ),
          _buildTile(
            icon: Icons.download_outlined,
            title: "VERİLERİMİ İNDİR",
            color: Colors.black,
            onTap: () => _downloadMyData(context),
          ),
          
          const SizedBox(height: 24),
          _buildSectionHeader("HAKKINDA"),
          _buildTile(
            icon: Icons.info_outline,
            title: "UYGULAMA HAKKINDA",
            color: Colors.black,
            onTap: () => _showAboutApp(context),
          ),
          _buildTile(
            icon: Icons.privacy_tip_outlined,
            title: "GİZLİLİK SÖZLEŞMESİ",
            color: Colors.black,
            onTap: () => _launchUrl(context, ConfigService().privacyPolicyUrl),
          ),
          _buildTile(
            icon: Icons.description_outlined,
            title: "KULLANIM KOŞULLARI (EULA)",
            color: Colors.black,
            onTap: () => _launchUrl(context, ConfigService().termsOfServiceUrl),
          ),
          
          const SizedBox(height: 48),
          Center(
            child: Text(
              "DENGIM v${ConfigService().appVersion}",
              style: GoogleFonts.outfit(color: Colors.black.withOpacity(0.3), fontSize: 12, fontWeight: FontWeight.w900),
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
        style: GoogleFonts.outfit(
          color: Colors.black.withOpacity(0.4),
          fontSize: 12,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildTile({required IconData icon, required String title, required VoidCallback onTap, required Color color}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black, width: 2),
        boxShadow: const [
          BoxShadow(color: Colors.black, offset: Offset(3, 3)),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title, style: GoogleFonts.outfit(color: color, fontWeight: FontWeight.w900, fontSize: 14)),
        trailing: const Icon(Icons.chevron_right, color: Colors.black),
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
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Colors.black, width: 3)),
        title: Text("HESABI SİL?", style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.w900)),
        content: Text(
          "BU İŞLEM GERİ ALINAMAZ. PROFİLİNİZ, EŞLeŞMELERİNİZ VE MESAJLARINIZ KALICI OLARAK SİLİNECEKTİR.",
          style: GoogleFonts.outfit(color: Colors.black.withOpacity(0.6), fontWeight: FontWeight.w700),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("İPTAL", style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.w900))),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
               _showFinalDeleteConfirmation(context);
            },
            child: Text("DEVAM ET", style: GoogleFonts.outfit(color: Colors.red, fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }
  
  void _showFinalDeleteConfirmation(BuildContext context) {
     showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Colors.black, width: 3)),
        title: Text("SON KARARINIZ MI?", style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.w900)),
        content: Text(
          "YAZIK OLACAK... YİNE DE SİLMEK İSTİYOR MUSUNUZ?",
          style: GoogleFonts.outfit(color: Colors.black.withOpacity(0.6), fontWeight: FontWeight.w700),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("VAZGEÇ", style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.w900))),
          GestureDetector(
            onTap: () async {
              Navigator.pop(context);
              try {
                showDialog(
                  context: context, 
                  barrierDismissible: false,
                  builder: (_) => const Center(child: CircularProgressIndicator(color: Colors.black))
                );
                
                await ProfileService().deleteAccount();
                
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("HATA: $e", style: GoogleFonts.outfit(fontWeight: FontWeight.w900)), backgroundColor: Colors.red));
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.black, width: 2),
                boxShadow: const [
                  BoxShadow(color: Colors.black, offset: Offset(2, 2)),
                ],
              ),
              child: Text("HESABI SİL", style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)),
            ),
          ),
        ],
      ),
     );
  }

  void _showBlockedUsers(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Colors.black, width: 3)),
        title: Text("ENGELLENEN KULLANICILAR", style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.w900)),
        content: Text(
          "ENGELLEDİĞİNİZ KULLANICILARI BURADA GÖREBİLECEKSİNİZ.",
          style: GoogleFonts.outfit(color: Colors.black.withOpacity(0.6), fontWeight: FontWeight.w700),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("KAPAT", style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }

  void _downloadMyData(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Colors.black, width: 3)),
        title: Text("VERİLERİMİ İNDİR", style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.w900)),
        content: Text(
          "TÜM VERİLERİNİZ (PROFİL, MESAJLAR, EŞLeŞMELER) BİR ZIP DOSYASI OLARAK E-POSTANIZA GÖNDERİLECEKTİR.\n\nBU İŞLEM 24-48 SAAT SÜREBİLİR.",
          style: GoogleFonts.outfit(color: Colors.black.withOpacity(0.6), fontWeight: FontWeight.w700, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("İPTAL", style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.w900)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('📧 VERİ İNDİRME TALEBİ ALINDI. E-POSTANIZI KONTROL EDİN.', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, color: Colors.white)),
                  backgroundColor: Colors.black,
                  duration: const Duration(seconds: 3),
                ),
              );
            },
            child: Text("TALEP OLUŞTUR", style: GoogleFonts.outfit(color: AppColors.primary, fontWeight: FontWeight.w900)),
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
          color: AppColors.primary,
          border: Border.all(color: Colors.black, width: 3),
          boxShadow: const [
            BoxShadow(color: Colors.black, offset: Offset(3, 3)),
          ],
        ),
        child: const Icon(Icons.favorite, color: Colors.black, size: 32),
      ),
      children: [
        const SizedBox(height: 16),
        Text(
          'DENGİM - TÜRKİYE\'NİN EN POPÜLER FLÖRT UYGULAMASI! 💛',
          style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 12),
        Text(
          'ÖZELLİKLER:',
          style: GoogleFonts.outfit(
            fontSize: 13,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '• AKILLI EŞLeŞME ALGORİTMASI\n'
          '• VİDEO GÖRÜŞME\n'
          '• SESLİ MESAJLAR\n'
          '• HİKAYELER\n'
          '• HARİTA ÜZERİNDE KEŞFET\n'
          '• SESLİ SOHBET ODALARI\n'
          '• PREMİUM ÖZELLİKLER',
          style: GoogleFonts.outfit(fontSize: 12, height: 1.6, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
