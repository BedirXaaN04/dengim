import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/log_service.dart';
import '../../../core/services/audio_recorder_service.dart';
import '../../../core/services/cloudinary_service.dart';
import '../../../core/services/typing_indicator_service.dart';
import '../../../core/widgets/online_status_indicator.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/services/feature_flag_service.dart';

import '../models/chat_models.dart';
import '../services/chat_service.dart';
import '../widgets/chat_widgets.dart';
import '../../auth/services/report_service.dart';
import '../../payment/premium_offer_screen.dart';
import 'call_screen.dart';

class ChatDetailScreen extends StatefulWidget {
  final String chatId;
  final String otherUserId;
  final String otherUserName;
  final String otherUserAvatar;

  const ChatDetailScreen({
    super.key,
    required this.chatId,
    required this.otherUserId,
    required this.otherUserName,
    required this.otherUserAvatar,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final AudioRecorderService _audioRecorder = AudioRecorderService();
  final TypingIndicatorService _typingService = TypingIndicatorService();
  bool _isUploading = false;
  bool _isRecording = false;
  int _recordingDuration = 0;
  
  // Yanıt verme için
  ChatMessage? _replyingTo;
  
  // Tepki emojileri
  static const List<String> _reactionEmojis = ['❤️', '😂', '😮', '😢', '😡', '👍'];

  StreamSubscription? _conversationSubscription;

  @override
  void initState() {
    super.initState();
    _chatService.markAsRead(widget.chatId);
    
    // Listen for new messages while in this screen to clear unread count
    _conversationSubscription = FirebaseFirestore.instance
        .collection('conversations')
        .doc(widget.chatId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data();
        final unreadCounts = data?['unreadCounts'] as Map<String, dynamic>?;
        final uid = FirebaseAuth.instance.currentUser?.uid;
        if (uid != null && (unreadCounts?[uid] ?? 0) > 0) {
          _chatService.markAsRead(widget.chatId);
        }
      }
    });

    // Ses kaydı callback'leri
    _audioRecorder.onDurationUpdate = (duration) {
      if (mounted) setState(() => _recordingDuration = duration);
    };
  }

  @override
  void dispose() {
    _conversationSubscription?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    _audioRecorder.dispose();
    _typingService.stopTyping(widget.chatId);
    super.dispose();
  }

  void _sendMessage() {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    // Yanıtlı mesaj mı?
    if (_replyingTo != null) {
      _chatService.sendReplyMessage(
        widget.chatId,
        content,
        widget.otherUserId,
        _replyingTo!.id,
        _replyingTo!.content,
      );
      setState(() => _replyingTo = null);
    } else {
      _chatService.sendMessage(
        widget.chatId,
        content,
        widget.otherUserId,
      );
    }
    _messageController.clear();
  }

