import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Beta: Simplified swipe buttons — only Dislike, Like, and Undo.
/// Super Like and Boost are removed for the beta version.
class SwipeActionButtons extends StatelessWidget {
  final VoidCallback onUndo;
  final VoidCallback onDislike;
  final VoidCallback onLike;

  const SwipeActionButtons({
    super.key,
    required this.onUndo,
    required this.onDislike,
    required this.onLike,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Undo — small secondary button
          _buildCircleButton(
            onTap: onUndo,
            size: 48,
            icon: Icons.undo_rounded,
            color: Colors.black54,
            bgColor: Colors.white,
          ),
          const SizedBox(width: 24),
          // Dislike
          _buildCircleButton(
            onTap: onDislike,
            size: 68,
            icon: Icons.close_rounded,
            color: Colors.black,
            bgColor: Colors.white,
          ),
          const SizedBox(width: 24),
          // Like — primary CTA (large, black background)
          _buildCircleButton(
            onTap: onLike,
            size: 84,
            icon: Icons.favorite_rounded,
            iconSize: 38,
            color: Colors.white,
            bgColor: Colors.black,
          ),
        ],
      ),
    );
  }

  Widget _buildCircleButton({
    required VoidCallback onTap,
    required double size,
    required IconData icon,
    required Color color,
    required Color bgColor,
    double? iconSize,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
          border: Border.all(color: Color(0xFFEEEEEE), width: 1.0),
          boxShadow: [AppColors.neoShadow],
        ),
        child: Icon(
          icon,
          color: color,
          size: iconSize ?? (size * 0.44),
        ),
      ),
    );
  }
}
