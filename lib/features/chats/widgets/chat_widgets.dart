import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:just_audio/just_audio.dart';
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

/// Mesaj balonu - Modern "Custom Shape" Tasarım (Ses mesajı destekli)
class ChatBubble extends StatefulWidget {
  final ChatMessage message;

  const ChatBubble({
    super.key,
    required this.message,
  });

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    if (widget.message.type == MessageType.audio) {
      _initAudio();
    }
  }

  void _initAudio() {
    // Ses URL'sini ve süresini parse et
    final parts = widget.message.content.split('|');
    final audioUrl = parts[0];
    if (parts.length > 1) {
      _duration = Duration(seconds: int.tryParse(parts[1]) ?? 0);
    }

    _audioPlayer.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state.playing;
        });
      }
    });

    _audioPlayer.positionStream.listen((pos) {
      if (mounted) {
        setState(() {
          _position = pos;
        });
      }
    });

    _audioPlayer.durationStream.listen((dur) {
      if (dur != null && mounted) {
        setState(() {
          _duration = dur;
        });
      }
    });
  }

  Future<void> _togglePlay() async {
    final parts = widget.message.content.split('|');
    final audioUrl = parts[0];

    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      try {
        if (_audioPlayer.audioSource == null) {
          await _audioPlayer.setUrl(audioUrl);
        }
        await _audioPlayer.play();
      } catch (e) {
        debugPrint('Audio play error: $e');
      }
    }
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMe = widget.message.senderId == FirebaseAuth.instance.currentUser?.uid;
    final hasReactions = widget.message.reactions.isNotEmpty;
    final hasReply = widget.message.replyToContent != null;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // Yanıt gösterimi (varsa)
          if (hasReply)
            Container(
              margin: EdgeInsets.fromLTRB(isMe ? 64 : 0, 4, isMe ? 0 : 64, 2),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border(
                  left: BorderSide(
                    color: isMe ? AppColors.primary : Colors.white38,
                    width: 3,
                  ),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.reply, size: 12, color: Colors.white38),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      widget.message.replyToContent!,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: Colors.white54,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          
          // Ana mesaj balonu
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                margin: EdgeInsets.fromLTRB(
                  isMe ? 64 : 0,
                  4,
                  isMe ? 0 : 64,
                  hasReactions ? 12 : 4,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
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
                child: Column(
                  crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    if (widget.message.storyReply != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (widget.message.storyReply!['storyUrl'] != null)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: CachedNetworkImage(
                                  imageUrl: widget.message.storyReply!['storyUrl'],
                                  width: 40,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(color: Colors.grey[800]),
                                  errorWidget: (context, url, error) => const Icon(Icons.broken_image, size: 20, color: Colors.white54),
                                ),
                              ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Hikayeye Yanıt", style: GoogleFonts.plusJakartaSans(fontSize: 10, color: Colors.white54, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 2),
                                  const Icon(Icons.reply, color: Colors.white54, size: 14),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                        ),
                      ),
                    _buildMessageContent(isMe),
                    
                    // Zaman damgası
                    const SizedBox(height: 6),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _formatTime(widget.message.timestamp),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            color: isMe ? Colors.black45 : Colors.white38,
                          ),
                        ),
                        if (isMe) ...[
                          const SizedBox(width: 4),
                          _buildReadReceipt(),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              
              // Tepkiler (mesajın altında)
              if (hasReactions)
                Positioned(
                  bottom: 0,
                  right: isMe ? 8 : null,
                  left: isMe ? null : 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: widget.message.reactions.values.map((emoji) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 1),
                          child: Text(emoji, style: const TextStyle(fontSize: 14)),
                        );
                      }).toList(),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildMessageContent(bool isMe) {
    switch (widget.message.type) {
      case MessageType.image:
        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: CachedNetworkImage(
            imageUrl: widget.message.content,
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
        );
      
      case MessageType.audio:
        return _buildAudioPlayer(isMe);
      
      case MessageType.text:
      default:
        return Text(
          widget.message.content,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            color: isMe ? const Color(0xFF1F1F1F) : Colors.white.withOpacity(0.9),
            fontWeight: isMe ? FontWeight.w600 : FontWeight.normal,
            height: 1.4,
          ),
        );
    }
  }

  Widget _buildAudioPlayer(bool isMe) {
    final progress = _duration.inMilliseconds > 0 
        ? _position.inMilliseconds / _duration.inMilliseconds 
        : 0.0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Play/Pause Button
        GestureDetector(
          onTap: _togglePlay,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isMe ? Colors.black.withOpacity(0.2) : AppColors.primary.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              color: isMe ? Colors.black87 : AppColors.primary,
              size: 24,
            ),
          ),
        ),
        const SizedBox(width: 12),
        
        // Waveform / Progress
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress bar
              Container(
                height: 4,
                decoration: BoxDecoration(
                  color: isMe ? Colors.black.withOpacity(0.1) : Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progress.clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isMe ? Colors.black87 : AppColors.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              // Duration
              Text(
                _isPlaying ? _formatDuration(_position) : _formatDuration(_duration),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: isMe ? Colors.black54 : Colors.white54,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        
        // Microphone icon
        Icon(
          Icons.mic,
          size: 16,
          color: isMe ? Colors.black38 : Colors.white38,
        ),
      ],
    );
  }

  /// Read Receipt Indicator
  Widget _buildReadReceipt() {
    // Üç durum: Gönderildi (✓), İletildi (✓✓), Okundu (✓✓ mavi)
    final bool isSent = true; // Her mesaj gönderilmiş kabul edilir
    final bool isDelivered = widget.message.isRead; // Şu an read = delivered olarak kullanılıyor
    final bool isRead = widget.message.isRead;
    
    IconData icon;
    Color color;
    
    if (isRead) {
      icon = Icons.done_all; // ✓✓
      color = const Color(0xFF10B981); // Green - okundu
    } else if (isDelivered) {
      icon = Icons.done_all; // ✓✓  
      color = Colors.black38; // Gray - iletildi
    } else if (isSent) {
      icon = Icons.done; // ✓
      color = Colors.black38; // Gray - gönderildi
    } else {
      icon = Icons.schedule; // ⏱
      color = Colors.black26; // Lighter gray - gönder iliyor
    }
    
    return Icon(icon, size: 14, color: color);
  }
}
