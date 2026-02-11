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
import '../notifications/notifications_screen.dart';
import 'story_viewer_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'models/story_model.dart';
import '../payment/premium_offer_screen.dart';
import 'user_profile_detail_screen.dart';
import '../spaces/screens/spaces_screen.dart';
import 'widgets/advanced_filters_modal.dart';
import '../ads/widgets/dengim_banner_ad.dart';

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
  final TextEditingController _searchController = TextEditingController();
  
  FilterSettings _filterSettings = FilterSettings();
  bool _isRefreshing = false;
  bool _showSearchBar = false;
  String _searchQuery = '';
  List<UserProfile> _searchResults = [];
  bool _isSearching = false;

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

  /// Pull-to-refresh fonksiyonu
  Future<void> _refreshData() async {
    if (_isRefreshing) return;
    
    setState(() => _isRefreshing = true);
    
    try {
      // Haptic feedback
      HapticFeedback.mediumImpact();
      
      // Hikayeleri yenile
      await context.read<StoryProvider>().loadStories();
      
      // Kullanıcıları yenile
      await context.read<DiscoveryProvider>().loadDiscoveryUsers(
        gender: _filterSettings.gender,
        minAge: _filterSettings.ageRange.start.toInt(),
        maxAge: _filterSettings.ageRange.end.toInt(),
        forceRefresh: true,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                const Text('Yenilendi! 🔄'),
              ],
            ),
            backgroundColor: AppColors.success,
            duration: const Duration(milliseconds: 1200),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.only(bottom: 120, left: 20, right: 20),
          ),
        );
      }
    } catch (e) {
      LogService.e("Refresh error", e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Yenileme başarısız oldu'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isRefreshing = false);
      }
    }
  }

  Future<bool> _onSwipe(int previousIndex, int? currentIndex, CardSwiperDirection direction) async {
    HapticFeedback.mediumImpact();
    
    final discoveryProvider = context.read<DiscoveryProvider>();
    final targetUser = discoveryProvider.users[previousIndex];
    String swipeType = 'dislike';
    if (direction == CardSwiperDirection.right) swipeType = 'like';
    if (direction == CardSwiperDirection.top) swipeType = 'super_like';
    
    try {
      final userProvider = context.read<UserProvider>();
      final currentUser = userProvider.currentUser;
      final userTier = currentUser?.subscriptionTier ?? 'free';

      final success = await discoveryProvider.swipeUser(
        targetUser.uid, 
        swipeType, 
        userTier: userTier
      );
      
      if (!success && swipeType != 'dislike') {
        // Limit reached, show offer
        if (mounted) {
           Navigator.push(context, MaterialPageRoute(builder: (_) => const PremiumOfferScreen()));
        }
        return false; // Swipe failed
      }

      final isMatch = success; // Success means swipe recorded, might be match
      
      // Geri bildirim göster (match değilse ve beğeni ise)
      if (mounted && !isMatch && swipeType != 'dislike') {
        if (direction == CardSwiperDirection.right) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('💛 ${targetUser.name} beğenildi!'),
              backgroundColor: AppColors.surfaceLight,
              duration: const Duration(milliseconds: 800),
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.only(bottom: 120, left: 20, right: 20),
            ),
          );
        }
      }
      
      // Re-fetch isMatch real status if needed, but swipeUser returns if it was a match
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
  int _currentPhotoIndex = 0;

  @override
  void dispose() {
    _cardController.dispose();
    _confettiController.dispose();
    _searchController.dispose();
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

  void _onSuperLike() async {
    final userProvider = context.read<UserProvider>();
    final currentUser = userProvider.currentUser;

    if (currentUser?.isPremium != true) {
      // Show Premium Offer
      final result = await Navigator.push(
        context, 
        MaterialPageRoute(builder: (_) => const PremiumOfferScreen())
      );
      
      if (result == true) {
         // If purchased, proceed
         _performSuperLike();
      }
    } else {
      _performSuperLike();
    }
  }

  void _performSuperLike() {
    HapticFeedback.heavyImpact();
    // Show visual feedback
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🌟 Super Like gönderildi!'),
        backgroundColor: AppColors.secondary,
        duration: Duration(seconds: 1),
      )
    );
    _cardController.swipe(CardSwiperDirection.top);
  }

  void _onUndo() {
    final userProvider = context.read<UserProvider>();
    final isPremium = userProvider.currentUser?.isPremium ?? false;

    if (!isPremium) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const PremiumOfferScreen()));
      return;
    }

    HapticFeedback.lightImpact();
    _cardController.undo();
  }

  void _onBoost() {
    final userProvider = context.read<UserProvider>();
    final currentUser = userProvider.currentUser;
    final isPremium = currentUser?.isPremium ?? false;

    if (!isPremium) {
       Navigator.push(context, MaterialPageRoute(builder: (_) => const PremiumOfferScreen()));
       return;
    }
    
    // Check if already boosted
    if (currentUser?.isBoosted ?? false) {
       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text('Zaten bir boost aktif!'))
       );
       return;
    }

    _showBoostActivationDialog();
  }

  void _showBoostActivationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.purpleAccent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.purpleAccent.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.bolt_rounded, color: Colors.purpleAccent, size: 24),
            ),
            const SizedBox(width: 12),
            Text('Profilini Öne Çıkar', 
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              )
            ),
          ],
        ),
        content: Text(
          '30 dakika boyunca profilin daha fazla kişi tarafından görülecek ve eşleşme şansın artacak!',
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white70,
            fontSize: 14,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('İptal', 
              style: GoogleFonts.plusJakartaSans(color: Colors.white54, fontWeight: FontWeight.bold)
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<DiscoveryProvider>().activateBoost();
              HapticFeedback.heavyImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('🚀 Boost Aktifleştirildi! Profilin öne çıkıyor.'),
                  backgroundColor: Colors.purpleAccent,
                  behavior: SnackBarBehavior.floating,
                )
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purpleAccent,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Aktifleştir', 
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)
            ),
          ),
        ],
      ),
    );
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

  /// Profil arama
  Future<void> _searchUsers(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    try {
      final results = await ProfileService().searchUsers(query.trim());
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      }
    } catch (e) {
      LogService.e("Search error", e);
      if (mounted) {
        setState(() => _isSearching = false);
      }
    }
  }

  void _onSearchChanged(String value) {
    setState(() => _searchQuery = value);
    // Debounce: Kısa arama sorgularında bekle
    if (value.length >= 2) {
      _searchUsers(value);
    } else {
      setState(() => _searchResults = []);
    }
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
              RefreshIndicator(
                onRefresh: _refreshData,
                color: AppColors.primary,
                backgroundColor: AppColors.surfaceLight,
                displacement: 40,
                strokeWidth: 3,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          _buildTopBar(),
                          _buildSearchBar(), // 🔍 Arama barı
                          if (!_showSearchBar) _buildStoriesTray(storyProvider.activeStories),
                          if (!_showSearchBar) _buildTopPicks(provider.activeUsers),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Column(
                        children: [
                          Expanded(
                            child: provider.isLoading && !_isRefreshing
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
                          const DengimBannerAd(),
                          const SizedBox(height: 100), 
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Yenileme göstergesi
              if (_isRefreshing)
                Positioned(
                  top: MediaQuery.of(context).padding.top + 60,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Yenileniyor...',
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
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


  Widget _buildTopPicks(List<UserProfile> activeUsers) {
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
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  letterSpacing: 1.5,
                ),
              ),
              if (!isPremium) 
                const Icon(Icons.lock_outline_rounded, color: AppColors.primary, size: 14),
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
              return _buildTopPickCard(user, isPremium);
            },
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildTopPickCard(UserProfile user, bool isPremium) {
    return GestureDetector(
      onTap: () {
        if (!isPremium) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const PremiumOfferScreen()));
        } else {
          _onCardTap(user);
        }
      },
      child: Container(
        width: 100,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: user.imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(color: Colors.white05),
              ),
              if (!isPremium)
                ClipRRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      color: Colors.black.withOpacity(0.4),
                      child: const Center(
                        child: Icon(Icons.lock_outline_rounded, color: Colors.white70, size: 24),
                      ),
                    ),
                  ),
                ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                    ),
                  ),
                  child: Text(
                    isPremium ? user.name : 'Aç',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
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
            // Sol: Kullanıcı Profil Avatarı
            Consumer<UserProvider>(
              builder: (context, userProvider, _) {
                final user = userProvider.currentUser;
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    // Profil sayfasına git (bottom nav index 4)
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Profilini görmek için alt menüden Profil sekmesine git!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: user?.isPremium == true ? AppColors.goldGradient : null,
                      border: user?.isPremium == true ? null : Border.all(color: Colors.white.withOpacity(0.2), width: 1),
                      boxShadow: user?.isPremium == true ? [
                        BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 8, spreadRadius: 1)
                      ] : null,
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(user?.isPremium == true ? 2 : 0),
                      child: Container(
                        decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.scaffold),
                        child: ClipOval(
                          child: user?.imageUrl != null
                              ? CachedNetworkImage(
                                  imageUrl: user!.imageUrl,
                                  fit: BoxFit.cover,
                                  placeholder: (_, __) => Container(color: AppColors.surface),
                                  errorWidget: (_, __, ___) => const Icon(Icons.person, color: Colors.white54, size: 18),
                                )
                              : const Icon(Icons.person, color: Colors.white54, size: 18),
                        ),
                      ),
                    ),
                  ),
                );
              },
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
            
            // Sağ: Arama, Spaces, Notifications ve Filtre
            Row(
              children: [
                // 🎙️ Sesli Odalar (Spaces)
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SpacesScreen()),
                    );
                  },
                  child: const Icon(
                    Icons.graphic_eq_rounded,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                // 🔍 Arama butonu
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() => _showSearchBar = !_showSearchBar);
                    if (!_showSearchBar) {
                      _searchController.clear();
                      _searchResults.clear();
                      _searchQuery = '';
                    }
                  },
                  child: Icon(
                    _showSearchBar ? Icons.close : Icons.search_rounded,
                    color: _showSearchBar ? AppColors.primary : Colors.white.withOpacity(0.8),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())),
                  child: Icon(Icons.notifications_outlined, color: Colors.white.withOpacity(0.8), size: 24),
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => SizedBox(
                        height: MediaQuery.of(context).size.height * 0.85,
                        child: AdvancedFiltersModal(
                          isPremium: context.read<UserProvider>().currentUser?.isPremium ?? false,
                          currentFilters: {
                            'minAge': _filterSettings.ageRange.start.toInt(),
                            'maxAge': _filterSettings.ageRange.end.toInt(),
                            'maxDistance': 50,
                            'gender': _filterSettings.gender,
                            'interests': [],
                            'relationshipGoal': null,
                            'verifiedOnly': false,
                            'hasPhotoOnly': true,
                            'onlineOnly': false,
                          },
                          onApplyFilters: (filters) {
                            setState(() {
                              _filterSettings = FilterSettings(
                                gender: filters['gender'] ?? 'all',
                                ageRange: RangeValues(
                                  filters['minAge'].toDouble(),
                                  filters['maxAge'].toDouble(),
                                ),
                              );
                            });
                            context.read<DiscoveryProvider>().loadDiscoveryUsers(
                              gender: filters['gender'] ?? 'all',
                              minAge: filters['minAge'] ?? 18,
                              maxAge: filters['maxAge'] ?? 50,
                              interests: filters['interests'],
                              forceRefresh: true,
                            );
                          },
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                    ),
                    child: const Icon(Icons.filter_list_rounded, color: AppColors.primary, size: 20),
                  ),
                ),
              ],
            ),

          ],
        ),
      ),
    );
  }

  /// Instagram benzeri arama barı
  Widget _buildSearchBar() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      height: _showSearchBar ? null : 0,
      child: _showSearchBar ? Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
        ),
        child: Column(
          children: [
            // Arama input
            Container(
              decoration: BoxDecoration(
                color: AppColors.scaffold,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                autofocus: true,
                style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'Profil ara...',
                  hintStyle: GoogleFonts.plusJakartaSans(color: Colors.white38, fontSize: 15),
                  prefixIcon: const Icon(Icons.search, color: Colors.white38, size: 20),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.white38, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            _onSearchChanged('');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
            
            // Arama sonuçları
            if (_isSearching)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('Aranıyor...', style: GoogleFonts.plusJakartaSans(color: Colors.white54, fontSize: 12)),
                  ],
                ),
              )
            else if (_searchResults.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 12),
                constraints: const BoxConstraints(maxHeight: 280),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final user = _searchResults[index];
                    return _buildSearchResultItem(user);
                  },
                ),
              )
            else if (_searchQuery.length >= 2)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  'Sonuç bulunamadı',
                  style: GoogleFonts.plusJakartaSans(color: Colors.white38, fontSize: 13),
                ),
              ),
          ],
        ),
      ) : const SizedBox.shrink(),
    );
  }

  /// Arama sonucu öğesi
  Widget _buildSearchResultItem(UserProfile user) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        // Profil detayına git
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => UserProfileDetailScreen(user: user),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.03))),
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 2),
              ),
              child: ClipOval(
                child: CachedNetworkImage(
                  imageUrl: user.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(color: AppColors.surface),
                  errorWidget: (_, __, ___) => const Icon(Icons.person, color: Colors.white38),
                ),
              ),
            ),
            const SizedBox(width: 12),
            
            // İsim ve bilgiler
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        user.name,
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (user.isVerified) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.verified, color: Colors.blue, size: 14),
                      ],
                      if (user.isPremium) ...[
                        const SizedBox(width: 4),
                        ShaderMask(
                          shaderCallback: (bounds) => AppColors.goldGradient.createShader(bounds),
                          child: const Icon(Icons.star, color: Colors.white, size: 14),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${user.age} • ${user.location ?? user.country}',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            
            // Ok ikonu
            Icon(Icons.chevron_right, color: Colors.white24, size: 20),
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
                              backgroundImage: NetworkImage(myStories.userAvatar),
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
      child: GestureDetector(
        onTap: () => _onCardTap(user),
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
              children: _buildStackChildren(user, showLike, showNope, percentX),
            ),
          ),
        ),
      ),
    );
  }

  void _onCardTap(UserProfile user) {
    HapticFeedback.lightImpact();
    // Visit track et
    DiscoveryService().trackVisit(user.uid);
    
    // Profil detay sayfasını aç
    // Not: UserDetailScreen henüz yoksa oluşturulmalı veya modal açılmalı
    // _showUserDetail(user); 
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
          const SizedBox(width: 24),
          _buildCircleButton(
            onTap: _onBoost,
            size: 40,
            icon: Icons.bolt_rounded,
            color: Colors.purpleAccent,
            borderColor: Colors.purpleAccent.withOpacity(0.4),
            bgColor: Colors.transparent,
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

  List<Widget> _buildStackChildren(UserProfile user, bool showLike, bool showNope, double percentX) {
    final photoUrls = user.photoUrls ?? [user.imageUrl];
    final children = <Widget>[
      // Multi-photo PageView
      PageView.builder(
        itemCount: photoUrls.length,
        onPageChanged: (index) {
          setState(() => _currentPhotoIndex = index);
        },
        itemBuilder: (context, index) {
          return CachedNetworkImage(
            imageUrl: photoUrls[index],
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
          );
        },
      ),
      Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.center,
            colors: [Colors.black.withOpacity(0.3), Colors.transparent],
          ),
        ),
      ),
      Positioned(
        top: 24,
        right: 24,
        child: Row(
          children: [
            if (user.videoUrl != null)
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.8),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.play_arrow_rounded, color: Colors.black, size: 16),
              ),
            Container(
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
          ],
        ),
      ),
      // Photo Indicators
      if (photoUrls.length > 1)
        Positioned(
          top: 12,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              photoUrls.length,
              (index) => Container(
                width: 6,
                height: 6,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentPhotoIndex == index
                    ? AppColors.primary
                    : Colors.white.withOpacity(0.5),
                ),
              ),
            ),
          ),
        ),
      // User Info
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
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      if (user.isVerified) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.verified, color: AppColors.primary, size: 22),
                      ],
                    ],
                  ),
                  if (user.relationshipGoal != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primary.withOpacity(0.5)),
                      ),
                      child: Text(
                        _getGoalLabel(user.relationshipGoal),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
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
    ];
    if (showLike) {
      children.add(Positioned(top: 60, left: 30, child: _buildSwipeLabel('LIKE', AppColors.success, percentX.abs())));
    }
    if (showNope) {
      children.add(Positioned(top: 60, right: 30, child: _buildSwipeLabel('NOPE', AppColors.error, percentX.abs())));
    }
    return children;
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
                    // Kullanıcının kendi avatarı (dinamik)
                    Consumer<UserProvider>(
                      builder: (context, userProvider, _) {
                        final myAvatar = userProvider.currentUser?.imageUrl ?? '';
                        return Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 3),
                          ),
                          child: ClipOval(
                            child: myAvatar.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: myAvatar,
                                    fit: BoxFit.cover,
                                    placeholder: (_, __) => Container(
                                      color: AppColors.surface,
                                      child: const Icon(Icons.person, size: 40, color: Colors.white24),
                                    ),
                                    errorWidget: (_, __, ___) => Container(
                                      color: AppColors.surface,
                                      child: const Icon(Icons.person, size: 40, color: Colors.white24),
                                    ),
                                  )
                                : Container(
                                    color: AppColors.surface,
                                    child: const Icon(Icons.person, size: 40, color: Colors.white24),
                                  ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 24),
                    const Icon(Icons.favorite_rounded, color: AppColors.primary, size: 40),
                    const SizedBox(width: 24),
                    // Eşleşilen kullanıcının avatarı
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 3),
                      ),
                      child: ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: _matchedUser!.imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            color: AppColors.surface,
                            child: const Icon(Icons.person, size: 40, color: Colors.white24),
                          ),
                          errorWidget: (_, __, ___) => Container(
                            color: AppColors.surface,
                            child: const Icon(Icons.person, size: 40, color: Colors.white24),
                          ),
                        ),
                      ),
                    ),
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

  String _getGoalLabel(String? key) {
    switch (key) {
      case 'serious': return '💍 Ciddi';
      case 'casual': return '🥂 Eğlence';
      case 'chat': return '☕ Sohbet';
      case 'unsure': return '🤷‍♂️ Belirsiz';
      default: return '';
    }
  }
}

