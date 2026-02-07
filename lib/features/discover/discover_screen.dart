import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/app_colors.dart';
import '../auth/models/user_profile.dart';
import '../auth/services/profile_service.dart';
import '../../core/utils/log_service.dart';
import 'widgets/filter_bottom_sheet.dart';

/// Keşfet Ekranı - Tinder tarzı Swipe Kartlar
import 'package:provider/provider.dart';
import '../../core/providers/discovery_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/providers/story_provider.dart';
import '../../core/providers/user_provider.dart';
import '../map/map_screen.dart';
import '../notifications/notifications_screen.dart';
import 'story_viewer_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'models/story_model.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final CardSwiperController _cardController = CardSwiperController();
  final ConfettiController _confettiController = ConfettiController(
    duration: const Duration(seconds: 2),
  );
  
  FilterSettings _filterSettings = FilterSettings();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  void _loadInitialData() {
    try {
      context.read<DiscoveryProvider>().loadDiscoveryUsers(
        gender: _filterSettings.gender,
        minAge: _filterSettings.ageRange.start.toInt(),
        maxAge: _filterSettings.ageRange.end.toInt(),
      );
    } catch (e) {
      LogService.e("Failed to load initial discovery data", e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kullanıcılar yüklenemedi. Lütfen internet bağlantınızı kontrol edin.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<bool> _onSwipe(int previousIndex, int? currentIndex, CardSwiperDirection direction) async {
    HapticFeedback.mediumImpact();
    
    final discoveryProvider = context.read<DiscoveryProvider>();
    final targetUser = discoveryProvider.users[previousIndex];
    final isLike = direction == CardSwiperDirection.right || direction == CardSwiperDirection.top;
    
    try {
      final isMatch = await discoveryProvider.swipeUser(targetUser.uid, isLike);
      if (isMatch) {
        _showMatchAnimation(targetUser);
      }
    } catch (e) {
      LogService.e("Swipe action failed", e);
    }
    
    return true; 
  }

  void _showMatchAnimation(UserProfile user) {
    HapticFeedback.heavyImpact();
    setState(() {
      _matchedUser = user;
      _showMatch = true;
    });
    _confettiController.play();
  }

  UserProfile? _matchedUser;
  bool _showMatch = false;

  @override
  void dispose() {
    _cardController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _onLike() {
    HapticFeedback.mediumImpact();
    _cardController.swipe(CardSwiperDirection.right);
  }

  void _onDislike() {
    HapticFeedback.lightImpact();
    _cardController.swipe(CardSwiperDirection.left);
  }

  void _onSuperLike() {
    HapticFeedback.heavyImpact();
    _cardController.swipe(CardSwiperDirection.top);
  }

  void _onUndo() {
    HapticFeedback.lightImpact();
    _cardController.undo();
  }

  void _dismissMatch() {
    setState(() {
      _showMatch = false;
      _matchedUser = null;
    });
  }

  void _showFilters() {
    showFilterBottomSheet(
      context,
      currentSettings: _filterSettings,
      onApply: (settings) {
        setState(() {
          _filterSettings = settings;
        });
        context.read<DiscoveryProvider>().loadDiscoveryUsers(
          gender: settings.gender,
          minAge: settings.ageRange.start.toInt(),
          maxAge: settings.ageRange.end.toInt(),
        );
      },
    );
  }

  Future<void> _pickAndUploadStory() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    
    if (image != null && mounted) {
      try {
        final userProvider = context.read<UserProvider>();
        final storyProvider = context.read<StoryProvider>();
        
        final user = userProvider.currentUser;
        if (user == null) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hikayen yükleniyor...'), duration: Duration(seconds: 2))
        );
        
        final bytes = await image.readAsBytes();
        
        await storyProvider.uploadStoryBytes(
          bytes,
          user.name, 
          user.imageUrl,
          isPremium: user.isPremium,
          isVerified: user.isVerified,
        );


        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Hikaye paylaşıldı! 🎉'))
          );
        }
      } catch (e) {
        LogService.e("Story upload error in UI", e);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Yükleme başarısız oldu.'))
          );
        }
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: Consumer2<DiscoveryProvider, StoryProvider>(
        builder: (context, provider, storyProvider, child) {
          return Stack(
            children: [
              Column(
                children: [
                  _buildTopBar(),
                  _buildStoriesTray(storyProvider.activeStories),
                  const SizedBox(height: 8),
                  Expanded(
                    child: provider.isLoading 
                        ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                        : provider.users.isEmpty
                            ? _buildEmptyState()
                        : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: CardSwiper(
                              controller: _cardController,
                              cardsCount: provider.users.length,
                              numberOfCardsDisplayed: 3,
                              backCardOffset: const Offset(0, 30),
                              padding: EdgeInsets.zero,
                              onSwipe: _onSwipe,
                              allowedSwipeDirection: const AllowedSwipeDirection.only(
                                left: true,
                                right: true,
                                up: true,
                              ),
                              cardBuilder: (context, index, percentThresholdX, percentThresholdY) {
                                return _buildUserCard(provider.users[index], percentThresholdX.toDouble(), percentThresholdY.toDouble());
                              },
                            ),
                        ),
                  ),
                  _buildActionButtons(),
                  const SizedBox(height: 100), 
                ],
              ),
              
              if (storyProvider.isUploading)
                Container(
                  color: Colors.black45,
                  child: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                ),

              if (_showMatch) _buildMatchOverlay(),
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirectionality: BlastDirectionality.explosive,
                  colors: const [AppColors.primary, AppColors.secondary, AppColors.success],
                ),
              ),
            ],
          );
        },
      ),
    );
  }


  Widget _buildTopBar() {
    return SafeArea(
      bottom: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.scaffold.withOpacity(0.8),
          border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Sol: Menü (HTML tasarımı gibi)
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
              },
              child: Icon(Icons.menu_rounded, color: Colors.white.withOpacity(0.4), size: 24),
            ),
            
            // Orta: DENGIM (Luxury style)
            Text(
              'DENGIM',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 4.0,
                color: Colors.white,
              ),
            ),
            
            // Sağ: Refresh ve Filtre
            Row(
              children: [
                GestureDetector(
                   onTap: () {
                     HapticFeedback.lightImpact();
                     _loadInitialData();
                     ScaffoldMessenger.of(context).showSnackBar(
                       const SnackBar(
                         content: Text("Yenileniyor...", style: TextStyle(color: Colors.white)), 
                         backgroundColor: AppColors.surfaceLight,
                         duration: Duration(seconds: 1)
                        )
                      );
                   },
                   child: Icon(Icons.refresh_rounded, color: Colors.white.withOpacity(0.8), size: 24),
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())),
                  child: Icon(Icons.notifications_outlined, color: Colors.white.withOpacity(0.8), size: 24),
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: _showFilters,
                  child: const Icon(Icons.tune_rounded, color: AppColors.primary, size: 24),
                ),
              ],
            ),

          ],
        ),
      ),
    );
  }

  Widget _buildStoriesTray(List<UserStories> activeStories) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        final currentUser = userProvider.currentUser;
        
        UserStories? myStories;
        final List<UserStories> otherStories = [];

        for (var s in activeStories) {
          if (s.userId == currentUser?.uid) {
            myStories = s;
          } else {
            otherStories.add(s);
          }
        }
        
        // Combine for viewer (My Story first if exists)
        final List<UserStories> allViewableStories = [];
        if (myStories != null) allViewableStories.add(myStories);
        allViewableStories.addAll(otherStories);

        return Container(
          height: 110,
          padding: const EdgeInsets.only(top: 16),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: otherStories.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                // My Story Slot
                if (myStories != null) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => StoryViewerScreen(
                              stories: allViewableStories,
                              initialIndex: 0,
                            ),
                          ),
                        );
                      },
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.primary, width: 2),
                            ),
                            child: CircleAvatar(
                              radius: 28,
                              backgroundColor: Colors.grey[900],
                              backgroundImage: NetworkImage(myStories!.userAvatar),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'SİZ',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                } else {
                  return Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: _pickAndUploadStory,
                          child: Container(
                            width: 65,
                            height: 65,
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white.withOpacity(0.08)),
                            ),
                            child: const Icon(Icons.add, color: AppColors.primary, size: 24),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('SİZ', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: Colors.white24, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                      ],
                    ),
                  );
                }
              }

              // Other Users
              final userStories = otherStories[index - 1];
              final name = userStories.userName.toUpperCase();

              return Padding(
                padding: const EdgeInsets.only(right: 20),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        // Find correct index in allViewableStories
                        final viewIndex = allViewableStories.indexOf(userStories);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => StoryViewerScreen(
                              stories: allViewableStories,
                              initialIndex: viewIndex,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(2.5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: userStories.stories.any((s) => s.isPremium) 
                              ? AppColors.goldGradient 
                              : AppColors.storyGradient,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.scaffold, width: 2),
                          ),
                          child: ClipOval(
                             child: CachedNetworkImage(
                              imageUrl: userStories.userAvatar,
                              width: 56,
                              height: 56,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(color: AppColors.surface),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      name.length > 8 ? '${name.substring(0, 7)}..' : name, 
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10, 
                        color: Colors.white, 
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      )
                    ),
                  ],
                ),
              );
            },
          ),
        );
      }
    );
  }





  // Yeni Kart Tasarımı (Glassmorphism)
  Widget _buildUserCard(UserProfile user, double percentX, double percentY) {
    final showLike = percentX > 0.2;
    final showNope = percentX < -0.2;

    return AspectRatio(
      aspectRatio: 3.8 / 5,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 40,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(40),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Fotoğraf
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
                  child: const Icon(Icons.person, size: 80, color: Colors.white10),
                ),
              ),

              // Üst Gradient (Overlay)
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.center,
                    colors: [Colors.black.withOpacity(0.3), Colors.transparent],
                  ),
                ),
              ),

              // Aktif Durum
              Positioned(
                top: 24,
                right: 24,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8, height: 8, 
                        decoration: BoxDecoration(
                          color: user.isOnline ? const Color(0xFF10B981) : Colors.white30, 
                          shape: BoxShape.circle
                        )
                      ),
                      const SizedBox(width: 8),
                      Text(
                        user.isOnline ? 'AKTİF' : 'ÇEVRİMDIŞI', 
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10, 
                          fontWeight: FontWeight.bold, 
                          color: user.isOnline ? Colors.white : Colors.white30, 
                          letterSpacing: 1.0
                        )
                      ),
                    ],
                  ),
                ),



              Positioned(
                bottom: 24,
                left: 24,
                right: 24,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                '${user.name}, ${user.age}',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.verified, color: AppColors.primary, size: 22),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(Icons.architecture, color: Colors.white.withOpacity(0.5), size: 16),
                              const SizedBox(width: 8),
                              Text(
                                (user.job ?? 'Kreatif Direktör').toUpperCase(),
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white.withOpacity(0.5),
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Swipe Etiketleri
              if (showLike) Positioned(top: 60, left: 30, child: _buildSwipeLabel('LIKE', AppColors.success, percentX.abs())),
              if (showNope) Positioned(top: 60, right: 30, child: _buildSwipeLabel('NOPE', AppColors.error, percentX.abs())),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildCircleButton(
            onTap: _onUndo,
            size: 40,
            icon: Icons.undo,
            color: AppColors.secondary.withOpacity(0.7),
            borderColor: AppColors.secondary.withOpacity(0.4),
            bgColor: Colors.transparent,
          ),
          const SizedBox(width: 24),
          _buildCircleButton(
            onTap: _onDislike,
            size: 56,
            icon: Icons.close,
            color: Colors.white.withOpacity(0.5),
            borderColor: Colors.white.withOpacity(0.1),
            bgColor: Colors.white.withOpacity(0.03),
          ),
          const SizedBox(width: 24),
          _buildCircleButton(
            onTap: _onLike,
            size: 80,
            icon: Icons.favorite,
            iconSize: 36,
            color: AppColors.primary,
            borderColor: AppColors.primary.withOpacity(0.3),
            bgColor: AppColors.primary.withOpacity(0.1),
            hasShadow: true,
          ),
          const SizedBox(width: 24),
          _buildCircleButton(
            onTap: _onSuperLike,
            size: 56,
            icon: Icons.star,
            color: Colors.white.withOpacity(0.5),
            borderColor: Colors.white.withOpacity(0.1),
            bgColor: Colors.white.withOpacity(0.03),
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
    Color? borderColor,
    Color? bgColor,
    double? iconSize,
    bool hasShadow = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: bgColor ?? Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(
            color: borderColor ?? Colors.transparent,
            width: 1,
          ),
          boxShadow: hasShadow
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.15),
                    blurRadius: 30,
                    spreadRadius: 0,
                  )
                ]
              : null,
        ),
        child: Icon(
          icon,
          color: color,
          size: iconSize ?? (size * 0.45),
        ),
      ),
    );
  }

  Widget _buildSwipeLabel(String text, Color color, double opacity) {
    return Transform.rotate(
      angle: text == 'NOPE' ? 0.3 : text == 'LIKE' ? -0.3 : 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(opacity.clamp(0.0, 1.0)), width: 3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: color.withOpacity(opacity.clamp(0.0, 1.0)),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.explore_rounded, size: 60, color: AppColors.primary),
            ),
            const SizedBox(height: 32),
            Text(
              "Şu an için bu kadar! 🎉",
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Yakındaki tüm profilleri gördün.\nDaha fazla kişi için filtrelerini genişlet\nveya daha sonra tekrar dene.",
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white38,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _showFilters,
                  icon: const Icon(Icons.tune_rounded, size: 18),
                  label: Text("Filtreleri Değiştir", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                ),
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  onPressed: () => context.read<DiscoveryProvider>().loadDiscoveryUsers(),
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: Text("Yenile", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white54,
                    side: BorderSide(color: Colors.white.withOpacity(0.2)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchOverlay() {
    if (_matchedUser == null) return const SizedBox.shrink();
    return Positioned.fill(
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            color: Colors.black.withOpacity(0.9),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "EŞLEŞTİNİZ!",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                    letterSpacing: 5.0,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Artık ${_matchedUser?.name} ile konuşabilirsin",
                  style: GoogleFonts.plusJakartaSans(color: Colors.white54, fontSize: 13),
                ),
                const SizedBox(height: 60),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(radius: 60, backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=me')),
                    const SizedBox(width: 24),
                    const Icon(Icons.favorite_rounded, color: AppColors.primary, size: 40),
                    const SizedBox(width: 24),
                    CircleAvatar(radius: 60, backgroundImage: NetworkImage(_matchedUser!.imageUrl)),
                  ],
                ),
                const SizedBox(height: 80),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: ElevatedButton(
                    onPressed: _dismissMatch,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.black,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text("MESAJ GÖNDER", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                  ),
                ),
                TextButton(
                  onPressed: _dismissMatch,
                  child: Text("ŞİMDİ DEĞİL", style: GoogleFonts.plusJakartaSans(color: Colors.white30, fontSize: 12, letterSpacing: 1.0)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

