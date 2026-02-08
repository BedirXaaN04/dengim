import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/safety_service.dart';
import '../auth/models/user_profile.dart';

class UserProfileDetailScreen extends StatelessWidget {
  final String? userId;
  final UserProfile? user;

  const UserProfileDetailScreen({super.key, this.userId, this.user})
      : assert(userId != null || user != null, 'Either userId or user must be provided');

  @override
  Widget build(BuildContext context) {
    // Eğer user objesi verilmişse, direkt göster
    if (user != null) {
      return _buildProfileUI(context, user!);
    }

    // Yoksa userId ile Firestore'dan çek
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Kullanıcı bulunamadı", style: TextStyle(color: Colors.white)));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final name = data['name'] ?? 'İsimsiz';
          final age = data['age'] ?? 18;
          final bio = data['bio'] ?? '';
          final job = data['job'] ?? '';
          final photoUrlsFromData = data['photoUrls'] != null ? List<String>.from(data['photoUrls']) : <String>[];
          final photos = photoUrlsFromData.isNotEmpty ? photoUrlsFromData : [data['imageUrl'] ?? ''];

          return Stack(
            children: [
              // Slider or Image
              PageView.builder(
                itemCount: photos.length,
                itemBuilder: (context, index) {
                   return CachedNetworkImage(
                      imageUrl: photos[index],
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      placeholder: (context, url) => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                      errorWidget: (context, url, error) => const Icon(Icons.error),
                   );
                },
              ),
              
              // Gradient
               IgnorePointer(
                 child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.transparent, Colors.black.withOpacity(0.9)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.5, 1.0],
                    ),
                  ),
                               ),
               ),

              // Info
              Positioned(
                bottom: 40,
                left: 20,
                right: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("$name, $age", style: GoogleFonts.plusJakartaSans(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                    if (job.toString().isNotEmpty) 
                       Text(job.toString().toUpperCase(), style: GoogleFonts.plusJakartaSans(fontSize: 14, color: Colors.white70, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 16),
                    Text(bio, style: GoogleFonts.plusJakartaSans(fontSize: 16, color: Colors.white)),
                    const SizedBox(height: 30),
                  ],
                ),
              ),

              // Indicators (if multiple photos)
              if (photos.length > 1) 
                 Positioned(
                   top: 50,
                   right: 70,
                   child: Container(
                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                     decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
                     child: Text("1/${photos.length}", style: const TextStyle(color: Colors.white)),
                   ),
                 ),

              // Back Button
              Positioned(
                top: 50,
                left: 20,
                child: CircleAvatar(
                  backgroundColor: Colors.black45,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),

              // Menu Button (Report/Block)
              Positioned(
                top: 50,
                right: 20,
                child: CircleAvatar(
                  backgroundColor: Colors.black45,
                  child: PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                    onSelected: (value) async {
                      if (value == 'report') {
                         final reasonController = TextEditingController();
                         if (!context.mounted) return;
                         showDialog(context: context, builder: (ctx) => AlertDialog(
                           backgroundColor: const Color(0xFF1E293B),
                           title: const Text("Şikayet Et", style: TextStyle(color: Colors.white)),
                           content: TextField(
                             controller: reasonController, 
                             style: const TextStyle(color: Colors.white),
                             decoration: const InputDecoration(hintText: "Sebep...", hintStyle: TextStyle(color: Colors.white54)),
                           ),
                           actions: [
                             TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("İptal")),
                             TextButton(onPressed: () {
                               if (reasonController.text.isNotEmpty) {
                                  SafetyService().reportUser(reportedUserId: userId ?? '', reason: reasonController.text);
                                  Navigator.pop(ctx);
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Şikayet alındı.")));
                               }
                             }, child: const Text("Gönder")),
                           ],
                         ));
                      } else if (value == 'block') {
                         if (!context.mounted) return;
                         showDialog(context: context, builder: (ctx) => AlertDialog(
                           backgroundColor: const Color(0xFF1E293B),
                           title: const Text("Engelle?", style: TextStyle(color: Colors.white)),
                           content: const Text("Bu kullanıcıyı bir daha görmeyeceksiniz.", style: TextStyle(color: Colors.white70)),
                           actions: [
                             TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Vazgeç")),
                             TextButton(onPressed: () async {
                               if (userId != null) {
                                 await SafetyService().blockUser(userId!);
                               }
                               if (!ctx.mounted) return;
                               Navigator.pop(ctx); // Dialog kapat
                               if (!context.mounted) return;
                               Navigator.pop(context); // Ekranı kapat
                               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Kullanıcı engellendi.")));
                             }, child: const Text("ENGELLE", style: TextStyle(color: Colors.red))),
                           ],
                         ));
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'report', child: Text('Şikayet Et')),
                      const PopupMenuItem(value: 'block', child: Text('Engelle', style: TextStyle(color: Colors.red))),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// UserProfile objesi ile profil UI oluştur
  Widget _buildProfileUI(BuildContext context, UserProfile profile) {
    final photos = (profile.photoUrls != null && profile.photoUrls!.isNotEmpty) ? profile.photoUrls! : [profile.imageUrl];
    final targetUserId = profile.uid;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Slider or Image
          PageView.builder(
            itemCount: photos.length,
            itemBuilder: (context, index) {
               return CachedNetworkImage(
                  imageUrl: photos[index],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  placeholder: (context, url) => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
               );
            },
          ),
          
          // Gradient
           IgnorePointer(
             child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, Colors.black.withOpacity(0.9)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.5, 1.0],
                ),
              ),
            ),
           ),

          // Info
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text("${profile.name}, ${profile.age}", style: GoogleFonts.plusJakartaSans(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                    if (profile.isVerified) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.verified, color: Colors.blue, size: 24),
                    ],
                    if (profile.isPremium) ...[
                      const SizedBox(width: 8),
                      ShaderMask(
                        shaderCallback: (bounds) => AppColors.goldGradient.createShader(bounds),
                        child: const Icon(Icons.star, color: Colors.white, size: 24),
                      ),
                    ],
                  ],
                ),
                if (profile.job != null && profile.job!.isNotEmpty) 
                   Text(profile.job!.toUpperCase(), style: GoogleFonts.plusJakartaSans(fontSize: 14, color: Colors.white70, fontWeight: FontWeight.w600)),
                if (profile.location.isNotEmpty)
                   Padding(
                     padding: const EdgeInsets.only(top: 4),
                     child: Row(
                       children: [
                         const Icon(Icons.location_on, color: Colors.white54, size: 14),
                         const SizedBox(width: 4),
                         Text(profile.location, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.white54)),
                       ],
                     ),
                   ),
                const SizedBox(height: 16),
                Text(profile.bio ?? '', style: GoogleFonts.plusJakartaSans(fontSize: 16, color: Colors.white)),
                const SizedBox(height: 30),
              ],
            ),
          ),

          // Indicators (if multiple photos)
          if (photos.length > 1) 
             Positioned(
               top: 50,
               right: 70,
               child: Container(
                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                 decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
                 child: Text("1/${photos.length}", style: const TextStyle(color: Colors.white)),
               ),
             ),

          // Back Button
          Positioned(
            top: 50,
            left: 20,
            child: CircleAvatar(
              backgroundColor: Colors.black45,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          // Menu Button (Report/Block)
          Positioned(
            top: 50,
            right: 20,
            child: CircleAvatar(
              backgroundColor: Colors.black45,
              child: PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onSelected: (value) async {
                  if (value == 'report') {
                     final reasonController = TextEditingController();
                     if (!context.mounted) return;
                     showDialog(context: context, builder: (ctx) => AlertDialog(
                       backgroundColor: const Color(0xFF1E293B),
                       title: const Text("Şikayet Et", style: TextStyle(color: Colors.white)),
                       content: TextField(
                         controller: reasonController, 
                         style: const TextStyle(color: Colors.white),
                         decoration: const InputDecoration(hintText: "Sebep...", hintStyle: TextStyle(color: Colors.white54)),
                       ),
                       actions: [
                         TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("İptal")),
                         TextButton(onPressed: () {
                           if (reasonController.text.isNotEmpty) {
                              SafetyService().reportUser(reportedUserId: targetUserId, reason: reasonController.text);
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Şikayet alındı.")));
                           }
                         }, child: const Text("Gönder")),
                       ],
                     ));
                  } else if (value == 'block') {
                     if (!context.mounted) return;
                     showDialog(context: context, builder: (ctx) => AlertDialog(
                       backgroundColor: const Color(0xFF1E293B),
                       title: const Text("Engelle?", style: TextStyle(color: Colors.white)),
                       content: const Text("Bu kullanıcıyı bir daha görmeyeceksiniz.", style: TextStyle(color: Colors.white70)),
                       actions: [
                         TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Vazgeç")),
                         TextButton(onPressed: () async {
                           await SafetyService().blockUser(targetUserId);
                           if (!ctx.mounted) return;
                           Navigator.pop(ctx); // Dialog kapat
                           if (!context.mounted) return;
                           Navigator.pop(context); // Ekranı kapat
                           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Kullanıcı engellendi.")));
                         }, child: const Text("ENGELLE", style: TextStyle(color: Colors.red))),
                       ],
                     ));
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'report', child: Text('Şikayet Et')),
                  const PopupMenuItem(value: 'block', child: Text('Engelle', style: TextStyle(color: Colors.red))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
