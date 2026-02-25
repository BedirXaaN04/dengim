import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/user_provider.dart';
import '../../auth/models/user_profile.dart';

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
        color: Colors.black.withOpacity(0.9), // Darker, more dramatic back
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Floating 'MATCH' tag
            Transform.rotate(
              angle: -0.05,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: const [
                    BoxShadow(color: Colors.white, offset: Offset(8, 8)),
                  ],
                ),
                child: Text(
                  "EŞLEŞTİNİZ!",
                  style: GoogleFonts.outfit(
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                    letterSpacing: -1.0,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 48),
            
            Text(
              "ARTIK ${matchedUser.name.toUpperCase()} İLE KONUŞABİLİRSİN",
              style: GoogleFonts.outfit(
                color: Colors.white, 
                fontSize: 14, 
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2
              ),
            ),
            
            const SizedBox(height: 60),
            
            // Avatars
            Stack(
              alignment: Alignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Me
                    Consumer<UserProvider>(
                      builder: (context, userProvider, _) {
                        final myAvatar = userProvider.currentUser?.imageUrl ?? '';
                        return _buildMatchAvatar(myAvatar, isMe: true);
                      },
                    ),
                    const SizedBox(width: 20),
                    // Them
                    _buildMatchAvatar(matchedUser.imageUrl, isMe: false),
                  ],
                ),
                // Heart in middle
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black, width: 3),
                  ),
                  child: const Icon(Icons.favorite_rounded, color: AppColors.red, size: 32),
                ),
              ],
            ),
            
            const SizedBox(height: 80),
            
            // Actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: _buildNeoMatchButton(
                label: "MESAJ GÖNDER",
                color: AppColors.primary,
                onTap: onMessage, 
              ),
            ),
            
            const SizedBox(height: 16),
            
            TextButton(
              onPressed: onDismiss,
              child: Text(
                "KEŞFETMEYE DEVAM ET", 
                style: GoogleFonts.outfit(
                  color: Colors.white.withOpacity(0.6), 
                  fontSize: 13, 
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                )
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchAvatar(String url, {required bool isMe}) {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: isMe ? AppColors.blue : AppColors.secondary, width: 4),
        boxShadow: [
          BoxShadow(
            color: isMe ? AppColors.blue.withOpacity(0.5) : AppColors.secondary.withOpacity(0.5), 
            blurRadius: 20, 
            spreadRadius: 5
          ),
        ],
      ),
      child: ClipOval(
        child: url.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(color: Colors.white10),
              )
            : const Icon(Icons.person, size: 60, color: Colors.black),
      ),
    );
  }

  Widget _buildNeoMatchButton({required String label, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: const [
            BoxShadow(color: Colors.white, offset: Offset(4, 4)),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.w900, 
              color: Colors.black, 
              fontSize: 18,
              letterSpacing: 1.0
            ),
          ),
        ),
      ),
    );
  }
}
