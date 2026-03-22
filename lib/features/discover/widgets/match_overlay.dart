import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/providers/user_provider.dart';
import '../../auth/models/user_profile.dart';

/// Beta B&W Match Overlay — profile photos remain in color,
/// all chrome/UI is pure black and white.
class MatchOverlay extends StatelessWidget {
  final UserProfile matchedUser;
  final VoidCallback onDismiss;
  final VoidCallback onMessage;

  const MatchOverlay({
    super.key,
    required this.matchedUser,
    required this.onDismiss,
    required this.onMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.92),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // MATCH label — tilted B&W neo-brutalist style
            Transform.rotate(
              angle: -0.04,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Colors.white54, offset: Offset(6, 6))],
                ),
                child: Text(
                  'EŞLEŞTİNİZ!',
                  style: GoogleFonts.outfit(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                    letterSpacing: -1.0,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),

            Text(
              'ARTIK ${matchedUser.name.toUpperCase()} İLE KONUŞABİLİRSİN',
              style: GoogleFonts.outfit(
                color: Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),

            const SizedBox(height: 56),

            // Avatars row — photos stay in full color
            Stack(
              alignment: Alignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Consumer<UserProvider>(
                      builder: (context, userProvider, _) {
                        return _buildAvatar(userProvider.currentUser?.imageUrl ?? '');
                      },
                    ),
                    const SizedBox(width: 24),
                    _buildAvatar(matchedUser.imageUrl),
                  ],
                ),
                // Divider heart
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.favorite_rounded, color: Colors.white, size: 28),
                ),
              ],
            ),

            const SizedBox(height: 72),

            // CTA button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: GestureDetector(
                onTap: onMessage,
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      'MESAJ GÖNDER',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                        fontSize: 17,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            TextButton(
              onPressed: onDismiss,
              child: Text(
                'KEŞFETMEYE DEVAM ET',
                style: GoogleFonts.outfit(
                  color: Colors.white38,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(String url) {
    return Container(
      width: 136,
      height: 136,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
      ),
      child: ClipOval(
        child: url.isNotEmpty
            ? CachedNetworkImage(imageUrl: url, fit: BoxFit.cover,
                placeholder: (_, __) => Container(color: Colors.grey[900]))
            : const Icon(Icons.person, size: 56, color: Colors.white),
      ),
    );
  }
}