  Future<void> _pickAndSendImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);

    if (image != null) {
      setState(() => _isUploading = true);
      try {
        ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('Fotoğraf gönderiliyor...'), duration: Duration(seconds: 1)),
        );
        
        await _chatService.sendImage(widget.chatId, image, widget.otherUserId);
        
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Fotoğraf gönderilemedi.')),
          );
        }
      } finally {
        if (mounted) setState(() => _isUploading = false);
      }
    }
  }

  void _showMessageOptions(ChatMessage message) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: Text(
                'Mesajı Sil',
                style: GoogleFonts.plusJakartaSans(color: Colors.red),
              ),
              onTap: () async {
                Navigator.pop(context);
                await _chatService.deleteMessage(widget.chatId, message.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Mesaj silindi')),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showChatOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.flag_outlined, color: Colors.amber),
              title: Text(
                'Kullanıcıyı Raporla',
                style: GoogleFonts.plusJakartaSans(color: Colors.amber),
              ),
              onTap: () {
                Navigator.pop(context);
                _showReportDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.block, color: Colors.orange),
              title: Text(
                'Kullanıcıyı Engelle',
                style: GoogleFonts.plusJakartaSans(color: Colors.orange),
              ),
              onTap: () async {
                Navigator.pop(context);
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                      side: const BorderSide(color: Colors.black, width: 4),
                    ),
                    title: Text('KULLANICIYI ENGELLE?', style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.w900)),
                    content: Text(
                      '${widget.otherUserName} ENGELLENSİN Mİ? SİZE MESAJ GÖNDEREMEYECEK.',
                      style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.w700),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text('İPTAL', style: GoogleFonts.outfit(color: AppColors.textSecondary, fontWeight: FontWeight.w900)),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: TextButton.styleFrom(foregroundColor: AppColors.red),
                        child: Text('ENGELLE', style: GoogleFonts.outfit(color: AppColors.red, fontWeight: FontWeight.w900)),
                      ),
                    ],
                  ),
                );
                
                if (confirm == true) {
                  await _chatService.blockUser(widget.otherUserId);
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${widget.otherUserName} engellendi')),
                    );
                  }
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_sweep, color: Colors.red),
              title: Text(
                'Sohbeti Sil',
                style: GoogleFonts.plusJakartaSans(color: Colors.red),
              ),
              onTap: () async {
                Navigator.pop(context);
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                      side: const BorderSide(color: Colors.black, width: 4),
                    ),
                    title: Text('SOHBETİ SİL?', style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.w900)),
                    content: Text(
                      'BU SOHBET SİLİNECEK. BU İŞLEM GERİ ALINAMAZ.',
                      style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.w700),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text('İPTAL', style: GoogleFonts.outfit(color: AppColors.textSecondary, fontWeight: FontWeight.w900)),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: TextButton.styleFrom(foregroundColor: AppColors.red),
                        child: Text('SİL', style: GoogleFonts.outfit(color: AppColors.red, fontWeight: FontWeight.w900)),
                      ),
                    ],
                  ),
                );
                
                if (confirm == true) {
                  await _chatService.deleteConversation(widget.chatId);
                  if (mounted) {
                    Navigator.pop(context);
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return const SizedBox();

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        shape: const Border(bottom: BorderSide(color: Colors.black, width: 4)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            OnlineStatusBadge(
              userId: widget.otherUserId,
              badgeSize: 12,
              child: CircleAvatar(
                radius: 18,
                backgroundImage: NetworkImage(widget.otherUserAvatar),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.otherUserName.toUpperCase(),
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                      letterSpacing: -0.5,
                    ),
                  ),
                  LastSeenText(
                    userId: widget.otherUserId,
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      color: Colors.black.withOpacity(0.5),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.call, color: Colors.black, size: 22),
            onPressed: () {
              final userProvider = context.read<UserProvider>();
              final userTier = userProvider.currentUser?.subscriptionTier ?? 'free';
              
              if (userTier == 'free') {
                 Navigator.push(context, MaterialPageRoute(builder: (_) => PremiumOfferScreen()));
                 return;
              }

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CallScreen(
                    channelId: widget.chatId,
                    userName: widget.otherUserName,
                    userAvatar: widget.otherUserAvatar,
                    isVideo: false,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.videocam, color: Colors.black, size: 24),
            onPressed: () {
              final userProvider = context.read<UserProvider>();
              final userTier = userProvider.currentUser?.subscriptionTier ?? 'free';
              
              if (!FeatureFlagService().isVideoCallEnabled(userTier)) {
                Navigator.push(context, MaterialPageRoute(builder: (_) => PremiumOfferScreen()));
                return;
              }

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CallScreen(
                    channelId: widget.chatId,
                    userName: widget.otherUserName,
                    userAvatar: widget.otherUserAvatar,
                    isVideo: true,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black, size: 24),
            onPressed: _showChatOptions,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<ChatMessage>>(
              stream: _chatService.getMessages(widget.chatId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      'HENÜZ MESAJ YOK',
                      style: GoogleFonts.outfit(color: Colors.black.withOpacity(0.3), fontWeight: FontWeight.w900, fontSize: 12),
                    ),
                  );
                }

                final messages = snapshot.data!
                    .where((m) => !m.deletedFor.contains(currentUser.uid))
                    .toList();

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.isMe(currentUser.uid);

                    // Swipe ile yanıt verme veya silme
                    return Slidable(
                      key: Key(message.id),
                      // Sağa swipe: Yanıt ver
                      startActionPane: ActionPane(
                        motion: const BehindMotion(),
                        extentRatio: 0.25,
                        children: [
                          SlidableAction(
                            onPressed: (_) => _setReply(message),
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
                            onPressed: (_) => _deleteMessage(message),
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
                        onDoubleTap: () => _quickReact(message, '❤️'),
                        // Long-press: Tepki seçici aç
                        onLongPress: () => _showReactionPicker(message),
                        child: ChatBubble(
                          message: message,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          
          // Typing Indicator
          TypingIndicator(
            chatId: widget.chatId,
            otherUserId: widget.otherUserId,
            color: AppColors.primary,
          ),
          
          // Yanıt önizlemesi
          if (_replyingTo != null) _buildReplyPreview(),
          
          // Ses kaydı yapılırken gösterilen UI
          if (_isRecording)
            _buildRecordingUI()
          else
            _buildInputBar(),
        ],
      ),
    );
  }

  /// Yanıt önizlemesi
  Widget _buildReplyPreview() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.black, width: 2),
          left: BorderSide(color: AppColors.primary, width: 6),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'YANIT VERİLİYOR',
                  style: GoogleFonts.outfit(
                    fontSize: 10,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _replyingTo!.content.length > 50 
                      ? '${_replyingTo!.content.substring(0, 50)}...'
                      : _replyingTo!.content,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.black, size: 20),
            onPressed: () => setState(() => _replyingTo = null),
          ),
        ],
      ),
    );
  }

  /// Yanıt modunu ayarla
  void _setReply(ChatMessage message) {
    setState(() => _replyingTo = message);
    // Klavyeyi aç
    FocusScope.of(context).requestFocus(FocusNode());
  }

  /// Hızlı tepki ekle (double-tap)
  void _quickReact(ChatMessage message, String emoji) {
    _chatService.addReaction(widget.chatId, message.id, emoji);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$emoji tepkisi eklendi!'),
        duration: const Duration(milliseconds: 800),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.surfaceLight,
      ),
    );
  }

  /// Tepki seçici aç
  void _showReactionPicker(ChatMessage message) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 100,
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.black, width: 3),
          boxShadow: const [
            BoxShadow(
              color: Colors.black,
              offset: Offset(4, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _reactionEmojis.map((emoji) {
                return GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    _chatService.addReaction(widget.chatId, message.id, emoji);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    child: Text(emoji, style: const TextStyle(fontSize: 28)),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _showReportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Colors.black, width: 4),
        ),
        title: Text('RAPOR NEDENİ', style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.w900)),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: ReportReason.values.length,
            itemBuilder: (context, index) {
              final reason = ReportReason.values[index];
              if (reason == ReportReason.other) return const SizedBox.shrink(); 
              
              return ListTile(
                title: Text(reason.displayName, style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.w800)),
                onTap: () {
                  Navigator.pop(context);
                  _submitReport(reason);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitReport(ReportReason reason) async {
    try {
      final success = await ReportService().reportUser(
        reportedUserId: widget.otherUserId,
        reason: reason,
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Raporunuz alındı. Teşekkür ederiz.'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Bu kullanıcıyı zaten raporladınız veya bir hata oluştu.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bir hata oluştu.')),
        );
      }
    }
  }

  /// Mesajı sil (swipe ile)
  Future<void> _deleteMessage(ChatMessage message) async {
    try {
      await _chatService.deleteMessage(widget.chatId, message.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mesaj silindi'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mesaj silinemedi')),
        );
      }
    }
  }

  /// Normal input bar (metin, fotoğraf, mikrofon)
  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.black, width: 4),
        ),
      ),
      child: Row(
        children: [
          // Fotoğraf butonu
          IconButton(
            icon: _isUploading 
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))
                : const Icon(Icons.image, color: AppColors.primary),
            onPressed: _isUploading ? null : _pickAndSendImage,
          ),
          
          // Mikrofon butonu
          IconButton(
            icon: const Icon(Icons.mic, color: AppColors.primary),
            onPressed: _startRecording,
          ),
          
          Expanded(
            child: TextField(
              controller: _messageController,
              style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.w700),
              onChanged: (text) {
                if (text.isNotEmpty) {
                  _typingService.startTyping(widget.chatId);
                } else {
                  _typingService.stopTyping(widget.chatId);
                }
              },
              decoration: InputDecoration(
                hintText: 'MESAJ YAZ...',
                hintStyle: GoogleFonts.outfit(color: Colors.black.withOpacity(0.3), fontWeight: FontWeight.w900, fontSize: 12),
                filled: true,
                fillColor: AppColors.scaffold,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Colors.black, width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Colors.black, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 12),
          
          // Gönder butonu
          Container(
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black, width: 2),
              boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(2, 2))],
            ),
            child: IconButton(
              icon: const Icon(Icons.send_rounded, color: Colors.black),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  /// Ses kaydı yapılırken gösterilen UI
  Widget _buildRecordingUI() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.black, width: 4),
        ),
      ),
      child: Row(
        children: [
          // İptal butonu
          IconButton(
            icon: const Icon(Icons.close_rounded, color: AppColors.red),
            onPressed: _cancelRecording,
          ),
          
          const SizedBox(width: 8),
          
          // Kayıt göstergesi
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: AppColors.red,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black, width: 1.5),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Süre
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'SES KAYDEDİLİYOR...',
                  style: GoogleFonts.outfit(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  AudioRecorderService.formatDuration(_recordingDuration),
                  style: GoogleFonts.outfit(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          
          // Gönder butonu
          Container(
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black, width: 2),
              boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(2, 2))],
            ),
            child: IconButton(
              icon: const Icon(Icons.send_rounded, color: Colors.black),
              onPressed: _stopAndSendRecording,
            ),
          ),
        ],
      ),
    );
  }

  /// Ses kaydını başlat
  Future<void> _startRecording() async {
    final userProvider = context.read<UserProvider>();
    final userTier = userProvider.currentUser?.subscriptionTier ?? 'free';
    
    if (!FeatureFlagService().isVoiceMessageEnabled(userTier)) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => PremiumOfferScreen()));
      return;
    }

    final started = await _audioRecorder.startRecording();
    if (started) {
      setState(() {
        _isRecording = true;
        _recordingDuration = 0;
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mikrofon erişimi için izin vermeniz gerekiyor'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  /// Ses kaydını durdur ve gönder
  Future<void> _stopAndSendRecording() async {
    if (!_isRecording) return;
    
    setState(() => _isUploading = true);
    
    try {
      final filePath = await _audioRecorder.stopRecording();
      final duration = _recordingDuration;
      
      setState(() {
        _isRecording = false;
        _recordingDuration = 0;
      });
      
      if (filePath == null) {
        throw Exception('Ses kaydı alınamadı');
      }
      
      // Dosyayı yükle
      final file = File(filePath);
      final bytes = await file.readAsBytes();
      final audioUrl = await CloudinaryService.uploadAudioBytes(bytes);
      
      if (audioUrl != null) {
        // Mesaj olarak gönder
        await _chatService.sendVoiceMessage(
          widget.chatId, 
          audioUrl, 
          widget.otherUserId,
          durationSeconds: duration,
        );
        
        // Geçici dosyayı sil
        if (await file.exists()) {
          await file.delete();
        }
      } else {
        throw Exception('Ses yüklenemedi');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ses mesajı gönderilemedi'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  /// Ses kaydını iptal et
  Future<void> _cancelRecording() async {
    await _audioRecorder.cancelRecording();
    setState(() {
      _isRecording = false;
      _recordingDuration = 0;
    });
  }
}

