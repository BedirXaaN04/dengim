import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import 'models/chat_models.dart';
import 'widgets/chat_widgets.dart';
import 'services/chat_service.dart';

import 'package:provider/provider.dart';
import '../../core/providers/chat_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
        builder: (context) => ChatDetailScreen(chat: chat),
      ),
    );
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
                      return ChatListItem(
                        chat: chats[index],
                        onTap: () => _onChatTap(chats[index]),
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
              _buildIconButton(Icons.edit_note_rounded, () {}),
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
              decoration: InputDecoration(
                hintText: "Sohbetlerde ara...",
                hintStyle: GoogleFonts.plusJakartaSans(color: Colors.white.withOpacity(0.4), fontSize: 13),
                border: InputBorder.none,
              ),
              style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyChats() {
    return Center(
       child: Column(
         mainAxisAlignment: MainAxisAlignment.center,
         children: [
           Container(
             padding: const EdgeInsets.all(20),
             decoration: BoxDecoration(
               color: AppColors.primary.withOpacity(0.05),
               shape: BoxShape.circle,
             ),
             child: Icon(Icons.mark_chat_unread_outlined, size: 40, color: AppColors.primary.withOpacity(0.5)),
           ),
           const SizedBox(height: 16),
           Text(
             "Henüz mesaj yok", 
             style: GoogleFonts.plusJakartaSans(
               color: Colors.white30, 
               fontSize: 14, 
               fontWeight: FontWeight.bold,
               letterSpacing: 0.5
             ),
           ),
         ],
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

class ChatDetailScreen extends StatefulWidget {
  final ChatConversation chat;
  const ChatDetailScreen({super.key, required this.chat});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _controller = TextEditingController();
  final ChatService _service = ChatService();

  void _send() {
    if (_controller.text.trim().isEmpty) return;
    _service.sendMessage(widget.chat.id, _controller.text.trim(), widget.chat.otherUserId);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              color: AppColors.scaffold.withOpacity(0.8),
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top, bottom: 10, left: 8, right: 16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  
                  // User Avatar
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.goldGradient,
                    ),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.scaffold,
                      child: ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: widget.chat.otherUserAvatar,
                          width: 36,
                          height: 36,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(color: AppColors.surface),
                          errorWidget: (context, url, error) => const Icon(Icons.person),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Name & Status
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.chat.otherUserName.toUpperCase(),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                            color: Colors.white,
                          ),
                        ),
                        Row(
                          children: [
                            if (widget.chat.otherUserOnline)
                              Container(width: 6, height: 6, margin: const EdgeInsets.only(right: 6), decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle)),
                            Text(
                              widget.chat.otherUserOnline ? "AKTİF" : "ÇEVRİMDIŞI",
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                color: widget.chat.otherUserOnline ? AppColors.success : Colors.white30,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Actions
                  _buildHeaderButton(Icons.call),
                  const SizedBox(width: 12),
                  _buildHeaderButton(Icons.videocam_rounded),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<ChatMessage>>(
               stream: _service.getMessages(widget.chat.id),
               builder: (context, snapshot) {
                 final messages = snapshot.data ?? [];
                 return ListView.builder(
                   reverse: true,
                   padding: const EdgeInsets.fromLTRB(20, 120, 20, 20),
                   physics: const BouncingScrollPhysics(),
                   itemCount: messages.length,
                   itemBuilder: (context, index) => ChatBubble(message: messages[index]),
                 );
               },
            ),
          ),
          
          _buildInput(),
        ],
      ),
    );
  }

  Widget _buildHeaderButton(IconData icon) {
    return Container(
      width: 40, height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Icon(icon, color: Colors.white70, size: 20),
    );
  }

  Widget _buildInput() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).padding.bottom + 20),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A).withOpacity(0.9),
            border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add_rounded, color: Colors.white70, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: Center(
                    child: TextField(
                      controller: _controller,
                      style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: "Bir mesaj yaz...",
                        hintStyle: GoogleFonts.plusJakartaSans(color: Colors.white30),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () {
                   HapticFeedback.lightImpact();
                   _send();
                },
                child: Container(
                  width: 50, height: 50,
                  decoration: const BoxDecoration(
                    gradient: AppColors.goldGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.send_rounded, color: Colors.black, size: 22),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
