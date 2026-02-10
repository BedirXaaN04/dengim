import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../auth/models/user_profile.dart';
import '../payment/premium_offer_screen.dart';

import 'package:provider/provider.dart';
import '../../core/providers/likes_provider.dart';
import '../../core/providers/badge_provider.dart';
import '../../core/services/config_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';


class LikesScreen extends StatefulWidget {
  const LikesScreen({super.key});

  @override
  State<LikesScreen> createState() => _LikesScreenState();
}

class _LikesScreenState extends State<LikesScreen> {
  int _activeTab = 0; // 0: Seni Beğenenler, 1: Eşleşmeler

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<LikesProvider>();
      provider.initStreams(); // Gerçek zamanlı dinleme
      provider.loadMatches();
      provider.loadLikedMeUsers();
      
      // Bildirimleri temizle
      if (mounted) {
        context.read<BadgeProvider>().markLikesAsViewed();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: Consumer<LikesProvider>(
        builder: (context, provider, child) {
          return SafeArea(
            child: Column(
              children: [
                _buildTopBar(),
                _buildTabs(),

                Expanded(
                  child: provider.isLoading 
                    ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                    : CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      if (_activeTab == 1) ...[
                        // Eşleşmeler Listesi (Grid)
                        if (provider.matches.isEmpty)
                          SliverToBoxAdapter(
                            child: _buildEmptyMatches(),
                          )
                        else
                        SliverPadding(
                          padding: const EdgeInsets.all(20),
                          sliver: SliverGrid(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.75,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) => _UnlockedLikeCard(
                                user: provider.matches[index],
                                showActions: false, // Eşleşmelerde aksiyon yok
                              ),
                              childCount: provider.matches.length,
                            ),
                          ),
                        ),
                      ] else ...[
                        // Seni Beğenenler Section
                        SliverToBoxAdapter(
                          child: _buildNewMatchesSection(provider.matches),
                        ),
                        if (ConfigService().isVipEnabled) ...[
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(20, 32, 20, 16),
                              child: Text(
                                "SENI BEĞENENLER (VIP)",
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ),
                          ),
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            sliver: SliverGrid(
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.75,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                              delegate: SliverChildBuilderDelegate(
                                (context, index) => const _LockedLikeCard(),
                                childCount: provider.likedMeUsers.length,
                              ),
                            ),
                          ),
                        ] else ...[
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            sliver: SliverGrid(
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.75,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                              delegate: SliverChildBuilderDelegate(
                                (context, index) => _UnlockedLikeCard(user: provider.likedMeUsers[index]),
                                childCount: provider.likedMeUsers.length,
                              ),
                            ),
                          ),
                        ],
                        if (provider.likedMeUsers.isEmpty)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                              child: Column(
                                children: [
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.favorite_border_rounded, size: 40, color: AppColors.primary),
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    "Profilini güçlendir! 💪",
                                    style: GoogleFonts.plusJakartaSans(
                                      color: Colors.white, 
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Daha fazla fotoğraf ekle ve\nilgi çekici bir biyografi yaz.",
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.plusJakartaSans(
                                      color: Colors.white38, 
                                      fontSize: 13,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                      const SliverToBoxAdapter(child: SizedBox(height: 120)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildNewMatchesSection(List<UserProfile> matches) {
    if (matches.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
          child: Text(
            "YENI EŞLEŞMELER",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
        ),
        SizedBox(
          height: 140,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: matches.length,
            itemBuilder: (context, index) {
              final user = matches[index];
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: CachedNetworkImage(
                        imageUrl: user.imageUrl,
                        width: 80,
                        height: 110,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Shimmer.fromColors(
                          baseColor: Colors.white10,
                          highlightColor: Colors.white24,
                          child: Container(color: Colors.white),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: AppColors.surface,
                          child: const Icon(Icons.person, color: Colors.white10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      user.name,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(Icons.arrow_back_ios_new, color: Colors.white.withOpacity(0.9), size: 20),
          Text(
            "Beğeniler",
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          Icon(Icons.filter_list_rounded, color: AppColors.primary, size: 24),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _buildTabItem("Seni Beğenenler", 0),
          const SizedBox(width: 32),
          _buildTabItem("Eşleşmeler", 1),
        ],
      ),
    );
  }

  Widget _buildTabItem(String title, int index) {
    bool isActive = _activeTab == index;
    return GestureDetector(
      onTap: () => setState(() => _activeTab = index),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: isActive ? Colors.white : Colors.white.withOpacity(0.4),
              ),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 2,
            width: 40,
            decoration: BoxDecoration(
              color: isActive ? AppColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyMatches() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.pink.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.favorite, size: 50, color: Colors.pinkAccent),
          ),
          const SizedBox(height: 24),
          Text(
            "Henüz eşleşme yok",
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Keşfet'e gidip insanları beğenmeye başla.\nKarşılıklı beğeniler eşleşme oluşturur!",
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white38,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _LockedLikeCard extends StatelessWidget {
  const _LockedLikeCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: const DecorationImage(
          image: NetworkImage('https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=400'),
          fit: BoxFit.cover,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PremiumOfferScreen())),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A).withOpacity(0.6), // Midnight Blue Tint
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.05),
                    Colors.black.withOpacity(0.4),
                  ],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                    ),
                    child: Icon(Icons.lock_outline_rounded, color: AppColors.primary.withOpacity(0.8), size: 28),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      "Görmek için Premium'a geç",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Beğeni kartı - Kabul/Ret butonlarıyla etkileşimli
class _UnlockedLikeCard extends StatelessWidget {
  final UserProfile user;
  final bool showActions; // Beğeniler için kabul/ret, eşleşmeler için false
  
  const _UnlockedLikeCard({
    required this.user, 
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showProfileDetail(context),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Profil fotoğrafı
              CachedNetworkImage(
                imageUrl: user.imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Shimmer.fromColors(
                  baseColor: Colors.white10,
                  highlightColor: Colors.white24,
                  child: Container(color: Colors.white),
                ),
                errorWidget: (context, url, error) => Container(
                  color: AppColors.surface,
                  child: const Icon(Icons.person, color: Colors.white10, size: 40),
                ),
              ),
              
              // Gradient overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.8),
                      ],
                      stops: const [0.5, 1.0],
                    ),
                  ),
                ),
              ),
              
              // Kullanıcı bilgileri
              Positioned(
                bottom: showActions ? 56 : 12,
                left: 12,
                right: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${user.name}, ${user.age}",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (user.location != null) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 10, color: Colors.white54),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              user.location!,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                color: Colors.white.withOpacity(0.6),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              
              // Kabul/Ret butonları (sadece beğeniler için)
              if (showActions)
                Positioned(
                  bottom: 8,
                  left: 12,
                  right: 12,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Ret butonu
                      _ActionButton(
                        icon: Icons.close_rounded,
                        color: Colors.red,
                        onTap: () => _rejectLike(context),
                      ),
                      // Kabul butonu (Eşleş)
                      _ActionButton(
                        icon: Icons.favorite_rounded,
                        color: AppColors.primary,
                        isMain: true,
                        onTap: () => _acceptLike(context),
                      ),
                    ],
                  ),
                ),

              // Beğeni kalp ikonu (üst sağ)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.favorite, color: Colors.red, size: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _acceptLike(BuildContext context) async {
    final provider = context.read<LikesProvider>();
    
    // Loading göster
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
    );
    
    final matched = await provider.likeBack(user.uid);
    Navigator.pop(context); // Loading kapat
    
    if (matched) {
      // Eşleşme animasyonu/bildirimi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.favorite, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${user.name} ile eşleştiniz! 🎉',
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _rejectLike(BuildContext context) async {
    await context.read<LikesProvider>().rejectLike(user.uid);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${user.name} reddedildi'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _showProfileDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              children: [
                // Handle
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                
                // Profil fotoğrafı
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: CachedNetworkImage(
                    imageUrl: user.imageUrl,
                    width: double.infinity,
                    height: 400,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) => Container(
                      height: 400,
                      color: Colors.grey[900],
                      child: const Icon(Icons.person, size: 100, color: Colors.white24),
                    ),
                  ),
                ),
                
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // İsim ve yaş
                      Text(
                        "${user.name}, ${user.age}",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      
                      if (user.location != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 18, color: AppColors.primary),
                            const SizedBox(width: 4),
                            Text(
                              user.location!,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ],
                      
                      if (user.bio != null && user.bio!.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        Text(
                          "Hakkında",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          user.bio!,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            color: Colors.white70,
                            height: 1.5,
                          ),
                        ),
                      ],
                      
                      const SizedBox(height: 32),
                      
                      // Aksiyon butonları
                      if (showActions)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _rejectLike(context);
                                },
                                icon: const Icon(Icons.close),
                                label: const Text("Geç"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red.withOpacity(0.2),
                                  foregroundColor: Colors.red,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _acceptLike(context);
                                },
                                icon: const Icon(Icons.favorite),
                                label: const Text("Eşleş"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Aksiyon butonu (kabul/ret)
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool isMain;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
    this.isMain = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: isMain ? 44 : 36,
        height: isMain ? 44 : 36,
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          shape: BoxShape.circle,
          border: Border.all(color: color, width: isMain ? 2 : 1),
          boxShadow: isMain ? [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Icon(icon, color: color, size: isMain ? 22 : 18),
      ),
    );
  }
}

