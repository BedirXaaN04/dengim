import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../auth/models/user_profile.dart';
import '../auth/services/profile_service.dart';
import '../auth/services/discovery_service.dart';
import '../../core/utils/log_service.dart';
import 'widgets/filter_bottom_sheet.dart';

/// Keşfet Ekranı - Tinder tarzı Swipe Kartlar
import 'package:provider/provider.dart';
import '../../core/providers/discovery_provider.dart';
import '../../core/providers/user_provider.dart';
import '../../core/providers/credit_provider.dart';
import '../../core/services/credit_service.dart';
import '../../core/constants/tier_limits.dart';
import '../payment/premium_offer_screen.dart';
import '../../core/widgets/premium_required_modal.dart';
import 'user_profile_detail_screen.dart';
import 'widgets/discover_header.dart';
import 'widgets/swipe_action_buttons.dart';
import 'widgets/discover_empty_state.dart';
import 'widgets/match_overlay.dart';
import 'widgets/discover_search_bar.dart';
import 'widgets/discover_user_card.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final CardSwiperController _cardController = CardSwiperController();
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
        interests: _filterSettings.interests.isNotEmpty ? _filterSettings.interests : null,
        maxDistance: _filterSettings.distance.toInt(),
        verifiedOnly: _filterSettings.verifiedOnly,
        hasPhotoOnly: _filterSettings.hasPhotoOnly,
        onlineOnly: _filterSettings.onlineOnly,
        relationshipGoal: _filterSettings.relationshipGoal,
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
      
      // Hikayeleri yenile (devre dışı)
      // await context.read<StoryProvider>().loadStories();
      
      // Kullanıcıları yenile
      await context.read<DiscoveryProvider>().loadDiscoveryUsers(
        gender: _filterSettings.gender,
        minAge: _filterSettings.ageRange.start.toInt(),
        maxAge: _filterSettings.ageRange.end.toInt(),
        interests: _filterSettings.interests.isNotEmpty ? _filterSettings.interests : null,
        maxDistance: _filterSettings.distance.toInt(),
        verifiedOnly: _filterSettings.verifiedOnly,
        hasPhotoOnly: _filterSettings.hasPhotoOnly,
        onlineOnly: _filterSettings.onlineOnly,
        relationshipGoal: _filterSettings.relationshipGoal,
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
  }

  UserProfile? _matchedUser;
  bool _showMatch = false;

  @override
  void dispose() {
    _cardController.dispose();
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

  void _onUndo() {
    HapticFeedback.lightImpact();
    _cardController.undo();
  }

  void _onBoost() async {
    final userProvider = context.read<UserProvider>();
    final currentUser = userProvider.currentUser;
    final tier = currentUser?.subscriptionTier ?? 'free';
    
    // Check if already boosted
    if (currentUser?.isBoosted ?? false) {
       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text('Zaten bir boost aktif!'))
       );
       return;
    }

    if (TierLimits.canBoost(tier)) {
      _showBoostActivationDialog();
    } else {
      // Free kullanıcı - kredi ile boost alabilir
      final creditProvider = context.read<CreditProvider>();
      if (creditProvider.balance >= CreditService.costBoost) {
        final success = await creditProvider.spendBoost();
        if (success) {
          _showBoostActivationDialog();
        }
      } else {
        if (mounted) {
          PremiumRequiredModal.show(
            context,
            featureName: 'Boost',
            requiredTier: 'gold',
            creditCost: CreditService.costBoost,
          );
        }
      }
    }
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
                color: Colors.black.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.bolt_rounded, color: Colors.black, size: 24),
            ),
            const SizedBox(width: 12),
            Text('Profilini Öne Çıkar', 
              style: GoogleFonts.plusJakartaSans(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              )
            ),
          ],
        ),
        content: Text(
          '30 dakika boyunca profilin daha fazla kişi tarafından görülecek ve eşleşme şansın artacak!',
          style: GoogleFonts.plusJakartaSans(
            color: Colors.black87,
            fontSize: 14,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('İptal', 
              style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary, fontWeight: FontWeight.bold)
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<DiscoveryProvider>().activateBoost();
              HapticFeedback.heavyImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('🚀 Boost Aktifleştirildi! Profilin öne çıkıyor.', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  backgroundColor: AppColors.primary, // Black
                  behavior: SnackBarBehavior.floating,
                )
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
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
          interests: settings.interests.isNotEmpty ? settings.interests : null,
          maxDistance: settings.distance.toInt(),
          verifiedOnly: settings.verifiedOnly,
          hasPhotoOnly: settings.hasPhotoOnly,
          onlineOnly: settings.onlineOnly,
          relationshipGoal: settings.relationshipGoal,
          forceRefresh: true,
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

  void _onCardTap(UserProfile user) {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserProfileDetailScreen(user: user),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer<DiscoveryProvider>(
        builder: (context, provider, child) {
          return Stack(
            children: [
              RefreshIndicator(
                onRefresh: _refreshData,
                color: Colors.black,
                backgroundColor: Colors.white,
                displacement: 40,
                strokeWidth: 3,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          DiscoverHeader(
                            showSearchBar: _showSearchBar,
                            onSearchToggle: () {
                              HapticFeedback.lightImpact();
                              setState(() => _showSearchBar = !_showSearchBar);
                            },
                            filterSettings: _filterSettings,
                            onFiltersApplied: (settings) {
                              setState(() => _filterSettings = settings);
                            },
                          ),
                          DiscoverSearchBar(
                            showSearchBar: _showSearchBar,
                            searchController: _searchController,
                            searchQuery: _searchQuery,
                            isSearching: _isSearching,
                            searchResults: _searchResults,
                            onSearchChanged: _onSearchChanged,
                            onClear: () {
                              _searchController.clear();
                              _onSearchChanged('');
                            },
                          ),
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
                                    ? DiscoverEmptyState(onShowFilters: _showFilters)
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
                                          ),
                                          cardBuilder: (context, index, percentThresholdX, percentThresholdY) {
                                            final user = provider.users[index];
                                            return DiscoverUserCard(
                                              user: user,
                                              percentX: percentThresholdX.toDouble() ?? 0.0,
                                              percentY: percentThresholdY.toDouble() ?? 0.0,
                                              onTap: () => _onCardTap(user),
                                            );
                                          },
                                        ),
                                      ),
                          ),
                          SwipeActionButtons(
                            onUndo: _onUndo,
                            onDislike: _onDislike,
                            onLike: _onLike,
                          ),
                          const SafeArea(bottom: true, child: SizedBox(height: 24)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Refresh indicator overlay
              if (_isRefreshing)
                Positioned(
                  top: MediaQuery.of(context).padding.top + 60,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Color(0xFFEEEEEE), width: 1.0),
                        boxShadow: [AppColors.neoShadowSmall],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.black),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'YENİLENİYOR...',
                            style: GoogleFonts.outfit(
                              color: Colors.black,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // Match overlay (B&W)
              if (_showMatch && _matchedUser != null)
                MatchOverlay(
                  matchedUser: _matchedUser!,
                  onDismiss: _dismissMatch,
                  onMessage: _dismissMatch,
                ),
            ],
          );
        },
      ),
    );
  }
}


