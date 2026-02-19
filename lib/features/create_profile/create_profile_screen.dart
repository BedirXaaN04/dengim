import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
// import '../features.dart'; 
import 'package:dengim/features/main/main_scaffold.dart'; 
import '../auth/services/profile_service.dart';
import '../../core/providers/user_provider.dart';
import '../../core/utils/log_service.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'dart:typed_data';

class CreateProfileScreen extends StatefulWidget {
  const CreateProfileScreen({super.key});

  @override
  State<CreateProfileScreen> createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  final ProfileService _profileService = ProfileService();
  
  Future<void> _pickImage(int index) async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 75);
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _profilePhotos[index] = image;
          _photoBytes[index] = bytes;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fotoğraf seçilemedi: $e')),
        );
      }
    }
  }
  
  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _jobController = TextEditingController();
  final TextEditingController _dayController = TextEditingController();
  final TextEditingController _monthController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  
  @override
  void dispose() {
    _nameController.dispose();
    _countryController.dispose();
    _bioController.dispose();
    _jobController.dispose();
    _dayController.dispose();
    _monthController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  DateTime? _getBirthDateFromFields() {
    final day = int.tryParse(_dayController.text);
    final month = int.tryParse(_monthController.text);
    final year = int.tryParse(_yearController.text);
    
    if (day == null || month == null || year == null) return null;
    if (day < 1 || day > 31) return null;
    if (month < 1 || month > 12) return null;
    if (year < 1924 || year > DateTime.now().year) return null;
    
    try {
      return DateTime(year, month, day);
    } catch (e) {
      return null;
    }
  }

  int? _calculateAge() {
    final birthDate = _getBirthDateFromFields();
    if (birthDate == null) return null;
    
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month || 
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }
  // State variables
  String? _selectedGender;
  String? _selectedRelationshipGoal;
  final List<String> _selectedInterests = [];
  
  final List<Map<String, String>> _relationshipGoals = [
    {'id': 'serious', 'label': 'Ciddi İlişki 💍', 'desc': 'Uzun vadeli partner'},
    {'id': 'casual', 'label': 'Eğlence 🥂', 'desc': 'Kısa vadeli takılmaca'},
    {'id': 'chat', 'label': 'Sohbet ☕', 'desc': 'Yeni arkadaşlar'},
    {'id': 'unsure', 'label': 'Belirsiz 🤷‍♂️', 'desc': 'Henüz karar vermedim'},
  ];
  final List<XFile?> _profilePhotos = [null, null, null, null, null, null]; 
  final Map<int, Uint8List> _photoBytes = {}; 
  
  final List<Map<String, dynamic>> _interests = [
    {'name': 'Seyahat', 'icon': Icons.flight},
    {'name': 'Finans', 'icon': Icons.payments},
    {'name': 'Müzik', 'icon': Icons.piano},
    {'name': 'Tenis', 'icon': Icons.sports_tennis},
    {'name': 'Mimari', 'icon': Icons.architecture},
    {'name': 'Yemek', 'icon': Icons.restaurant},
    {'name': 'Sanat', 'icon': Icons.theater_comedy},
    {'name': 'Deniz', 'icon': Icons.sailing},
  ];

  bool _isLoading = false;

  void _submitProfile() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lütfen isminizi giriniz')));
      return;
    }

    if (_getBirthDateFromFields() == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lütfen doğum tarihinizi giriniz')));
      return;
    }

    setState(() => _isLoading = true);
    HapticFeedback.mediumImpact();
    LogService.i("Starting profile submission process...");

    try {
      final userProvider = context.read<UserProvider>();
      
      // Fotoğraf yükleme
      List<String> photoUrls = [];
      try {
        final List<Future<String>> uploadFutures = [];
        final uid = Provider.of<UserProvider>(context, listen: false).currentUser?.uid ?? 'anon';
        
        for (int i = 0; i < _profilePhotos.length; i++) {
          final photo = _profilePhotos[i];
          if (photo != null) {
            if (_photoBytes.containsKey(i)) {
              uploadFutures.add(_profileService.uploadProfilePhotoBytes(_photoBytes[i]!, uid));
            } else {
              uploadFutures.add(_profileService.uploadProfilePhoto(photo, uid));
            }
          }
        }

        if (uploadFutures.isNotEmpty) {
          photoUrls = await Future.wait(uploadFutures).timeout(const Duration(seconds: 30));
        }
      } catch (e) {
        LogService.e("Photo upload failed", e);
      }

      // Firestore kaydı
      await _profileService.createProfile(
        name: _nameController.text.trim(),
        birthDate: _getBirthDateFromFields(),
        gender: _selectedGender ?? 'Diğer',
        country: _countryController.text.trim(),
        interests: _selectedInterests,
        relationshipGoal: _selectedRelationshipGoal,
        photoUrls: photoUrls.isNotEmpty ? photoUrls : ['https://ui-avatars.com/api/?name=${_nameController.text.isNotEmpty ? _nameController.text[0] : "D"}&size=500&background=D4AF37&color=fff'],
        bio: _bioController.text.trim(),
        job: _jobController.text.trim(),
        education: '',
      );

      // Provider'ı güncelle
      await userProvider.loadCurrentUser();

      LogService.i("Profile process finished. Navigating...");
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const MainScaffold()),
          (route) => false,
        );
      }
    } catch (e) {
      LogService.e("Unexpected Error in _submitProfile", e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profil oluşturulamadı: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Minimum bilgilerle profil oluştur (sadece isim gerekli)
  void _submitProfileMinimal() async {
    setState(() => _isLoading = true);
    
    try {
      final userProvider = context.read<UserProvider>();
      final name = _nameController.text.trim().isNotEmpty 
          ? _nameController.text.trim() 
          : 'Kullanıcı';
      
      await _profileService.createProfile(
        name: name,
        birthDate: _getBirthDateFromFields() ?? DateTime(2000, 1, 1),
        gender: _selectedGender ?? 'Belirtilmemiş',
        country: _countryController.text.trim().isNotEmpty ? _countryController.text.trim() : 'Dünya',
        interests: _selectedInterests,
        relationshipGoal: _selectedRelationshipGoal,
        photoUrls: ['https://ui-avatars.com/api/?name=${name[0]}&size=500&background=D4AF37&color=fff'],
        bio: _bioController.text.trim(),
        job: _jobController.text.trim(),
        education: '',
      );

      await userProvider.loadCurrentUser();

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const MainScaffold()),
          (route) => false,
        );
      }
    } catch (e) {
      LogService.e("Minimal profile creation failed", e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Profil tamamlanma yüzdesi hesapla
  int _calculateCompletionPercentage() {
    int completed = 0;
    int total = 7;
    
    if (_nameController.text.trim().isNotEmpty) completed++;
    if (_getBirthDateFromFields() != null) completed++;
    if (_selectedGender != null) completed++;
    if (_countryController.text.trim().isNotEmpty) completed++;
    if (_selectedInterests.isNotEmpty) completed++;
    if (_selectedRelationshipGoal != null) completed++;
    if (_photoBytes.isNotEmpty) completed++;
    
    return ((completed / total) * 100).round();
  }

  Widget _buildProgressIndicator() {
    final percentage = _calculateCompletionPercentage();
    return Container(
      width: 100,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(2),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: percentage / 100,
        child: Container(
          decoration: BoxDecoration(
            color: percentage >= 70 ? AppColors.success : AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        backgroundColor: AppColors.scaffold,
        elevation: 0,
        centerTitle: true,
        leading: TextButton(
          onPressed: _isLoading ? null : () {
            // Daha sonra tamamla - minimum bilgilerle devam et
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                backgroundColor: AppColors.surface,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                title: Text(
                  'Daha Sonra Tamamla?',
                  style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                content: Text(
                  'Profilini daha sonra tamamlayabilirsin. Ancak tamamlanmamış profiller daha az görünürlük alır.',
                  style: GoogleFonts.plusJakartaSans(color: Colors.white70),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text('Kapat', style: GoogleFonts.plusJakartaSans(color: Colors.white54)),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _submitProfileMinimal();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.black,
                    ),
                    child: Text('Devam Et', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );
          },
          child: Text(
            'SONRA',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white54,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        title: Column(
          children: [
            Text(
              'PROFİLİNİ OLUŞTUR',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 2.0,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            // İlerleme göstergesi
            _buildProgressIndicator(),
          ],
        ),
        actions: [
          Container(
             margin: const EdgeInsets.only(right: 12, top: 12, bottom: 12),
             child: TextButton(
               onPressed: _isLoading ? null : _submitProfile,
               style: TextButton.styleFrom(
                 backgroundColor: AppColors.primary.withOpacity(0.1),
                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                 padding: const EdgeInsets.symmetric(horizontal: 16),
               ),
               child: Text(
                 'KAYDET',
                 style: GoogleFonts.plusJakartaSans(
                   color: AppColors.primary,
                   fontWeight: FontWeight.w900,
                   fontSize: 12,
                   letterSpacing: 1.0,
                 ),
               ),
             ),
          ),
        ],
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Photo Header
                    _buildPhotoHeader(),

                    // Basic Info Section
                    _buildSectionHeader('TEMEL BİLGİLER'),
                    _buildModernInput(
                      controller: _nameController,
                      label: 'Ad Soyad',
                      placeholder: 'Arda Yılmaz',
                      validator: (v) => v!.isEmpty ? 'Gerekli' : null,
                    ),
                    _buildModernInput(
                      controller: _jobController,
                      label: 'Meslek',
                      placeholder: 'Finans Direktörü',
                    ),
                    // Birth Date Selection
                    _buildSectionHeader('DOĞUM TARİHİ'),
                    // Birth Date - Simple Text Inputs
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _dayController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(2),
                                  ],
                                  style: GoogleFonts.plusJakartaSans(color: Colors.white),
                                  decoration: InputDecoration(
                                    labelText: 'Gün',
                                    hintText: '01',
                                    filled: true,
                                    fillColor: AppColors.surface,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide.none,
                                    ),
                                    labelStyle: GoogleFonts.plusJakartaSans(color: Colors.white54),
                                    hintStyle: GoogleFonts.plusJakartaSans(color: Colors.white30),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) return 'Gün gerekli';
                                    final day = int.tryParse(value);
                                    if (day == null || day < 1 || day > 31) return 'Geçersiz gün';
                                    return null;
                                  },
                                  onChanged: (_) => setState(() {}),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: _monthController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(2),
                                  ],
                                  style: GoogleFonts.plusJakartaSans(color: Colors.white),
                                  decoration: InputDecoration(
                                    labelText: 'Ay',
                                    hintText: '12',
                                    filled: true,
                                    fillColor: AppColors.surface,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide.none,
                                    ),
                                    labelStyle: GoogleFonts.plusJakartaSans(color: Colors.white54),
                                    hintStyle: GoogleFonts.plusJakartaSans(color: Colors.white30),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) return 'Ay gerekli';
                                    final month = int.tryParse(value);
                                    if (month == null || month < 1 || month > 12) return 'Geçersiz ay';
                                    return null;
                                  },
                                  onChanged: (_) => setState(() {}),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  controller: _yearController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(4),
                                  ],
                                  style: GoogleFonts.plusJakartaSans(color: Colors.white),
                                  decoration: InputDecoration(
                                    labelText: 'Yıl',
                                    hintText: '2000',
                                    filled: true,
                                    fillColor: AppColors.surface,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide.none,
                                    ),
                                    labelStyle: GoogleFonts.plusJakartaSans(color: Colors.white54),
                                    hintStyle: GoogleFonts.plusJakartaSans(color: Colors.white30),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) return 'Yıl gerekli';
                                    final year = int.tryParse(value);
                                    final currentYear = DateTime.now().year;
                                    if (year == null || year < 1924 || year > currentYear) {
                                      return 'Geçersiz yıl';
                                    }
                                    
                                    // 18 yaş kontrolü
                                    final age = _calculateAge();
                                    if (age != null && age < 18) {
                                      return 'En az 18 yaşında olmalısınız';
                                    }
                                    return null;
                                  },
                                  onChanged: (_) => setState(() {}),
                                ),
                              ),
                            ],
                          ),
                          if (_calculateAge() != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                '${_calculateAge()} yaşındasınız',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  color: _calculateAge()! >= 18 
                                      ? AppColors.primary 
                                      : Colors.red,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    // Country Dropdown
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: DropdownButtonFormField<String>(
                        value: _countryController.text.isEmpty ? null : _countryController.text,
                        decoration: InputDecoration(
                          labelText: 'Ülke',
                          filled: true,
                          fillColor: AppColors.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          labelStyle: GoogleFonts.plusJakartaSans(color: Colors.white54),
                        ),
                        dropdownColor: AppColors.surface,
                        style: GoogleFonts.plusJakartaSans(color: Colors.white),
                        items: [
                          'Türkiye 🇹🇷',
                          'Almanya 🇩🇪',
                          'Fransa 🇫🇷',
                          'İngiltere 🇬🇧',
                          'ABD 🇺🇸',
                          'Hollanda 🇳🇱',
                          'Belçika 🇧🇪',
                          'İsveç 🇸🇪',
                          'Norveç 🇳🇴',
                          'Avusturya 🇦🇹',
                          'İsviçre 🇨🇭',
                          'Danimarka 🇩🇰',
                          'Kanada 🇨🇦',
                          'Avustralya 🇦🇺',
                          'Diğer',
                        ].map((country) => DropdownMenuItem(
                          value: country,
                          child: Text(country),
                        )).toList(),
                        onChanged: (value) {
                          setState(() => _countryController.text = value ?? '');
                        },
                      ),
                    ),
                    
                    // Gender Section
                    _buildSectionHeader('CİNSİYET'),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        children: [
                          _buildGenderChip('Erkek', Icons.male),
                          const SizedBox(width: 12),
                          _buildGenderChip('Kadın', Icons.female),
                        ],
                      ),
                    ),

                    // Interests Section
                    _buildSectionHeader('İLGİ ALANLARI'),
                    _buildInterestsGrid(),

                    // Relationship Goal Section
                    _buildSectionHeader('İLİŞKİ HEDEFİ'),
                    _buildRelationshipGoalSelector(),

                    // Bio Section
                    _buildSectionHeader('BİYOGRAFİ'),
                    _buildModernInput(
                      controller: _bioController,
                      label: 'Hakkında',
                      placeholder: 'Kendinden bahset...',
                      maxLines: 4,
                    ),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildPhotoHeader() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          children: [
            GestureDetector(
              onTap: () => _pickImage(0),
              child: Stack(
                children: [
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.1), width: 2),
                      color: AppColors.surface,
                    ),
                    child: _photoBytes.containsKey(0) 
                        ? ClipOval(
                            child: Image.memory(
                              _photoBytes[0]!,
                              fit: BoxFit.cover,
                              width: 140,
                              height: 140,
                            ),
                          )
                        : Icon(Icons.person, size: 64, color: Colors.white.withOpacity(0.1)),
                  ),

                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.scaffold, width: 4),
                      ),
                      child: const Icon(Icons.photo_camera, size: 18, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Fotoğrafı Güncelle",
              style: GoogleFonts.manrope(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
                color: Colors.white.withOpacity(0.4),
              ),
            ),
            
            // Other Photos Grid (Subtle)
            const SizedBox(height: 24),
            SizedBox(
              height: 80,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                scrollDirection: Axis.horizontal,
                itemCount: 5,
                itemBuilder: (context, index) {
                  final realIndex = index + 1;
                  return GestureDetector(

                      onTap: () => _pickImage(realIndex),
                      child: Container(
                        width: 60,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: AppColors.surface,
                          border: Border.all(
                            color: _photoBytes.containsKey(realIndex) ? AppColors.primary : Colors.white10,
                            width: _photoBytes.containsKey(realIndex) ? 1.5 : 1,
                          ),
                        ),
                        child: _photoBytes.containsKey(realIndex)
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(11),
                                child: Image.memory(_photoBytes[realIndex]!, fit: BoxFit.cover, width: 60, height: 80),
                              )
                            : const Icon(Icons.add, color: Colors.white10, size: 20),
                      ),
                    );

                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
      child: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 2.0,
          color: Colors.white.withOpacity(0.3),
        ),
      ),
    );
  }

  Widget _buildModernInput({
    required TextEditingController controller,
    required String label,
    required String placeholder,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(label, style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white.withOpacity(0.8))),
          ),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            validator: validator,
            style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: GoogleFonts.manrope(color: Colors.white.withOpacity(0.1)),
              filled: true,
              fillColor: Colors.white.withOpacity(0.03),
              contentPadding: const EdgeInsets.all(18),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.white.withOpacity(0.05))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.white.withOpacity(0.05))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderChip(String label, IconData icon) {
    final isSelected = _selectedGender == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedGender = label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isSelected ? AppColors.primary : Colors.white.withOpacity(0.05), width: 1.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isSelected ? AppColors.primary : Colors.white.withOpacity(0.3), size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : Colors.white.withOpacity(0.3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInterestsGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Wrap(
        spacing: 8,
        runSpacing: 12,
        children: _interests.map((interest) {
          final isSelected = _selectedInterests.contains(interest['name']);
          return GestureDetector(
            onTap: () {
              setState(() {
                if (isSelected) {
                  _selectedInterests.remove(interest['name']);
                } else {
                  _selectedInterests.add(interest['name']);
                }
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white.withOpacity(0.03),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: isSelected ? AppColors.primary : Colors.white.withOpacity(0.05)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(interest['icon'], size: 16, color: isSelected ? Colors.white : Colors.white.withOpacity(0.3)),
                  const SizedBox(width: 8),
                  Text(
                    interest['name'],
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.white.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRelationshipGoalSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: _relationshipGoals.map((goal) {
          final isSelected = _selectedRelationshipGoal == goal['id'];
          return GestureDetector(
            onTap: () {
              setState(() => _selectedRelationshipGoal = goal['id']);
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          goal['label']!,
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          goal['desc']!,
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white54,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 24),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
