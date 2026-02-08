import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../core/theme/app_colors.dart';
import 'models/chat_models.dart';
import 'widgets/chat_widgets.dart';
import 'services/chat_service.dart';
import 'screens/chat_detail_screen.dart';

import 'package:provider/provider.dart';
import '../../core/providers/chat_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/services/cloudinary_service.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().initConversations();
    });
  }

  void _onChatTap(ChatConversation chat) {
    HapticFeedback.lightImpact();
    context.read<ChatProvider>().markAsRead(chat.id);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChatDetailScreen(
          chatId: chat.id,
          otherUserId: chat.otherUserId,
          otherUserName: chat.otherUserName,
          otherUserAvatar: chat.otherUserAvatar,
        ),
      ),
    );
  }

  /// Sohbeti sil (swipe ile)
  Future<void> _deleteChat(ChatConversation chat) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Sohbeti Sil?', style: GoogleFonts.plusJakartaSans(color: Colors.white)),
        content: Text(
          '${chat.otherUserName} ile olan sohbetiniz silinecek. Bu işlem geri alınamaz.',
          style: GoogleFonts.plusJakartaSans(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      try {
        await ChatService().deleteConversation(chat.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${chat.otherUserName} ile sohbet silindi'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sohbet silinemedi')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: SafeArea(
        child: Column(
          children: [
            // Header Area (remains same)
            _buildHeader(),
            
            const SizedBox(height: 10),

            // Chat List
            Expanded(
              child: Consumer<ChatProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                  }
                  
                  final chats = provider.conversations;
                  
                  if (chats.isEmpty) {
                     return _buildEmptyChats();
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.only(top: 10, bottom: 100, left: 24, right: 24),
                    physics: const BouncingScrollPhysics(),
                    itemCount: chats.length,
                    itemBuilder: (context, index) {
                      final chat = chats[index];
                      return Slidable(
                        key: Key(chat.id),
                        endActionPane: ActionPane(
                          motion: const DrawerMotion(),
                          extentRatio: 0.25,
                          children: [
                            SlidableAction(
                              onPressed: (_) => _deleteChat(chat),
                              backgroundColor: Colors.red.shade800,
                              foregroundColor: Colors.white,
                              icon: Icons.delete_rounded,
                              label: 'Sil',
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ],
                        ),
                        child: ChatListItem(
                          chat: chat,
                          onTap: () => _onChatTap(chat),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                ),
                child: const Icon(Icons.chat_bubble_outline_rounded, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 16),
              Text(
                "MESAJLAR",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2.0,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              _buildIconButton(Icons.more_vert_rounded, () {
                // Menü göster
                HapticFeedback.lightImpact();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Daha fazla seçenek yakında!'),
                    duration: Duration(seconds: 1),
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: 24),
          _buildSearchBar(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 52,
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        boxShadow: [
           BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: Colors.white.withOpacity(0.4)),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              onChanged: (value) {
                // Arama filtreleme
                context.read<ChatProvider>().filterChats(value);
              },
              decoration: InputDecoration(
                hintText: "Sohbetlerde ara...",
                hintStyle: GoogleFonts.plusJakartaSans(color: Colors.white.withOpacity(0.4), fontSize: 13),
                border: InputBorder.none,
              ),
              style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 14),
            ),
          ),
          // Arama temizle butonu
          Consumer<ChatProvider>(
            builder: (context, provider, _) {
              if (provider.searchQuery.isEmpty) return const SizedBox.shrink();
              return GestureDetector(
                onTap: () {
                  provider.clearSearch();
                },
                child: Icon(Icons.close_rounded, color: Colors.white.withOpacity(0.4), size: 20),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyChats() {
    return Center(
       child: Padding(
         padding: const EdgeInsets.symmetric(horizontal: 40),
         child: Column(
           mainAxisAlignment: MainAxisAlignment.center,
           children: [
             Container(
               width: 100,
               height: 100,
               decoration: BoxDecoration(
                 color: AppColors.primary.withOpacity(0.1),
                 shape: BoxShape.circle,
               ),
               child: const Icon(Icons.chat_bubble_outline_rounded, size: 48, color: AppColors.primary),
             ),
             const SizedBox(height: 24),
             Text(
               "Henüz mesajınız yok 💬", 
               style: GoogleFonts.plusJakartaSans(
                 color: Colors.white, 
                 fontSize: 20, 
                 fontWeight: FontWeight.bold,
               ),
             ),
             const SizedBox(height: 12),
             Text(
               "Eşleşmelerinizle sohbet etmeye\nburadan başlayabilirsiniz.", 
               textAlign: TextAlign.center,
               style: GoogleFonts.plusJakartaSans(
                 color: Colors.white38, 
                 fontSize: 14, 
                 height: 1.5,
               ),
             ),
             const SizedBox(height: 28),
             ElevatedButton.icon(
               onPressed: () {
                 // Navigate to discover tab (index 0)
                 // This will be handled by bottom nav - just show toast for now
                 ScaffoldMessenger.of(context).showSnackBar(
                   const SnackBar(
                     content: Text('Keşfet sekmesine gidip yeni kişilerle eşleş!'),
                     duration: Duration(seconds: 2),
                   ),
                 );
               },
               icon: const Icon(Icons.explore_rounded, size: 18),
               label: Text("Keşfetmeye Başla", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
               style: ElevatedButton.styleFrom(
                 backgroundColor: AppColors.primary,
                 foregroundColor: Colors.black,
                 padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
               ),
             ),
           ],
         ),
       ),
     );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44, height: 44,
        decoration: BoxDecoration(
           color: Colors.white.withOpacity(0.05),
           borderRadius: BorderRadius.circular(14),
           border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Icon(icon, color: Colors.white70, size: 22),
      ),
    );
  }
}
