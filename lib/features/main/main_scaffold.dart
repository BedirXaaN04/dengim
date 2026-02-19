import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/notification_service.dart';
import '../discover/discover_screen.dart';
import '../map/map_screen.dart';
import '../chats/chats_screen.dart';
import '../profile/profile_screen.dart';
import '../likes/likes_screen.dart';
import 'package:provider/provider.dart';
import '../../core/providers/connectivity_provider.dart';
import '../../core/providers/badge_provider.dart';
import '../../core/providers/system_config_provider.dart';
import '../../core/widgets/offline_banner.dart';

/// MainScaffold - Ana uygulama iskeleti
class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // FCM Token güncelle
    NotificationService.updateToken();
  }

  List<Widget> _getScreens(bool isMapEnabled) {
    return [
      const DiscoverScreen(),
      if (isMapEnabled) const MapScreen(),
      const LikesScreen(),
      const ChatsScreen(),
      const ProfileScreen(),
    ];
  }

  List<_NavItem> _getNavItems(bool isMapEnabled) {
    return [
      const _NavItem(
        icon: Icons.explore_outlined,
        activeIcon: Icons.explore,
        label: 'Keşfet',
      ),
      if (isMapEnabled)
        const _NavItem(
          icon: Icons.map_outlined,
          activeIcon: Icons.map,
          label: 'Harita',
        ),
      const _NavItem(
        icon: Icons.favorite_outline_rounded,
        activeIcon: Icons.favorite_rounded,
        label: 'Beğeniler',
      ),
      const _NavItem(
        icon: Icons.chat_bubble_outline_rounded,
        activeIcon: Icons.chat_bubble_rounded,
        label: 'Sohbetler',
      ),
      const _NavItem(
        icon: Icons.person_outline_rounded,
        activeIcon: Icons.person_rounded,
        label: 'Profil',
      ),
    ];
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final connectivityProvider = context.watch<ConnectivityProvider>();
    final configProvider = context.watch<SystemConfigProvider>();
    final isMapEnabled = configProvider.isMapEnabled;
    
    final screens = _getScreens(isMapEnabled);
    final navItems = _getNavItems(isMapEnabled);

    // Eğer map kapalıysa ve index map'i (1) veya sonrasını gösteriyorsa düzeltme gerekebilir
    // Ancak IndexedStack index'i ile nav items index'i uyumlu olmalı.
    // _currentIndex range check:
    if (_currentIndex >= screens.length) {
      _currentIndex = 0;
    }

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      extendBody: true, // Bottom nav overlap
      body: Column(
        children: [
          // Offline banner
          if (!connectivityProvider.isConnected)
            const OfflineBanner(),
          // Main content
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: screens,
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(navItems),
    );
  }

  Widget _buildBottomNav(List<_NavItem> navItems) {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      height: 72,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(36),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF0F1115).withOpacity(0.85),
              borderRadius: BorderRadius.circular(36),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ]
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                navItems.length,
                (index) => _buildNavItem(index, navItems),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, List<_NavItem> navItems) {
    final isSelected = _currentIndex == index;
    final item = navItems[index];
    final badgeProvider = context.watch<BadgeProvider>();
    
    // Determine badge count based on label (dynamic index)
    int badgeCount = 0;
    if (item.label == 'Sohbetler') { 
      badgeCount = badgeProvider.chatBadge;
    } else if (item.label == 'Beğeniler') {
      badgeCount = badgeProvider.likesBadge;
    }

    return GestureDetector(
      onTap: () => _onTabTapped(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                isSelected ? item.activeIcon : item.icon,
                size: 24,
                color: isSelected ? AppColors.primary : Colors.white.withOpacity(0.3),
              ),
              if (badgeCount > 0)
                Positioned(
                  right: -8,
                  top: -4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      badgeCount > 9 ? '9+' : '$badgeCount',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            item.label.toUpperCase(),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 8,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: isSelected ? AppColors.primary : Colors.white.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
