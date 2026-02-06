import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/user_provider.dart';
import '../../core/utils/error_handler.dart';
import '../auth/services/profile_service.dart';
import '../auth/models/user_profile.dart';
import 'package:cached_network_image/cached_network_image.dart';

class EditProfileScreen extends StatefulWidget {
  final UserProfile profile;

  const EditProfileScreen({super.key, required this.profile});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _jobController;
  late TextEditingController _educationController;
  late TextEditingController _ageController;
  late TextEditingController _countryController;
  
  List<String> _photoUrls = [];
  List<String> _selectedInterests = [];
  bool _isSaving = false;
  bool _hasChanges = false;

  final List<String> _allInterests = [
    'Spor', 'Müzik', 'Sanat', 'Film', 'Okuma', 'Seyahat',
    'Yeme-İçme', 'Fotoğrafçılık', 'Dans', 'Yoga', 'Oyun',
    'Fitness', 'Moda', 'Doğa', 'Teknoloji', 'Girişimcilik',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _bioController = TextEditingController(text: widget.profile.bio ?? '');
    _jobController = TextEditingController(text: widget.profile.job ?? '');
    _educationController = TextEditingController(text: widget.profile.education ?? '');
    _ageController = TextEditingController(text: widget.profile.age.toString());
    _countryController = TextEditingController(text: widget.profile.country);
    _photoUrls = List.from(widget.profile.photoUrls ?? []);
    _selectedInterests = List.from(widget.profile.interests);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _jobController.dispose();
    _educationController.dispose();
    _ageController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadPhoto() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    
    if (image != null) {
      setState(() => _isSaving = true);
      try {
        final url = await ProfileService().uploadProfilePhoto(image, widget.profile.uid);
        setState(() {
          _photoUrls.add(url);
          _hasChanges = true;
        });
      } catch (e) {
        if (mounted) ErrorHandler.showError(context, "Fotoğraf yüklenemedi: $e");
      } finally {
        if (mounted) setState(() => _isSaving = false);
      }
    }
  }

  void _removePhoto(int index) {
    setState(() {
      _photoUrls.removeAt(index);
      _hasChanges = true;
    });
  }

