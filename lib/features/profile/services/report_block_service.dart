import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/log_service.dart';

/// Report & Block Service
/// Kullanıcı şikayet ve engelleme işlemlerini yönetir
class ReportBlockService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Kullanıcıyı şikayet et
  Future<bool> reportUser({
    required String reportedUserId,
    required String reason,
    required String category,
    String? description,
  }) async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return false;

    try {
      await _firestore.collection('reports').add({
        'reporterId': currentUserId,
        'reportedUserId': reportedUserId,
        'reason': reason,
        'category': category,
        'description': description,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Şikayet sayısını artır (Hata alsa bile şikayet kaydedilsin)
      try {
        await _firestore.collection('users').doc(reportedUserId).update({
          'reportCount': FieldValue.increment(1),
        });
      } catch (e) {
        LogService.w('Could not increment report count for user $reportedUserId: $e');
      }

      LogService.i('User reported: $reportedUserId by $currentUserId');
      return true;
    } catch (e) {
      LogService.e('Error reporting user', e);
      return false;
    }
  }

  /// Kullanıcıyı engelle
  Future<bool> blockUser(String blockedUserId) async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return false;

    try {
      // Engelleme kaydı ekle
      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('blocked_users')
          .doc(blockedUserId)
          .set({
        'blockedAt': FieldValue.serverTimestamp(),
      });

      // Kullanıcının engellenenler listesini güncelle
      await _firestore.collection('users').doc(currentUserId).update({
        'blockedUsers': FieldValue.arrayUnion([blockedUserId]),
      });

      LogService.i('User blocked: $blockedUserId by $currentUserId');
      return true;
    } catch (e) {
      LogService.e('Error blocking user', e);
      return false;
    }
  }

  /// Kullanıcının engelini kaldır
  Future<bool> unblockUser(String blockedUserId) async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return false;

    try {
      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('blocked_users')
          .doc(blockedUserId)
          .delete();

      await _firestore.collection('users').doc(currentUserId).update({
        'blockedUsers': FieldValue.arrayRemove([blockedUserId]),
      });

      LogService.i('User unblocked: $blockedUserId by $currentUserId');
      return true;
    } catch (e) {
      LogService.e('Error unblocking user', e);
      return false;
    }
  }

  /// Kullanıcının engellenmiş olup olmadığını kontrol et
  Future<bool> isUserBlocked(String userId) async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return false;

    try {
      final doc = await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('blocked_users')
          .doc(userId)
          .get();

      return doc.exists;
    } catch (e) {
      LogService.e('Error checking if user is blocked', e);
      return false;
    }
  }

  /// Engellenen kullanıcıları getir
  Stream<List<String>> getBlockedUsersStream() {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(currentUserId)
        .snapshots()
        .map((snapshot) {
      final data = snapshot.data();
      return List<String>.from(data?['blockedUsers'] ?? []);
    });
  }
}

/// Report User Modal
/// Kullanıcı şikayet etme modal'ı
class ReportUserModal extends StatefulWidget {
  final String reportedUserId;
  final String reportedUserName;

  const ReportUserModal({
    super.key,
    required this.reportedUserId,
    required this.reportedUserName,
  });

  @override
  State<ReportUserModal> createState() => _ReportUserModalState();
}

class _ReportUserModalState extends State<ReportUserModal> {
  final _descriptionController = TextEditingController();
  String? _selectedCategory;
  String? _selectedReason;
  bool _isSubmitting = false;

  final List<Map<String, String>> _categories = [
    {
      'id': 'inappropriate_content',
      'label': 'Uygunsuz İçerik',
      'icon': '⚠️'
    },
    {'id': 'harassment', 'label': 'Taciz', 'icon': '🚫'},
    {'id': 'fake_profile', 'label': 'Sahte Profil', 'icon': '🎭'},
    {'id': 'spam', 'label': 'Spam', 'icon': '📧'},
    {'id': 'underage', 'label': 'Yaş Altı', 'icon': '🔞'},
    {'id': 'other', 'label': 'Diğer', 'icon': '📝'},
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.scaffold,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const Icon(Icons.report_problem, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Şikayet Et',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${widget.reportedUserName} kullanıcısını şikayet ediyorsunuz',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          const Divider(color: Colors.white10, height: 1),
          const SizedBox(height: 24),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Selection
                  Text(
                    'ŞİKAYET NEDENİ',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...(_categories.map((category) {
                    final isSelected = _selectedCategory == category['id'];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCategory = category['id'];
                          _selectedReason = category['label'];
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.red.withOpacity(0.1)
                              : Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? Colors.red : Colors.white10,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(category['icon']!,
                                style: const TextStyle(fontSize: 24)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                category['label']!,
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                            if (isSelected)
                              const Icon(Icons.check_circle,
                                  color: Colors.red, size: 20),
                          ],
                        ),
                      ),
                    );
                  }).toList()),

                  const SizedBox(height: 24),

                  // Description
                  Text(
                    'AÇIKLAMA (OPSİYONEL)',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _descriptionController,
                    maxLines: 4,
                    maxLength: 500,
                    style: GoogleFonts.plusJakartaSans(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Detayları açıklayın...',
                      hintStyle: GoogleFonts.plusJakartaSans(
                          color: Colors.white30),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.05),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.white10),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.white10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.primary),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Submit Button
        Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.scaffold,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedCategory == null || _isSubmitting
                      ? null
                      : _submitReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    disabledBackgroundColor: Colors.red.withOpacity(0.3),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'ŞİKAYETİ GÖNDER',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            letterSpacing: 1,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitReport() async {
    if (_selectedCategory == null || _selectedReason == null) return;

    setState(() => _isSubmitting = true);

    final success = await ReportBlockService().reportUser(
      reportedUserId: widget.reportedUserId,
      reason: _selectedReason!,
      category: _selectedCategory!,
      description: _descriptionController.text.trim(),
    );

    if (mounted) {
      setState(() => _isSubmitting = false);
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? '✅ Şikayetiniz alındı. İncelenecektir.'
                : '❌ Şikayet gönderilemedi. Tekrar deneyin.',
            style: GoogleFonts.plusJakartaSans(),
          ),
          backgroundColor: success ? Colors.green : Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

/// Block User Dialog
/// Kullanıcı engelleme onay dialog'u
class BlockUserDialog {
  static Future<bool?> show(
    BuildContext context, {
    required String userName,
    required VoidCallback onBlock,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F2937),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.block, color: Colors.red, size: 28),
            const SizedBox(width: 12),
            Text(
              'Engelle',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          '$userName kullanıcısını engellemek istediğinize emin misiniz?\n\n'
          '• Artık birbirinizi göremeyeceksiniz\n'
          '• Mesajlaşma sona erecek\n'
          '• Eşleşme silinecek',
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white70,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'İptal',
              style: GoogleFonts.plusJakartaSans(color: Colors.white54),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, true);
              onBlock();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Engelle',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
