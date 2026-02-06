import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../models/chat_models.dart';


/// Sohbet listesi öğesi - Premium Tasarım
class ChatListItem extends StatelessWidget {
  final ChatConversation chat;
  final VoidCallback onTap;

  const ChatListItem({
    super.key,
    required this.chat,
    required this.onTap,
  });

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      splashColor: AppColors.primary.withOpacity(0.1),
      highlightColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 16),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.03))),
        ),
        child: Row(
          children: [
            // Avatar with Gold Ring
            Stack(
              children: [
                 Container(
                  padding: const EdgeInsets.all(2.5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: chat.unreadCount > 0 ? AppColors.goldGradient : null,
                    color: chat.unreadCount > 0 ? null : Colors.white.withOpacity(0.1),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(2), // inner spacing
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.scaffold,
                    ),
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: NetworkImage(chat.userAvatar),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
                if (chat.isOnline)
                  Positioned(
                    right: 4,
                    bottom: 4,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.scaffold, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            
            const SizedBox(width: 16),
            
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                       Text(
                         chat.userName,
                         style: GoogleFonts.plusJakartaSans(
                           fontSize: 16,
                           fontWeight: chat.unreadCount > 0 ? FontWeight.w800 : FontWeight.w600,
                           color: Colors.white,
                         ),
                       ),
                       Text(
                         _formatTime(chat.lastMessageTime),
                         style: GoogleFonts.plusJakartaSans(
                           fontSize: 11,
                           color: chat.unreadCount > 0 ? AppColors.primary : Colors.white24,
                           fontWeight: chat.unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
                         ),
                       ),
                     ],
                   ),
                   const SizedBox(height: 6),
                   Row(
                     children: [
                       Expanded(
                         child: Text(
                           chat.lastMessage,
                           style: GoogleFonts.plusJakartaSans(
                             fontSize: 13,
                             color: chat.unreadCount > 0 ? Colors.white : Colors.white30,
                             fontWeight: chat.unreadCount > 0 ? FontWeight.w500 : FontWeight.normal,
                             letterSpacing: 0.3,
                           ),
                           maxLines: 1,
                           overflow: TextOverflow.ellipsis,
                         ),
                       ),
                       if (chat.unreadCount > 0)
                         Container(
                           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                           decoration: BoxDecoration(
                             color: AppColors.primary,
                             borderRadius: BorderRadius.circular(12),
                             boxShadow: [
                               BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 2))
                             ]
                           ),
                           child: Text(
                             '${chat.unreadCount}',
                             style: GoogleFonts.plusJakartaSans(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold),
                           ),
                         ),
                     ],
                   ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Mesaj balonu - Modern "Custom Shape" Tasarım
class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final isMe = message.senderId == FirebaseAuth.instance.currentUser?.uid;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.fromLTRB(
          isMe ? 64 : 0,
          4,
          isMe ? 0 : 64,
          4,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          // Gradient for me, glass for other
          gradient: isMe ? AppColors.goldGradient : null,
          color: isMe ? null : Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.only(
            topLeft: isMe ? const Radius.circular(20) : const Radius.circular(4),
            topRight: isMe ? const Radius.circular(4) : const Radius.circular(20),
            bottomLeft: const Radius.circular(20),
            bottomRight: const Radius.circular(20),
          ),
          border: Border.all(
            color: isMe ? Colors.transparent : Colors.white.withOpacity(0.05),
          ),
          boxShadow: isMe ? [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ] : null,
        ),
        child: message.type == MessageType.image
            ? ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CachedNetworkImage(
                  imageUrl: message.content,
                  placeholder: (context, url) => Container(
                    height: 200, width: 250,
                    color: Colors.black12,
                    child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  ),
                  errorWidget: (context, url, error) => const SizedBox(
                    height: 100, width: 100,
                    child: Icon(Icons.broken_image, color: Colors.white),
                  ),
                  fit: BoxFit.cover,
                  width: 250,
                ),
              )
            : Text(
                message.content,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  color: isMe ? const Color(0xFF1F1F1F) : Colors.white.withOpacity(0.9),
                  fontWeight: isMe ? FontWeight.w600 : FontWeight.normal,
                  height: 1.4,
                ),
              ),
      ),
    );
  }
}
