import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../../core/theme/app_colors.dart';
import '../models/chat_models.dart';
import 'chat_widgets.dart'; // Ensure ChatBubble is accessible

class ChatListItemData extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;
  final ValueChanged<ChatMessage> onReply;
  final ValueChanged<ChatMessage> onDelete;
  final void Function(ChatMessage, String) onQuickReact;
  final ValueChanged<ChatMessage> onLongPress;

  const ChatListItemData({
    super.key,
    required this.message,
    required this.isMe,
    required this.onReply,
    required this.onDelete,
    required this.onQuickReact,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: Key(message.id),
      // Sağa swipe: Yanıt ver
      startActionPane: ActionPane(
        motion: const BehindMotion(),
        extentRatio: 0.25,
        children: [
          SlidableAction(
            onPressed: (_) => onReply(message),
            backgroundColor: AppColors.primary.withOpacity(0.8),
            foregroundColor: Colors.black,
            icon: Icons.reply_rounded,
            label: 'Yanıtla',
            borderRadius: BorderRadius.circular(12),
          ),
        ],
      ),
      // Sola swipe: Sil (sadece kendi mesajlarım)
      endActionPane: isMe ? ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.25,
        children: [
          SlidableAction(
            onPressed: (_) => onDelete(message),
            backgroundColor: Colors.red.shade800,
            foregroundColor: Colors.white,
            icon: Icons.delete_rounded,
            label: 'Sil',
            borderRadius: BorderRadius.circular(12),
          ),
        ],
      ) : null,
      child: GestureDetector(
        // Double-tap: Hızlı ❤️ tepki (Instagram DM tarzı)
        onDoubleTap: () => onQuickReact(message, '❤️'),
        // Long-press: Tepki seçici aç
        onLongPress: () => onLongPress(message),
        child: ChatBubble(
          message: message,
        ),
      ),
    );
  }
}
