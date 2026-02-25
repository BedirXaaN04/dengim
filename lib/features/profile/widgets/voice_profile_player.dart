import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import '../../../core/theme/app_colors.dart';

class VoiceProfilePlayer extends StatefulWidget {
  final String audioUrl;
  const VoiceProfilePlayer({super.key, required this.audioUrl});

  @override
  State<VoiceProfilePlayer> createState() => _VoiceProfilePlayerState();
}

class _VoiceProfilePlayerState extends State<VoiceProfilePlayer> {
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    try {
      await _player.setUrl(widget.audioUrl);
      _player.playerStateStream.listen((state) {
        if (mounted) {
          setState(() {
            _isPlaying = state.playing;
            if (state.processingState == ProcessingState.completed) {
               _isPlaying = false;
               _player.seek(Duration.zero);
               _player.pause();
            }
          });
        }
      });
    } catch (e) {
      debugPrint("Error loading voice profile: $e");
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (_isPlaying) {
          _player.pause();
        } else {
          _player.play();
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _isPlaying ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black, width: 2),
          boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(4, 4))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             Icon(
               _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
               color: Colors.black,
               size: 32,
             ),
             const SizedBox(width: 12),
             Text(
               _isPlaying ? 'SESİ DURDUR' : 'SESİ DİNLE',
               style: GoogleFonts.outfit(
                 color: Colors.black,
                 fontWeight: FontWeight.w900,
                 fontSize: 16,
               ),
             ),
          ],
        ),
      ),
    );
  }
}
