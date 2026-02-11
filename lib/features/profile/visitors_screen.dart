import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_colors.dart';
import '../auth/models/user_profile.dart';
import '../auth/services/discovery_service.dart';
import '../../../core/providers/user_provider.dart';
import '../payment/premium_offer_screen.dart';

class VisitorsScreen extends StatefulWidget {
  const VisitorsScreen({super.key});

  @override
  State<VisitorsScreen> createState() => _VisitorsScreenState();
}

class _VisitorsScreenState extends State<VisitorsScreen> {
  List<UserProfile> _visitors = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVisitors();
  }

  Future<void> _loadVisitors() async {
    final visitors = await DiscoveryService().getProfileVisitors();
    if (mounted) {
      setState(() {
        _visitors = visitors;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final isPremium = userProvider.currentUser?.isPremium ?? false;

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Profil Ziyaretçileri",
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _visitors.isEmpty
              ? _buildEmptyState()
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: _visitors.length,
                  itemBuilder: (context, index) {
                    return _VisitorCard(
                      user: _visitors[index],
                      isPremium: isPremium,
                    );
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.visibility_off_rounded, size: 40, color: Colors.white24),
          ),
          const SizedBox(height: 20),
          Text(
            "Henüz ziyaretçi yok",
            style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "Profilini öne çıkararak daha fazla\ngörünürlük elde edebilirsin!",
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(color: Colors.white38, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _VisitorCard extends StatelessWidget {
  final UserProfile user;
  final bool isPremium;

  const _VisitorCard({required this.user, required this.isPremium});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!isPremium) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const PremiumOfferScreen()));
        } else {
          // Profil detayını aç
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white10),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: user.imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(color: AppColors.surface),
              ),
              if (!isPremium)
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    color: Colors.black.withOpacity(0.4),
                    child: const Center(
                      child: Icon(Icons.lock_rounded, color: Colors.white70, size: 30),
                    ),
                  ),
                ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        isPremium ? user.name : "Gizli Profil",
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (isPremium)
                        Text(
                          "${user.age} • ${user.location ?? user.country}",
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white70,
                            fontSize: 10,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
