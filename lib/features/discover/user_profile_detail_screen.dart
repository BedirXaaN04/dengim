import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/safety_service.dart';
import '../auth/models/user_profile.dart';
import '../auth/services/discovery_service.dart';
import '../profile/services/report_block_service.dart';
import '../profile/widgets/video_player_modal.dart';

class UserProfileDetailScreen extends StatefulWidget {
  final String? userId;
  final UserProfile? user;

  const UserProfileDetailScreen({super.key, this.userId, this.user})
      : assert(userId != null || user != null, 'Either userId or user must be provided');

  @override
  State<UserProfileDetailScreen> createState() => _UserProfileDetailScreenState();
}

class _UserProfileDetailScreenState extends State<UserProfileDetailScreen> {
  
  @override
  void initState() {
    super.initState();
    final targetId = widget.userId ?? widget.user?.uid;
    if (targetId != null) {
      DiscoveryService().trackVisit(targetId);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.user != null) {
      return _buildProfileUI(context, widget.user!);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(widget.userId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Kullanıcı bulunamadı", style: TextStyle(color: Colors.black)));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final profile = UserProfile.fromMap(data);
          return _buildProfileUI(context, profile);
        },
      ),
    );
  }

  Widget _buildProfileUI(BuildContext context, UserProfile profile) {
    final photoUrls = (profile.photoUrls != null && profile.photoUrls!.isNotEmpty) 
        ? profile.photoUrls! 
        : [profile.imageUrl];
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // 1. Image Header
              SliverAppBar(
                expandedHeight: MediaQuery.of(context).size.height * 0.6,
                backgroundColor: Colors.white,
                elevation: 0,
                leading: const SizedBox.shrink(), // Custom lead handled in Stack
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      PageView.builder(
                        itemCount: photoUrls.length,
                        itemBuilder: (context, index) {
                          return CachedNetworkImage(
                            imageUrl: photoUrls[index],
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(color: Colors.black12),
                            errorWidget: (context, url, error) => const Icon(Icons.error),
                          );
                        },
                      ),
                      // Gradient Overlay for text readability
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.3),
                                Colors.transparent,
                                Colors.transparent,
                                Colors.black.withOpacity(0.5),
                              ],
                              stops: const [0, 0.2, 0.7, 1],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. Profile Info
              SliverToBoxAdapter(
                child: Transform.translate(
                  offset: const Offset(0, -30),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                      border: Border(top: BorderSide(color: Colors.black, width: 4)),
                    ),
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name & Age Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          "${profile.name}, ${profile.age}".toUpperCase(),
                                          style: GoogleFonts.outfit(
                                            fontSize: 28,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.black,
                                            letterSpacing: -1.0,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (profile.isVerified) ...[
                                        const SizedBox(width: 8),
                                        const Icon(Icons.verified, color: Colors.blue, size: 24),
                                      ],
                                      if (profile.isPremium) ...[
                                        const SizedBox(width: 8),
                                        ShaderMask(
                                          shaderCallback: (bounds) => AppColors.goldGradient.createShader(bounds),
                                          child: const Icon(Icons.star, color: Colors.white, size: 24),
                                        ),
                                      ],
                                    ],
                                  ),
                                  if (profile.job != null && profile.job!.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        profile.job!.toUpperCase(),
                                        style: GoogleFonts.outfit(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.black.withOpacity(0.5),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            _buildOnlineStatus(profile.isOnline),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Info Chips Section
                        _buildInfoChips(profile),
                        const SizedBox(height: 32),

                        // Bio Section
                        _buildSectionTitle("HAKKIMDA"),
                        const SizedBox(height: 12),
                        Text(
                          profile.bio ?? "HENÜZ BİR BİLGİ EKLENMEMİŞ.",
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Video Profile Button
                        if (profile.videoUrl != null) ...[
                          _buildNeoActionButton(
                            label: 'VİDEO PROFİLİ İZLE',
                            icon: Icons.play_circle_fill,
                            color: AppColors.primary,
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.black,
                                builder: (context) => VideoPlayerModal(videoUrl: profile.videoUrl!),
                              );
                            },
                          ),
                          const SizedBox(height: 32),
                        ],

                        // Interests Section
                        if (profile.interests != null && profile.interests!.isNotEmpty) ...[
                          _buildSectionTitle("İLGİ ALANLARI"),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: profile.interests!.map((interest) => _buildInterestTag(interest)).toList(),
                          ),
                        ],

                        const SizedBox(height: 48),
                        
                        // Safety Advice
                        _buildSafetyBox(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Floating Header Buttons
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildFloatingButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onTap: () => Navigator.pop(context),
                ),
                _buildFloatingButton(
                  icon: Icons.more_vert_rounded,
                  onTap: () => _showMoreOptions(context, profile.uid, profile.name),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.w900,
        color: Colors.black,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildInterestTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black, width: 2),
        boxShadow: const [
          BoxShadow(color: Colors.black, offset: Offset(2, 2)),
        ],
      ),
      child: Text(
        text.toUpperCase(),
        style: GoogleFonts.outfit(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildOnlineStatus(bool isOnline) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isOnline ? AppColors.green.withOpacity(0.1) : Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isOnline ? AppColors.green : Colors.black, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8, height: 8,
            decoration: BoxDecoration(
              color: isOnline ? AppColors.green : Colors.grey,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            isOnline ? "AÇIK" : "KAPALI",
            style: GoogleFonts.outfit(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: isOnline ? AppColors.green : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChips(UserProfile profile) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        if (profile.gender != null) _buildInfoChip(Icons.person_outline, profile.gender!),
        if (profile.relationshipGoal != null) _buildInfoChip(Icons.search_rounded, _getGoalLabel(profile.relationshipGoal)),
        _buildInfoChip(Icons.location_on_outlined, "YAKINLARDA"),
      ],
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withOpacity(0.1), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.black54),
          const SizedBox(width: 8),
          Text(
            text.toUpperCase(),
            style: GoogleFonts.outfit(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black, width: 3),
          boxShadow: const [
            BoxShadow(color: Colors.black, offset: Offset(4, 4)),
          ],
        ),
        child: Icon(icon, color: Colors.black, size: 22),
      ),
    );
  }

  Widget _buildNeoActionButton({
    required String label, 
    required IconData icon, 
    required Color color, 
    required VoidCallback onTap
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black, width: 3),
          boxShadow: const [
            BoxShadow(color: Colors.black, offset: Offset(6, 6)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.black, size: 24),
            const SizedBox(width: 16),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: Colors.black,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSafetyBox() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.blue, width: 2, style: BorderStyle.solid),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.shield_outlined, color: AppColors.blue, size: 24),
              const SizedBox(width: 12),
              Text(
                "GÜVENLİK TAVSİYESİ",
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: AppColors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "KENDİNİ GÜVENDE TUTMAK İÇİN ASLA PARA GÖNDERME VEYA FİNANSAL BİLGİLERİNİ PAYLAŞMA.",
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Colors.black54,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  void _showMoreOptions(BuildContext context, String targetUserId, String name) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
        side: BorderSide(color: Colors.black, width: 4),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4, 
              decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 32),
            Text(
              "SEÇENEKLER",
              style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.black),
            ),
            const SizedBox(height: 32),
            _buildOptionButton(
              label: 'KULLANICIYI ŞİKAYET ET',
              icon: Icons.report_problem_rounded,
              color: AppColors.secondary,
              onTap: () {
                Navigator.pop(context);
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => SizedBox(
                    height: MediaQuery.of(context).size.height * 0.85,
                    child: ReportUserModal(
                      reportedUserId: targetUserId,
                      reportedUserName: name,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildOptionButton(
              label: 'KULLANICIYI ENGELLE',
              icon: Icons.block_flipped,
              color: AppColors.error,
              onTap: () async {
                Navigator.pop(context);
                await BlockUserDialog.show(
                  context,
                  userName: name,
                  onBlock: () async {
                    await ReportBlockService().blockUser(targetUserId);
                    if (!context.mounted) return;
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Kullanıcı engellendi.")),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton({
    required String label, 
    required IconData icon, 
    required Color color, 
    required VoidCallback onTap
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black, width: 3),
          boxShadow: const [
            BoxShadow(color: Colors.black, offset: Offset(4, 4)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.black, size: 22),
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: Colors.black,
              ),
            ),
          ],
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
      default: return 'Bilinmiyor';
    }
  }
}
