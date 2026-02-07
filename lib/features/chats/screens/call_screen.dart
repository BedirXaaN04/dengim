import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dengim/core/theme/app_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CallScreen extends StatefulWidget {
  final String userName;
  final String userAvatar;
  final bool isVideo;

  const CallScreen({
    super.key,
    required this.userName,
    required this.userAvatar,
    this.isVideo = false,
  });

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  Timer? _timer;
  int _seconds = 0;
  bool _isMuted = false;
  bool _isSpeaker = false;
  bool _isVideoOff = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _seconds++;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatDuration(int seconds) {
    final int minutes = seconds ~/ 60;
    final int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E), // Dark background
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image (Blurred)
          if (widget.isVideo && !_isVideoOff)
             CachedNetworkImage(
               imageUrl: widget.userAvatar,
               fit: BoxFit.cover,
               color: Colors.black.withOpacity(0.3),
               colorBlendMode: BlendMode.darken,
             )
          else
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black, AppColors.primary.withOpacity(0.2), Colors.black],
                ),
              ),
            ),
            
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Header Info
                Column(
                  children: [
                    const SizedBox(height: 40),
                    if (!widget.isVideo || _isVideoOff)
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primary, width: 2),
                        ),
                        child: CircleAvatar(
                          radius: 60,
                          backgroundImage: NetworkImage(widget.userAvatar),
                        ),
                      ),
                    const SizedBox(height: 24),
                    Text(
                      widget.userName,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatDuration(_seconds),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        color: Colors.white70,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),

                // Controls
                Padding(
                  padding: const EdgeInsets.only(bottom: 48),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildControlBtn(
                        icon: _isMuted ? Icons.mic_off : Icons.mic,
                        isActive: _isMuted,
                        onTap: () => setState(() => _isMuted = !_isMuted),
                      ),
                      if (widget.isVideo)
                         _buildControlBtn(
                          icon: _isVideoOff ? Icons.videocam_off : Icons.videocam,
                          isActive: _isVideoOff,
                          onTap: () => setState(() => _isVideoOff = !_isVideoOff),
                        ),
                         
                      _buildControlBtn(
                         icon: _isSpeaker ? Icons.volume_up : Icons.volume_off,
                         isActive: _isSpeaker,
                         onTap: () => setState(() => _isSpeaker = !_isSpeaker),
                      ),
                      
                      // End Call
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: Colors.redAccent, blurRadius: 20, spreadRadius: 2)
                            ]
                          ),
                          child: const Icon(Icons.call_end, color: Colors.white, size: 32),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlBtn({
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.white.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isActive ? Colors.black : Colors.white,
          size: 28,
        ),
      ),
    );
  }
}
