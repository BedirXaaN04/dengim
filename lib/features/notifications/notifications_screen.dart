import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/providers/user_provider.dart';
import '../../core/theme/app_colors.dart';
import '../chats/screens/chat_detail_screen.dart';
import '../likes/likes_screen.dart';
import '../discover/user_profile_detail_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  
  @override
  void initState() {
    super.initState();
    // Yeni kullanıcılar için global duyuruları kontrol et ve ekle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncGlobalAnnouncements();
    });
  }

  /// Yeni kayıt olan kullanıcılar için global announcements koleksiyonundan
  /// henüz almadıkları duyuruları notifications alt koleksiyonuna ekle
  Future<void> _syncGlobalAnnouncements() async {
    final currentUser = context.read<UserProvider>().currentUser;
    if (currentUser == null) return;

    try {
      final firestore = FirebaseFirestore.instance;
      
      // 1. Aktif duyuruları getir
      final announcementsSnapshot = await firestore
          .collection('announcements')
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(10)
          .get();

      if (announcementsSnapshot.docs.isEmpty) return;

      // 2. Kullanıcının mevcut duyuru notification'larını kontrol et
      final existingNotifs = await firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('notifications')
          .where('type', isEqualTo: 'announcement')
          .get();

      final existingAnnouncementIds = existingNotifs.docs
          .map((doc) => doc.data()['announcementId'] as String?)
          .where((id) => id != null)
          .toSet();

      // 3. Eksik duyuruları ekle
      final batch = firestore.batch();
      int addedCount = 0;

      for (final announcementDoc in announcementsSnapshot.docs) {
        if (!existingAnnouncementIds.contains(announcementDoc.id)) {
          final data = announcementDoc.data();
          final notifRef = firestore
              .collection('users')
              .doc(currentUser.uid)
              .collection('notifications')
              .doc(); // auto-generated ID

          batch.set(notifRef, {
            'type': 'announcement',
            'title': data['title'] ?? 'Duyuru',
            'body': data['body'] ?? '',
            'imageUrl': data['imageUrl'],
            'announcementId': announcementDoc.id,
            'senderId': 'admin',
            'isRead': false,
            'createdAt': data['createdAt'] ?? Timestamp.now(),
            'data': {
              'segment': data['segment'] ?? 'all',
            },
          });
          addedCount++;
        }
      }

      if (addedCount > 0) {
        await batch.commit();
      }
    } catch (e) {
      debugPrint('Announcement sync error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<UserProvider>().currentUser;

    if (currentUser == null) {
      return const Scaffold(body: Center(child: Text("Giriş yapmalısınız")));
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: Text(
          "Bildirimler",
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Tümünü Okundu İşaretle
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Colors.white.withOpacity(0.6)),
            color: const Color(0xFF1E293B),
            onSelected: (value) {
              if (value == 'mark_all') {
                _markAllAsRead(currentUser.uid);
              } else if (value == 'clear_all') {
                _clearAllNotifications(currentUser.uid);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'mark_all',
                child: Row(
                  children: [
                    const Icon(Icons.done_all, color: AppColors.primary, size: 18),
                    const SizedBox(width: 8),
                    Text('Tümünü Okundu İşaretle', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 13)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'clear_all',
                child: Row(
                  children: [
                    const Icon(Icons.delete_sweep, color: Colors.red, size: 18),
                    const SizedBox(width: 8),
                    Text('Tümünü Sil', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
        ],
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
                  const SizedBox(height: 8),
                  Text(
                    "Eşleşmeler, beğeniler ve duyurular\nburada görünecek.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(color: Colors.white30, fontSize: 12),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final data = doc.data() as Map<String, dynamic>;
              // Backward compatibility: support both old ('read', 'timestamp', 'fromUid') and new ('isRead', 'createdAt', 'senderId') formats
              final isRead = data['isRead'] ?? data['read'] ?? false;
              final timestamp = (data['createdAt'] ?? data['timestamp']) as Timestamp?;
              final type = data['type'] as String?;

              return Dismissible(
                key: Key(doc.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: AppColors.error.withOpacity(0.2),
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete, color: AppColors.error),
                ),
                onDismissed: (direction) {
                  doc.reference.delete();
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
                  decoration: BoxDecoration(
                    color: isRead ? Colors.transparent : _getNotifBgColor(type),
                    borderRadius: BorderRadius.circular(16),
                    border: isRead ? null : Border.all(color: _getNotifBorderColor(type)),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _getIconBgColor(type),
                        shape: BoxShape.circle,
                      ),
                      child: Center(child: _getIconForType(type)),
                    ),
                    title: Text(
                      data['title'] ?? 'Bildirim',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          data['body'] ?? '',
                          style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 12),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (timestamp != null) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Text(
                                _formatTime(timestamp.toDate()),
                                style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.3)),
                              ),
                              if (type == 'announcement') ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '📢 Duyuru',
                                    style: TextStyle(fontSize: 9, color: Colors.blue.withOpacity(0.7), fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
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

  Color _getNotifBgColor(String? type) {
    switch (type) {
      case 'announcement': return Colors.blue.withOpacity(0.05);
      case 'match': return AppColors.primary.withOpacity(0.08);
      case 'like': return Colors.pink.withOpacity(0.05);
      default: return AppColors.primary.withOpacity(0.05);
    }
  }

  Color _getNotifBorderColor(String? type) {
    switch (type) {
      case 'announcement': return Colors.blue.withOpacity(0.15);
      case 'match': return AppColors.primary.withOpacity(0.15);
      case 'like': return Colors.pink.withOpacity(0.1);
      default: return AppColors.primary.withOpacity(0.1);
    }
  }

  Color _getIconBgColor(String? type) {
    switch (type) {
      case 'announcement': return Colors.blue.withOpacity(0.15);
      case 'match': return AppColors.primary.withOpacity(0.15);
      case 'like': return Colors.pink.withOpacity(0.15);
      case 'message': return Colors.green.withOpacity(0.15);
      case 'story_like': return Colors.red.withOpacity(0.15);
      default: return Colors.white.withOpacity(0.05);
    }
  }

  Icon _getIconForType(String? type) {
    double size = 20;
    switch (type) {
      case 'announcement': return Icon(Icons.campaign_rounded, color: Colors.blue, size: size);
      case 'match': return Icon(Icons.favorite, color: AppColors.primary, size: size);
      case 'like': return Icon(Icons.thumb_up, color: Colors.pink, size: size);
      case 'story_like': return Icon(Icons.favorite_border, color: Colors.red, size: size);
      case 'message': return Icon(Icons.message, color: Colors.green, size: size);
      default: return Icon(Icons.notifications, color: Colors.white, size: size);
    }
  }

  void _handleNotificationTap(BuildContext context, Map<String, dynamic> data) {
    final type = data['type'];
    final payload = data['data'] as Map<String, dynamic>? ?? {};
    final senderId = data['senderId'] ?? data['fromUid'];

    switch (type) {
      case 'announcement':
        // Duyuru bildirimine tıklandığında özel bir şey yapmaya gerek yok
        // İçerik zaten görünüyor
        break;

      case 'message':
      case 'match':
      case 'story_reply':
        if (payload['chatId'] != null) {
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
        } else if (senderId != null && senderId != 'admin') {
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
        if (senderId != null && senderId != 'admin') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => UserProfileDetailScreen(userId: senderId)),
          );
        }
        break;

      default:
        if (senderId != null && senderId != 'admin') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => UserProfileDetailScreen(userId: senderId)),
          );
        }
    }
  }

  void _markAllAsRead(String uid) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('notifications')
          .where('isRead', isEqualTo: false)
          .get();

      final batch = FirebaseFirestore.instance.batch();
      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${snapshot.docs.length} bildirim okundu olarak işaretlendi'),
            backgroundColor: AppColors.primary.withOpacity(0.9),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('Mark all read error: $e');
    }
  }

  void _clearAllNotifications(String uid) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: Text('Tüm Bildirimleri Sil', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text('Tüm bildirimler silinecek. Bu işlem geri alınamaz.', style: GoogleFonts.plusJakartaSans(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('İptal', style: GoogleFonts.plusJakartaSans(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Sil', style: GoogleFonts.plusJakartaSans(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('notifications')
          .get();

      final batch = FirebaseFirestore.instance.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      debugPrint('Clear all notifications error: $e');
    }
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) return 'Şimdi';
    if (difference.inMinutes < 60) return '${difference.inMinutes} dk önce';
    if (difference.inHours < 24) return '${difference.inHours} saat önce';
    if (difference.inDays < 7) return '${difference.inDays} gün önce';
    return '${date.day}/${date.month}/${date.year}';
  }
}