  void _toggleInterest(String interest) {
    setState(() {
      if (_selectedInterests.contains(interest)) {
        _selectedInterests.remove(interest);
      } else if (_selectedInterests.length < 6) {
        _selectedInterests.add(interest);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('En fazla 6 ilgi alanı seçebilirsiniz')),
        );
      }
      _hasChanges = true;
    });
  }

  Future<void> _saveProfile() async {
    // Validation
    if (_nameController.text.trim().isEmpty) {
      ErrorHandler.showError(context, "İsim boş bırakılamaz");
      return;
    }
    
    if (_photoUrls.isEmpty) {
      ErrorHandler.showError(context, "En az 1 fotoğraf eklemelisiniz");
      return;
    }

    if (_selectedInterests.isEmpty) {
      ErrorHandler.showError(context, "En az 1 ilgi alanı seçmelisiniz");
      return;
    }

    setState(() => _isSaving = true);

    try {
      await ProfileService().updateProfile(
        name: _nameController.text.trim(),
        bio: _bioController.text.trim().isNotEmpty ? _bioController.text.trim() : null,
        job: _jobController.text.trim().isNotEmpty ? _jobController.text.trim() : null,
        education: _educationController.text.trim().isNotEmpty ? _educationController.text.trim() : null,
        age: int.tryParse(_ageController.text.trim()) ?? widget.profile.age,
        country: _countryController.text.trim(),
        photoUrls: _photoUrls,
        interests: _selectedInterests,
      );

      // Refresh provider
      await context.read<UserProvider>().loadCurrentUser();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Profil güncellendi!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ErrorHandler.showError(context, "Kaydetme hatası: $e");
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () {
            if (_hasChanges) {
              _showDiscardDialog();
            } else {
              Navigator.pop(context);
            }
          },
        ),
        centerTitle: true,
        title: Text(
          "PROFİLİ DÜZENLE",
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
            color: Colors.white,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveProfile,
            child: _isSaving
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))
                : Text(
                    'Kaydet',
                    style: GoogleFonts.plusJakartaSans(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photos Section
            _buildSectionHeader("FOTOĞRAFLAR"),
            const SizedBox(height: 12),
            _buildPhotosGrid(),
            
            const SizedBox(height: 32),
            
            // Basic Info
            _buildSectionHeader("TEMEL BİLGİLER"),
            const SizedBox(height: 16),
            _buildTextField("İsim", _nameController, Icons.person_outline),
            _buildTextField("Yaş", _ageController, Icons.cake_outlined, keyboardType: TextInputType.number),
            _buildTextField("Konum", _countryController, Icons.location_on_outlined),
            
            const SizedBox(height: 32),
            
            // About
            _buildSectionHeader("HAKKINDA"),
            const SizedBox(height: 16),
            _buildTextField("Biyografi", _bioController, Icons.edit_note, maxLines: 4, hint: "Kendinden bahset..."),
            _buildTextField("Meslek", _jobController, Icons.work_outline, hint: "Örn: Yazılım Mühendisi"),
            _buildTextField("Eğitim", _educationController, Icons.school_outlined, hint: "Örn: İstanbul Üniversitesi"),
            
            const SizedBox(height: 32),
            
            // Interests
            _buildSectionHeader("İLGİ ALANLARI (${_selectedInterests.length}/6)"),
            const SizedBox(height: 16),
            _buildInterestsGrid(),
            
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildPhotosGrid() {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _photoUrls.length + 1,
        itemBuilder: (context, index) {
          if (index == _photoUrls.length) {
            // Add Photo Button
            return GestureDetector(
              onTap: _pickAndUploadPhoto,
              child: Container(
                width: 100,
                height: 120,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary.withOpacity(0.5), style: BorderStyle.solid),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_photo_alternate_outlined, color: AppColors.primary, size: 28),
                    const SizedBox(height: 8),
                    Text(
                      'Ekle',
                      style: GoogleFonts.plusJakartaSans(color: AppColors.primary, fontSize: 12),
                    ),
                  ],
                ),
              ),
            );
          }
          
          // Photo Item
          return Stack(
            children: [
              Container(
                width: 100,
                height: 120,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: index == 0 
                      ? Border.all(color: AppColors.primary, width: 2) 
                      : null,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: CachedNetworkImage(
                    imageUrl: _photoUrls[index],
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(color: AppColors.surface),
                    errorWidget: (context, url, error) => const Icon(Icons.error),
                  ),
                ),
              ),
              if (index == 0)
                Positioned(
                  bottom: 4,
                  left: 0,
                  right: 12,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Ana',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              // Delete Button
              Positioned(
                top: 4,
                right: 16,
                child: GestureDetector(
                  onTap: () => _removePhoto(index),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, color: Colors.white, size: 14),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? hint,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: GoogleFonts.plusJakartaSans(color: Colors.white),
        onChanged: (_) => _hasChanges = true,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          hintStyle: GoogleFonts.plusJakartaSans(color: Colors.white30),
          labelStyle: GoogleFonts.plusJakartaSans(color: Colors.white54),
          prefixIcon: Icon(icon, color: Colors.white54, size: 20),
          filled: true,
          fillColor: Colors.white.withOpacity(0.05),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary),
          ),
        ),
      ),
    );
  }

  Widget _buildInterestsGrid() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _allInterests.map((interest) {
        final isSelected = _selectedInterests.contains(interest);
        return GestureDetector(
          onTap: () => _toggleInterest(interest),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary.withOpacity(0.2) : Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? AppColors.primary : Colors.white.withOpacity(0.1),
              ),
            ),
            child: Text(
              interest,
              style: GoogleFonts.plusJakartaSans(
                color: isSelected ? AppColors.primary : Colors.white70,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _showDiscardDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F2937),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Değişiklikler Kaybolacak", style: TextStyle(color: Colors.white)),
        content: Text(
          "Yaptığınız değişiklikler kaydedilmedi. Çıkmak istediğinize emin misiniz?",
          style: TextStyle(color: Colors.white.withOpacity(0.7)),
        ),
        actions: [
          TextButton(
            child: const Text("İptal", style: TextStyle(color: Colors.white54)),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close edit screen
            },
            child: const Text("Çık"),
          ),
        ],
      ),
    );
  }
}
