import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Read Receipt Service
/// Mesaj okundu bilgisini yönetir
class ReadReceiptService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Mesajı okundu olarak işaretle
  Future<void> markAsRead({
    required String chatId,
    required String messageId,
    required String userId,
  }) async {
    try {
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(messageId)
          .update({
        'readBy': FieldValue.arrayUnion([userId]),
        'readAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error marking message as read: $e');
    }
  }

  /// Tüm mesajları okundu olarak işaretle
  Future<void> markAllAsRead({
    required String chatId,
    required String userId,
  }) async {
    try {
      final messages = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .where('senderId', isNotEqualTo: userId)
          .get();

      final batch = _firestore.batch();

      for (final doc in messages.docs) {
        final data = doc.data();
        final readBy = List<String>.from(data['readBy'] ?? []);

        if (!readBy.contains(userId)) {
          batch.update(doc.reference, {
            'readBy': FieldValue.arrayUnion([userId]),
            'readAt': FieldValue.serverTimestamp(),
          });
        }
      }

      await batch.commit();
    } catch (e) {
      debugPrint('Error marking all messages as read: $e');
    }
  }

  /// Okunmamış mesaj sayısını al
  Stream<int> getUnreadCountStream({
    required String chatId,
    required String userId,
  }) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .where('senderId', isNotEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      int unreadCount = 0;
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final readBy = List<String>.from(data['readBy'] ?? []);
        if (!readBy.contains(userId)) {
          unreadCount++;
        }
      }
      return unreadCount;
    });
  }

  /// Mesajın okunup okunmadığını kontrol et
  bool isMessageRead(Map<String, dynamic> messageData, String userId) {
    final readBy = List<String>.from(messageData['readBy'] ?? []);
    return readBy.contains(userId);
  }
}

/// Read Receipt Indicator Widget
/// Mesaj gönderildi/okundu durumunu gösteren widget
class ReadReceiptIndicator extends StatelessWidget {
  final bool isSent;
  final bool isDelivered;
  final bool isRead;
  final Color color;

  const ReadReceiptIndicator({
    super.key,
    required this.isSent,
    required this.isDelivered,
    required this.isRead,
    this.color = Colors.white54,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color iconColor;

    if (isRead) {
      icon = Icons.done_all;
      iconColor = const Color(0xFF10B981); // Green
    } else if (isDelivered) {
      icon = Icons.done_all;
      iconColor = color;
    } else if (isSent) {
      icon = Icons.done;
      iconColor = color;
    } else {
      icon = Icons.schedule;
      iconColor = color.withOpacity(0.5);
    }

    return Icon(icon, size: 14, color: iconColor);
  }
}

/// Message Status Text
/// Mesaj durumunu text olarak gösteren widget
class MessageStatusText extends StatelessWidget {
  final bool isSent;
  final bool isDelivered;
  final bool isRead;
  final DateTime? readAt;
  final TextStyle? style;

  const MessageStatusText({
    super.key,
    required this.isSent,
    required this.isDelivered,
    required this.isRead,
    this.readAt,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    String statusText;

    if (isRead && readAt != null) {
      statusText = 'Okundu • ${_formatTime(readAt!)}';
    } else if (isRead) {
      statusText = 'Okundu';
    } else if (isDelivered) {
      statusText = 'İletildi';
    } else if (isSent) {
      statusText = 'Gönderildi';
    } else {
      statusText = 'Gönderiliyor...';
    }

    return Text(
      statusText,
      style: style ??
          const TextStyle(
            color: Colors.white54,
            fontSize: 10,
            fontStyle: FontStyle.italic,
          ),
    );
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) return 'Az önce';
    if (difference.inMinutes < 60) return '${difference.inMinutes}dk önce';
    if (difference.inHours < 24) return '${difference.inHours}sa önce';
    return '${date.day}/${date.month}';
  }
}

/// Unread Badge Widget
/// Okunmamış mesaj sayısını gösteren badge
class UnreadBadge extends StatelessWidget {
  final int count;
  final Color backgroundColor;
  final Color textColor;
  final double size;

  const UnreadBadge({
    super.key,
    required this.count,
    this.backgroundColor = const Color(0xFFEF4444), // Red
    this.textColor = Colors.white,
    this.size = 20,
  });

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();

    return Container(
      constraints: BoxConstraints(
        minWidth: size,
        minHeight: size,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(size / 2),
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withOpacity(0.4),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Center(
        child: Text(
          count > 99 ? '99+' : count.toString(),
          style: TextStyle(
            color: textColor,
            fontSize: size * 0.6,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

/// Typing and Read Status Bar
/// Sohbet ekranında alttaki durum çubuğu
class ChatStatusBar extends StatelessWidget {
  final String chatId;
  final String otherUserId;
  final bool isOtherUserOnline;
  final TextStyle? style;

  const ChatStatusBar({
    super.key,
    required this.chatId,
    required this.otherUserId,
    required this.isOtherUserOnline,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: _getTypingStream(),
      builder: (context, snapshot) {
        if (snapshot.data == true) {
          return Text(
            'yazıyor...',
            style: style ??
                const TextStyle(
                  color: Color(0xFF10B981),
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
          );
        }

        if (isOtherUserOnline) {
          return Text(
            'Çevrimiçi',
            style: style ??
                const TextStyle(
                  color: Color(0xFF10B981),
                  fontSize: 12,
                ),
          );
        }

        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(otherUserId)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const SizedBox.shrink();

            final data = snapshot.data?.data() as Map<String, dynamic>?;
            final lastSeen = data?['lastSeen'] as Timestamp?;

            if (lastSeen != null) {
              return Text(
                _formatLastSeen(lastSeen.toDate()),
                style: style ??
                    const TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
              );
            }

            return const SizedBox.shrink();
          },
        );
      },
    );
  }

  Stream<bool> _getTypingStream() {
    return FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('typing')
        .doc(otherUserId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) return false;
      final data = snapshot.data();
      return data?['isTyping'] ?? false;
    });
  }

  String _formatLastSeen(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) return 'Az önce çevrimiçiydi';
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} dakika önce çevrimiçiydi';
    }
    if (difference.inHours < 24) {
      return '${difference.inHours} saat önce çevrimiçiydi';
    }
    return 'Uzun zaman önce çevrimiçiydi';
  }
}
