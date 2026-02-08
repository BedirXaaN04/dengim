import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../models/space_model.dart';
import '../providers/space_provider.dart';
import '../../../core/providers/user_provider.dart';
import '../screens/space_detail_screen.dart';

class CreateSpaceModal extends StatefulWidget {
  const CreateSpaceModal({super.key});

  @override
  State<CreateSpaceModal> createState() => _CreateSpaceModalState();
}

class _CreateSpaceModalState extends State<CreateSpaceModal> {
  final TextEditingController _titleController = TextEditingController();
  SpaceCategory _selectedCategory = SpaceCategory.chat;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 32,
          top: 32,
          left: 24,
          right: 24,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF0F1115).withOpacity(0.95),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Yeni Oda Başlat',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            _buildTextField(
              controller: _titleController,
              label: 'Oda Başlığı',
              hint: 'Neler hakkında konuşacaksınız?',
              maxLength: 60,
            ),
            const SizedBox(height: 20),
            Text(
              'Kategori Seçin',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white60,
              ),
            ),
            const SizedBox(height: 12),
            _buildCategorySelector(),
            const SizedBox(height: 32),
            _buildCreateButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int? maxLength,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white60,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLength: maxLength,
          style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.plusJakartaSans(color: Colors.white24),
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            counterStyle: const TextStyle(color: Colors.white24),
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: SpaceCategory.values.map((cat) {
          final isSelected = _selectedCategory == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(_getCategoryText(cat)),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) setState(() => _selectedCategory = cat);
              },
              selectedColor: AppColors.primary,
              backgroundColor: Colors.white.withOpacity(0.05),
              labelStyle: GoogleFonts.plusJakartaSans(
                color: isSelected ? Colors.black : Colors.white60,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              side: BorderSide.none,
              showCheckmark: false,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCreateButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _handleCreate,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.black,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
      ),
      child: _isLoading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(color: Colors.black, strokeWidth: 3),
            )
          : Text(
              'ODAYI BAŞLAT',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                letterSpacing: 1.0,
              ),
            ),
    );
  }

  String _getCategoryText(SpaceCategory cat) {
    switch (cat) {
      case SpaceCategory.chat: return '💬 Sohbet';
      case SpaceCategory.music: return '🎵 Müzik';
      case SpaceCategory.dating: return '❤️ Tanışma';
      case SpaceCategory.advice: return '💡 Tavsiye';
      case SpaceCategory.fun: return '🎮 Eğlence';
    }
  }

  Future<void> _handleCreate() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen bir başlık girin')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userProvider = context.read<UserProvider>();
      final spaceProvider = context.read<SpaceProvider>();
      
      final roomId = await spaceProvider.createSpace(
        _titleController.text.trim(),
        null, // Description is optional
        userProvider.currentUser!,
      );


      if (mounted && roomId != null) {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SpaceDetailScreen(spaceId: roomId),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
