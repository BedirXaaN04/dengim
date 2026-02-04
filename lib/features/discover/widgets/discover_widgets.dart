import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

/// Glassmorphism efektli kart widget'ı
class GlassCard extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const GlassCard({
    super.key,
    required this.child,
    this.blur = 20,
    this.opacity = 0.1,
    this.borderRadius,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding ?? const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha((opacity * 255).toInt()),
              borderRadius: borderRadius ?? BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withAlpha(51),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(51),
                  blurRadius: 20,
                  spreadRadius: -5,
                ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Aksiyon butonu widget'ı (Like, Message, Super Like)
class ActionButton extends StatefulWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;
  final double size;
  final bool animate;

  const ActionButton({
    super.key,
    required this.icon,
    required this.color,
    required this.onPressed,
    this.size = 56,
    this.animate = false,
  });

  @override
  State<ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<ActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onPressed();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: widget.color.withAlpha(38),
            shape: BoxShape.circle,
            border: Border.all(
              color: widget.color.withAlpha(77),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.color.withAlpha(51),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Icon(
            widget.icon,
            color: widget.color,
            size: widget.size * 0.5,
          ),
        ),
      ),
    );
  }
}

/// Kullanıcı bilgi kartı (Glassmorphism)
class UserInfoCard extends StatelessWidget {
  final String name;
  final int age;
  final String location;
  final String bio;
  final bool isVerified;
  final bool isOnline;

  const UserInfoCard({
    super.key,
    required this.name,
    required this.age,
    required this.location,
    required this.bio,
    this.isVerified = false,
    this.isOnline = false,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // İsim, Yaş ve Doğrulama
          Row(
            children: [
              Text(
                '$name, ',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                '$age',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                ),
              ),
              if (isVerified) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ],
              if (isOnline) ...[
                const SizedBox(width: 8),
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          // Konum
          Row(
            children: [
              Icon(
                Icons.location_on_rounded,
                color: Colors.white.withAlpha(179),
                size: 18,
              ),
              const SizedBox(width: 4),
              Text(
                location,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.white.withAlpha(179),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Bio
          Text(
            bio,
            style: GoogleFonts.poppins(
              fontSize: 15,
              color: Colors.white.withAlpha(230),
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
