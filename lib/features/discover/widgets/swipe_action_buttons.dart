import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class SwipeActionButtons extends StatelessWidget {
  final VoidCallback onUndo;
  final VoidCallback onDislike;
  final VoidCallback onLike;
  final VoidCallback onSuperLike;
  final VoidCallback onBoost;

  const SwipeActionButtons({
    super.key,
    required this.onUndo,
    required this.onDislike,
    required this.onLike,
    required this.onSuperLike,
    required this.onBoost,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildCircleButton(
            onTap: onUndo,
            size: 48,
            icon: Icons.undo_rounded,
            color: Colors.black,
            bgColor: AppColors.secondary,
          ),
          const SizedBox(width: 16),
          _buildCircleButton(
            onTap: onDislike,
            size: 64,
            icon: Icons.close_rounded,
            color: Colors.black,
            bgColor: Colors.white,
          ),
          const SizedBox(width: 16),
          _buildCircleButton(
            onTap: onLike,
            size: 80,
            icon: Icons.favorite_rounded,
            iconSize: 36,
            color: AppColors.red,
            bgColor: AppColors.primary,
          ),
          const SizedBox(width: 16),
          _buildCircleButton(
            onTap: onSuperLike,
            size: 64,
            icon: Icons.star_rounded,
            color: Colors.black,
            bgColor: AppColors.blue,
          ),
          const SizedBox(width: 16),
          _buildCircleButton(
            onTap: onBoost,
            size: 48,
            icon: Icons.bolt_rounded,
            color: Colors.black,
            bgColor: AppColors.green,
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
          border: Border.all(color: Colors.black, width: 3),
          boxShadow: const [
            BoxShadow(color: Colors.black, offset: Offset(4, 4)),
          ],
        ),
        child: Icon(
          icon,
          color: color,
          size: iconSize ?? (size * 0.45),
        ),
      ),
    );
  }
}
