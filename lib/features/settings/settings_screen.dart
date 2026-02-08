import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../auth/services/profile_service.dart';
import '../auth/services/auth_service.dart';
import '../auth/login_screen.dart';

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
            icon: Icons.delete_forever,
            title: "Hesabı Sil",
            color: Colors.red,
            onTap: () => _deleteAccount(context),
          ),
          
          const SizedBox(height: 24),
          _buildSectionHeader("HAKKINDA"),
          _buildTile(
            icon: Icons.privacy_tip_outlined,
            title: "Gizlilik Sözleşmesi",
            color: Colors.white,
            onTap: () {
              // Launch URL
            },
          ),
           _buildTile(
            icon: Icons.description_outlined,
             title: "Kullanım Koşulları (EULA)",
             color: Colors.white,
            onTap: () {
               // Launch URL
            },
          ),
          
          const SizedBox(height: 48),
          Center(
            child: Text(
              "DENGIM v1.0.0 (Beta)",
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
}
