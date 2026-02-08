import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dengim/core/theme/app_colors.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../models/chat_models.dart';
import '../services/chat_service.dart';
import '../../auth/services/report_service.dart';
import '../widgets/chat_widgets.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/services/audio_recorder_service.dart';
import '../../../core/services/cloudinary_service.dart';
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
  bool _isUploading = false;
  bool _isRecording = false;
  int _recordingDuration = 0;
  
  // Yanıt verme için
  ChatMessage? _replyingTo;
  
  // Tepki emojileri
  static const List<String> _reactionEmojis = ['❤️', '😂', '😮', '😢', '😡', '👍'];

  @override
  void initState() {
    super.initState();
    _chatService.markAsRead(widget.chatId);
    
    // Ses kaydı callback'leri
    _audioRecorder.onDurationUpdate = (duration) {
      if (mounted) setState(() => _recordingDuration = duration);
    };
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _audioRecorder.dispose();
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
                    backgroundColor: AppColors.surface,
                    title: Text('Kullanıcıyı Engelle?', style: GoogleFonts.plusJakartaSans(color: Colors.white)),
                    content: Text(
                      '${widget.otherUserName} engellendi mi, size mesaj gönderemeyecek.',
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
                        child: const Text('Engelle'),
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
                    backgroundColor: AppColors.surface,
                    title: Text('Sohbeti Sil?', style: GoogleFonts.plusJakartaSans(color: Colors.white)),
                    content: Text(
                      'Bu sohbet silinecek. Bu işlem geri alınamaz.',
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
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage(widget.otherUserAvatar),
            ),
            const SizedBox(width: 12),
            Text(
              widget.otherUserName,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.call, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CallScreen(
                    userName: widget.otherUserName,
                    userAvatar: widget.otherUserAvatar,
                    isVideo: false,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.videocam, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CallScreen(
                    userName: widget.otherUserName,
                    userAvatar: widget.otherUserAvatar,
                    isVideo: true,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
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
                      'Henüz mesaj yok',
                      style: GoogleFonts.plusJakartaSans(color: Colors.white54),
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
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.1)),
          left: BorderSide(color: AppColors.primary, width: 4),
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
                  'Yanıt veriliyor',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _replyingTo!.content.length > 50 
                      ? '${_replyingTo!.content.substring(0, 50)}...'
                      : _replyingTo!.content,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: Colors.white70,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white54, size: 20),
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
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
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
        backgroundColor: AppColors.surface,
        title: Text('Rapor Nedeni', style: GoogleFonts.plusJakartaSans(color: Colors.white)),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: ReportReason.values.length,
            itemBuilder: (context, index) {
              final reason = ReportReason.values[index];
              if (reason == ReportReason.other) return const SizedBox.shrink(); 
              
              return ListTile(
                title: Text(reason.displayName, style: GoogleFonts.plusJakartaSans(color: Colors.white70)),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.1)),
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
              style: GoogleFonts.plusJakartaSans(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Mesaj yaz...',
                hintStyle: GoogleFonts.plusJakartaSans(color: Colors.white38),
                filled: true,
                fillColor: AppColors.scaffold,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
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
              gradient: AppColors.goldGradient,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.black),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade900.withOpacity(0.3),
        border: Border(
          top: BorderSide(color: Colors.red.withOpacity(0.3)),
        ),
      ),
      child: Row(
        children: [
          // İptal butonu
          IconButton(
            icon: const Icon(Icons.close, color: Colors.red),
            onPressed: _cancelRecording,
          ),
          
          const SizedBox(width: 8),
          
          // Kayıt göstergesi
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.5),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
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
                  'Ses kaydediliyor...',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AudioRecorderService.formatDuration(_recordingDuration),
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          
          // Gönder butonu
          Container(
            decoration: BoxDecoration(
              gradient: AppColors.goldGradient,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.black),
              onPressed: _stopAndSendRecording,
            ),
          ),
        ],
      ),
    );
  }

  /// Ses kaydını başlat
  Future<void> _startRecording() async {
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

