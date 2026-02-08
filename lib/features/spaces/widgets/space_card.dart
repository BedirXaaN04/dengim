import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/space_model.dart';
import '../../../core/theme/app_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SpaceCard extends StatelessWidget {
  final SpaceRoom space;
  final VoidCallback onTap;

  const SpaceCard({
    super.key,
    required this.space,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1D23),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: space.status == SpaceStatus.live 
                ? AppColors.primary.withOpacity(0.3) 
                : Colors.white.withOpacity(0.05),
            width: 1.5,
          ),
          boxShadow: [
            if (space.status == SpaceStatus.live)
              BoxShadow(
                color: AppColors.primary.withOpacity(0.05),
                blurRadius: 15,
                spreadRadius: 2,
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (space.status == SpaceStatus.live)
                  _buildLiveIndicator(),
                const Spacer(),
                Text(
                  _getCategoryName(space.category),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white38,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              space.title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (space.description != null && space.description!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                space.description!,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: Colors.white60,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 20),
            Row(
              children: [
                _buildSpeakerAvatars(),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${space.hostName} ve ${space.speakers.length + space.listenerIds.length - 1} kişi',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white54,
                    ),
                  ),
                ),
                _buildListenerCount(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.graphic_eq_rounded, size: 12, color: Colors.black),
          const SizedBox(width: 4),
          Text(
            'CANLI',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeakerAvatars() {
    final speakers = space.speakers.take(3).toList();
    return SizedBox(
      height: 32,
      width: 32.0 + (speakers.length > 1 ? (speakers.length - 1) * 20 : 0),
      child: Stack(
        children: List.generate(speakers.length, (index) {
          return Positioned(
            left: index * 20.0,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF1A1D23), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 5,
                  )
                ],
              ),
              child: ClipOval(
                child: CachedNetworkImage(
                  imageUrl: speakers[index].avatarUrl ?? 'https://ui-avatars.com/api/?name=${speakers[index].name}',
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(color: Colors.white12),
                  errorWidget: (context, url, error) => const Icon(Icons.person, size: 16),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildListenerCount() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.headset_rounded, size: 14, color: Colors.white38),
          const SizedBox(width: 6),
          Text(
            '${space.listenerCount}',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  String _getCategoryName(SpaceCategory category) {
    switch (category) {
      case SpaceCategory.chat: return 'SOHBET';
      case SpaceCategory.music: return 'MÜZİK';
      case SpaceCategory.dating: return 'TANIŞMA';
      case SpaceCategory.advice: return 'TAVSİYE';
      case SpaceCategory.fun: return 'EĞLENCE';
    }
  }
}
