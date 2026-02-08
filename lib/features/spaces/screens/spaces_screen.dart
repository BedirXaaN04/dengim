import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/space_provider.dart';
import '../widgets/space_card.dart';
import '../../auth/models/user_profile.dart';
import '../../../core/providers/user_provider.dart';
import '../models/space_model.dart';
import '../widgets/create_space_modal.dart';
import 'space_detail_screen.dart';

class SpacesScreen extends StatefulWidget {
  const SpacesScreen({super.key});

  @override
  State<SpacesScreen> createState() => _SpacesScreenState();
}

class _SpacesScreenState extends State<SpacesScreen> {
  @override
  Widget build(BuildContext context) {
    final spaceProvider = context.watch<SpaceProvider>();
    final userProvider = context.read<UserProvider>();
    final currentUser = userProvider.currentUser;

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: Stack(
        children: [
          // Background Glow
          Positioned(
            top: -150,
            right: -150,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.03),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                child: Container(),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                Expanded(
                  child: spaceProvider.spaces.isEmpty
                      ? _buildEmptyState()
                      : _buildSpacesList(spaceProvider.spaces),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildCreateButton(currentUser),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.05),
                  padding: const EdgeInsets.all(12),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.graphic_eq_rounded, color: AppColors.primary, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'SESLİ ODALAR',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Text(
            'Neler Konuşuluyor?',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Canlı sohbetlere katılın veya kendi odanızı oluşturun.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: Colors.white38,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildSpacesList(List<SpaceRoom> spaces) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: spaces.length,
      itemBuilder: (context, index) {
        return SpaceCard(
          space: spaces[index],
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SpaceDetailScreen(spaceId: spaces[index].id),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.mic_none_rounded,
              size: 64,
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Henüz aktif oda yok',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'İlk odayı sen başlatabilirsin!',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: Colors.white38,
            ),
          ),
        ],
      ),
    );
  }

  Widget? _buildCreateButton(UserProfile? user) {
    if (user == null) return null;

    // Sadece VIP Premium, Admin veya Moderatörler buton görebilir
    final canCreate = user.isPremium || 
                     user.role == UserRole.admin || 
                     user.role == UserRole.moderator;

    if (!canCreate) return null;

    return FloatingActionButton.extended(
      onPressed: () => _showCreateSpaceModal(context),
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.black,
      elevation: 4,
      label: Text(
        'ODA BAŞLAT',
        style: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w800,
          fontSize: 14,
          letterSpacing: 1.0,
        ),
      ),
      icon: const Icon(Icons.add_rounded, size: 24),
    );
  }


  void _showCreateSpaceModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CreateSpaceModal(),
    );
  }
}
