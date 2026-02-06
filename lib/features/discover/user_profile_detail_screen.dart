import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/safety_service.dart';

class UserProfileDetailScreen extends StatelessWidget {
  final String userId;

  const UserProfileDetailScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
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
          final photos = List<String>.from(data['photoUrls'] ?? []);

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
                    if (job.isNotEmpty) 
                       Text(job.toUpperCase(), style: GoogleFonts.plusJakartaSans(fontSize: 14, color: Colors.white70, fontWeight: FontWeight.w600)),
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
                                  SafetyService().reportUser(reportedUserId: userId, reason: reasonController.text);
                                  Navigator.pop(ctx);
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Şikayet alındı.")));
                               }
                             }, child: const Text("Gönder")),
                           ],
                         ));
                      } else if (value == 'block') {
                         showDialog(context: context, builder: (ctx) => AlertDialog(
                           backgroundColor: const Color(0xFF1E293B),
                           title: const Text("Engelle?", style: TextStyle(color: Colors.white)),
                           content: const Text("Bu kullanıcıyı bir daha görmeyeceksiniz.", style: TextStyle(color: Colors.white70)),
                           actions: [
                             TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Vazgeç")),
                             TextButton(onPressed: () async {
                               await SafetyService().blockUser(userId);
                               Navigator.pop(ctx); // Dialog kapat
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
}
