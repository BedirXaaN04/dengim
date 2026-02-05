import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/error_handler.dart';
import '../../core/widgets/state_widgets.dart';
import '../auth/models/user_profile.dart';
import '../auth/services/block_service.dart';

/// Engellenen kullanıcılar listesi ekranı
class BlockedUsersScreen extends StatefulWidget {
  const BlockedUsersScreen({super.key});

  @override
  State<BlockedUsersScreen> createState() => _BlockedUsersScreenState();
}

class _BlockedUsersScreenState extends State<BlockedUsersScreen> {
  final BlockService _blockService = BlockService();
  List<UserProfile> _blockedUsers = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBlockedUsers();
  }

  Future<void> _loadBlockedUsers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final users = await _blockService.getBlockedUsers();
      if (mounted) {
        setState(() {
          _blockedUsers = users;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _unblockUser(UserProfile user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          '${user.name} Engelini Kaldır?',
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Bu kullanıcının engelini kaldırdığınızda tekrar birbirinizi görebilir ve mesajlaşabilirsiniz.',
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white.withOpacity(0.7),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'İptal',
              style: TextStyle(color: Colors.white.withOpacity(0.5)),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Engeli Kaldır'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _blockService.unblockUser(user.uid);
      if (success && mounted) {
        setState(() {
          _blockedUsers.removeWhere((u) => u.uid == user.uid);
        });
        ErrorHandler.showSuccess(context, '${user.name} engeli kaldırıldı');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'ENGELLENEN KULLANICILAR',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: Colors.white,
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const ListLoadingShimmer(itemCount: 5, itemHeight: 72);
    }

    if (_error != null) {
      return ErrorStateWidget(
        message: _error,
        onRetry: _loadBlockedUsers,
      );
    }

    if (_blockedUsers.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.block,
        title: 'Engellenen kullanıcı yok',
        subtitle: 'Engellediğiniz kullanıcılar burada görünecek.',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadBlockedUsers,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _blockedUsers.length,
        itemBuilder: (context, index) => _buildUserTile(_blockedUsers[index]),
      ),
    );
  }

  Widget _buildUserTile(UserProfile user) {
    final photoUrl = user.photoUrls?.isNotEmpty == true
        ? user.photoUrls!.first
        : 'https://via.placeholder.com/100';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.red.withOpacity(0.3), width: 2),
            ),
            child: ClipOval(
              child: CachedNetworkImage(
                imageUrl: photoUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(color: AppColors.surface),
                errorWidget: (_, __, ___) => Container(
                  color: AppColors.surface,
                  child: const Icon(Icons.person, color: Colors.white54),
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${user.name}, ${user.age}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.block, size: 14, color: Colors.red.withOpacity(0.6)),
                    const SizedBox(width: 4),
                    Text(
                      'Engellendi',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: Colors.red.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Unblock Button
          TextButton(
            onPressed: () => _unblockUser(user),
            child: Text(
              'Engeli Kaldır',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
