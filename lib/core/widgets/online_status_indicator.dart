import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Online/Offline Status Widget
/// Kullanıcının çevrimiçi durumunu gösterir
class OnlineStatusIndicator extends StatelessWidget {
  final String userId;
  final double size;
  final bool showBorder;

  const OnlineStatusIndicator({
    super.key,
    required this.userId,
    this.size = 12,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return _buildOfflineIndicator();
        }

        final data = snapshot.data?.data() as Map<String, dynamic>?;
        final isOnline = data?['isOnline'] ?? false;
        final lastSeen = data?['lastSeen'] as Timestamp?;
        final isGhostMode = data?['isGhostMode'] ?? false;

        // Ghost Mode 활성화 시 오프라인으로 표시
        if (isGhostMode) return _buildOfflineIndicator();

        // Son 5 dakika içinde görüldüyse online say
        if (!isOnline && lastSeen != null) {
          final difference = DateTime.now().difference(lastSeen.toDate());
          if (difference.inMinutes < 5) {
            return _buildOnlineIndicator();
          }
        }

        return isOnline ? _buildOnlineIndicator() : _buildOfflineIndicator();
      },
    );
  }

  Widget _buildOnlineIndicator() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF10B981), // Green
        shape: BoxShape.circle,
        border: showBorder
            ? Border.all(color: Colors.white, width: size * 0.15)
            : null,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withOpacity(0.5),
            blurRadius: size * 0.5,
            spreadRadius: size * 0.1,
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineIndicator() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey.shade600,
        shape: BoxShape.circle,
        border: showBorder
            ? Border.all(color: Colors.white, width: size * 0.15)
            : null,
      ),
    );
  }
}

/// Online Status Badge (Avatar üzerinde gösterim için)
class OnlineStatusBadge extends StatelessWidget {
  final String userId;
  final Widget child;
  final double badgeSize;
  final Alignment alignment;

  const OnlineStatusBadge({
    super.key,
    required this.userId,
    required this.child,
    this.badgeSize = 14,
    this.alignment = Alignment.bottomRight,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned.fill(
          child: Align(
            alignment: alignment,
            child: OnlineStatusIndicator(
              userId: userId,
              size: badgeSize,
            ),
          ),
        ),
      ],
    );
  }
}

/// Last Seen Text Widget
class LastSeenText extends StatelessWidget {
  final String userId;
  final TextStyle? style;

  const LastSeenText({
    super.key,
    required this.userId,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Text(
            'Offline',
            style: style ?? const TextStyle(color: Colors.grey, fontSize: 12),
          );
        }

        final data = snapshot.data?.data() as Map<String, dynamic>?;
        final isOnline = data?['isOnline'] ?? false;
        final lastSeen = data?['lastSeen'] as Timestamp?;
        final isGhostMode = data?['isGhostMode'] ?? false;

        if (isGhostMode) {
           return Text(
            'Gizli',
            style: style ?? const TextStyle(color: Colors.grey, fontSize: 12),
          );
        }

        if (isOnline) {
          return Text(
            'Çevrimiçi',
            style: style ??
                const TextStyle(color: Color(0xFF10B981), fontSize: 12),
          );
        }

        if (lastSeen != null) {
          final lastSeenText = _formatLastSeen(lastSeen.toDate());
          return Text(
            lastSeenText,
            style: style ?? const TextStyle(color: Colors.grey, fontSize: 12),
          );
        }

        return Text(
          'Offline',
          style: style ?? const TextStyle(color: Colors.grey, fontSize: 12),
        );
      },
    );
  }

  String _formatLastSeen(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) return 'Az önce çevrimiçiydi';
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} dakika önce çevrimiçiydi';
    }
    if (difference.inHours < 24) {
      return '${difference.inHours} saat önce çevrimiçiydi';
    }
    if (difference.inDays < 7) {
      return '${difference.inDays} gün önce çevrimiçiydi';
    }
    return 'Uzun zaman önce çevrimiçiydi';
  }
}
