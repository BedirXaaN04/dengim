import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/user_provider.dart';
import '../../auth/models/user_profile.dart';
import '../../payment/premium_offer_screen.dart';

class TopPicksSection extends StatelessWidget {
  final List<UserProfile> activeUsers;
  final Function(UserProfile) onCardTap;

  const TopPicksSection({
    super.key,
    required this.activeUsers,
    required this.onCardTap,
  });

  @override
  Widget build(BuildContext context) {
    if (activeUsers.isEmpty) return const SizedBox();
    
    final userProvider = context.read<UserProvider>();
    final isPremium = userProvider.currentUser?.isPremium ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "ÖNE ÇIKANLAR",
                style: GoogleFonts.outfit(
                  color: Colors.black,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  letterSpacing: -0.5,
                ),
              ),
              if (!isPremium) 
                const Icon(Icons.lock_outline_rounded, color: Colors.black, size: 16),
            ],
          ),
        ),
        SizedBox(
          height: 140,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: activeUsers.take(8).length,
            itemBuilder: (context, index) {
              final user = activeUsers[index];
              return _buildTopPickCard(context, user, isPremium);
            },
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildTopPickCard(BuildContext context, UserProfile user, bool isPremium) {
    return GestureDetector(
      onTap: () {
        if (!isPremium) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const PremiumOfferScreen()));
        } else {
          onCardTap(user);
        }
      },
      child: Container(
        width: 100,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black, width: 3),
          boxShadow: const [
            BoxShadow(
              color: Colors.black,
              offset: Offset(4, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(13),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: user.imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(color: Colors.black12),
              ),
              // Gradient for name readability
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
                      stops: const [0.7, 1.0],
                    ),
                  ),
                ),
              ),
              // Name tag
              Positioned(
                bottom: 8,
                left: 8,
                right: 8,
                child: Text(
                  user.name.split(' ')[0].toUpperCase(),
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Live Indicator
              if (user.isOnline && isPremium)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    width: 8, height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                      boxShadow: [
                        BoxShadow(color: AppColors.green.withOpacity(0.5), blurRadius: 4, spreadRadius: 1),
                      ],
                    ),
                  ),
                ),
              if (!isPremium)
                Container(
                  color: Colors.black.withOpacity(0.4),
                  child: const Center(
                    child: Icon(Icons.lock_outline_rounded, color: Colors.white, size: 24),
                  ),
                ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    border: Border(top: BorderSide(color: Colors.black, width: 2.5)),
                  ),
                  child: Text(
                    (isPremium ? user.name : 'AÇ').toUpperCase(),
                    style: GoogleFonts.outfit(
                      color: Colors.black,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
