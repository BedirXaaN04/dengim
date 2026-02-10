import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/agora_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CallScreen extends StatefulWidget {
  final String userName;
  final String userAvatar;
  final String channelId;
  final bool isVideo;

  const CallScreen({
    super.key,
    required this.userName,
    required this.userAvatar,
    required this.channelId,
    this.isVideo = false,
  });

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  final _agoraService = AgoraService();
  int? _remoteUid;
  bool _localUserJoined = false;
  
  Timer? _timer;
  int _seconds = 0;
  bool _isMuted = false;
  bool _isSpeaker = false;
  bool _isVideoOff = false;

  @override
  void initState() {
    super.initState();
    _initAgora();
    _startTimer();
  }

  Future<void> _initAgora() async {
    await _agoraService.init();
    
    _agoraService.engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          setState(() {
            _localUserJoined = true;
          });
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          setState(() {
            _remoteUid = remoteUid;
          });
        },
        onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
          setState(() {
            _remoteUid = null;
          });
          Navigator.pop(context);
        },
      ),
    );

    await _agoraService.joinChannel(
      channelId: widget.channelId,
      uid: FirebaseAuth.instance.currentUser?.uid.hashCode.abs() ?? 0,
      isVideo: widget.isVideo,
      isHost: false, // Birebir görüşmede communication profili yeterli
    );
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
    _agoraService.leaveChannel();
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
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Remote Video or Placeholder
          _remoteUid != null && widget.isVideo && !_isVideoOff
              ? AgoraVideoView(
                  controller: VideoViewController.remote(
                    rtcEngine: _agoraService.engine,
                    canvas: VideoCanvas(uid: _remoteUid),
                    connection: RtcConnection(channelId: widget.channelId),
                  ),
                )
              : _buildPlaceholder(),

          // Local Preview (Picture-in-picture)
          if (widget.isVideo && _localUserJoined && !_isVideoOff)
            Positioned(
              top: 60,
              right: 20,
              child: Container(
                width: 120,
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white24),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: AgoraVideoView(
                    controller: VideoViewController(
                      rtcEngine: _agoraService.engine,
                      canvas: const VideoCanvas(uid: 0),
                    ),
                  ),
                ),
              ),
            ),

          // Overlay UI
          _buildOverlayUI(),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black, AppColors.primary.withOpacity(0.2), Colors.black],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage: CachedNetworkImageProvider(widget.userAvatar),
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
            if (_remoteUid == null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  'Bağlanıyor...',
                  style: GoogleFonts.plusJakartaSans(color: Colors.white54),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverlayUI() {
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                if (_remoteUid != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _formatDuration(_seconds),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
          ),

          // Controls
          Padding(
            padding: const EdgeInsets.only(bottom: 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildControlBtn(
                  icon: _isMuted ? Icons.mic_off : Icons.mic,
                  isActive: _isMuted,
                  onTap: () {
                    setState(() => _isMuted = !_isMuted);
                    _agoraService.engine.muteLocalAudioStream(_isMuted);
                  },
                ),
                if (widget.isVideo)
                  _buildControlBtn(
                    icon: _isVideoOff ? Icons.videocam_off : Icons.videocam,
                    isActive: _isVideoOff,
                    onTap: () {
                      setState(() => _isVideoOff = !_isVideoOff);
                      _agoraService.engine.muteLocalVideoStream(_isVideoOff);
                    },
                  ),
                _buildControlBtn(
                  icon: _isSpeaker ? Icons.volume_up : Icons.volume_down,
                  isActive: _isSpeaker,
                  onTap: () {
                    setState(() => _isSpeaker = !_isSpeaker);
                    _agoraService.engine.setEnableSpeakerphone(_isSpeaker);
                  },
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.call_end, color: Colors.white, size: 32),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlBtn({required IconData icon, required bool isActive, required VoidCallback onTap}) {
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
