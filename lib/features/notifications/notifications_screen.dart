import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/providers/user_provider.dart';
import '../../core/theme/app_colors.dart';
import '../chats/screens/chat_detail_screen.dart';
import '../likes/likes_screen.dart';
import '../discover/user_profile_detail_screen.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<UserProvider>().currentUser;

    if (currentUser == null) return const Scaffold(body: Center(child: Text("Giriş yapmalısınız")));

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Dark Midnight Blue
      appBar: AppBar(
        title: Text("Bildirimler", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .collection('notifications')
            .orderBy('createdAt', descending: true)
            .limit(50)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Icon(Icons.notifications_off_outlined, size: 64, color: Colors.white.withOpacity(0.2)),
                   const SizedBox(height: 16),
                   Text("Henüz bildirim yok", style: GoogleFonts.plusJakartaSans(color: Colors.white54)),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final isRead = data['isRead'] ?? false;
              final timestamp = data['createdAt'] as Timestamp?;

              return Dismissible(
                key: Key(doc.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: AppColors.error.withOpacity(0.2), 
                  alignment: Alignment.centerRight, 
                  padding: const EdgeInsets.only(right: 20), 
                  child: const Icon(Icons.delete, color: AppColors.error)
                ),
                onDismissed: (direction) {
                   doc.reference.delete();
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  decoration: BoxDecoration(
                    color: isRead ? Colors.transparent : AppColors.primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: isRead ? null : Border.all(color: AppColors.primary.withOpacity(0.1)),
                  ),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        shape: BoxShape.circle,
                      ),
                      child: _getIconForType(data['type']),
                    ),
                    title: Text(
                      data['title'] ?? 'Bildirim', 
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white, 
                        fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                        fontSize: 14,
                      )
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          data['body'] ?? '', 
                          style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 12)
                        ),
                        if (timestamp != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            _formatTime(timestamp.toDate()), 
                            style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.3))
                          ),
                        ]
                      ],
                    ),
                    onTap: () {
                      if (!isRead) {
                        doc.reference.update({'isRead': true});
                      }
                      
                      _handleNotificationTap(context, data);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
  
  Icon _getIconForType(String? type) {
    double size = 20;
    switch (type) {
      case 'match': return Icon(Icons.favorite, color: AppColors.primary, size: size);
      case 'like': return Icon(Icons.thumb_up, color: Colors.blue, size: size);
      case 'story_like': return Icon(Icons.favorite_border, color: Colors.red, size: size);
      case 'message': return Icon(Icons.message, color: Colors.green, size: size);
      default: return Icon(Icons.notifications, color: Colors.white, size: size);
    }
  }

  void _handleNotificationTap(BuildContext context, Map<String, dynamic> data) {
    final type = data['type'];
    final payload = data['data'] as Map<String, dynamic>? ?? {};
    final senderId = data['senderId'];

    switch (type) {
      case 'message':
      case 'match':
      case 'story_reply':
        if (payload['chatId'] != null) {
          // ChatDetailScreen requires other user details. 
          // Ideally we fetch them or pass minimal data.
          // For now, if we have senderId, we can try to rely on ChatService to fetch details or passed data
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatDetailScreen(
                chatId: payload['chatId'],
                otherUserId: senderId ?? '',
                otherUserName: payload['senderName'] ?? 'Kullanıcı',
                otherUserAvatar: payload['senderAvatar'] ?? '',
              ),
            ),
          );
        } else if (senderId != null) {
          // If no chatId, try to go to profile or chats list
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => UserProfileDetailScreen(userId: senderId)),
          );
        }
        break;
      
      case 'like':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LikesScreen()),
        );
        break;

      case 'story_like':
        if (senderId != null) {
           Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => UserProfileDetailScreen(userId: senderId)),
          );
        }
        break;
        
      default:
        // Default to profile if sender exists
        if (senderId != null) {
           Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => UserProfileDetailScreen(userId: senderId)),
          );
        }
    }
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) return 'Şimdi';
    if (difference.inMinutes < 60) return '${difference.inMinutes} dakika önce';
    if (difference.inHours < 24) return '${difference.inHours} saat önce';
    if (difference.inDays < 7) return '${difference.inDays} gün önce';
    return '${date.day}/${date.month}/${date.year}';
  }
}
