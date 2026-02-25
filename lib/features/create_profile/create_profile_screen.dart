import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import 'package:dengim/features/main/main_scaffold.dart'; 
import '../auth/services/profile_service.dart';
import '../../core/providers/user_provider.dart';
import '../../core/utils/log_service.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
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
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 5;
  
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
    _pageController.dispose();
    super.dispose();
  }

  // ... (State logic kept from previous version)
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

  DateTime? _getBirthDateFromFields() {
    final day = int.tryParse(_dayController.text);
    final month = int.tryParse(_monthController.text);
    final year = int.tryParse(_yearController.text);
    if (day == null || month == null || year == null) return null;
    if (day < 1 || day > 31 || month < 1 || month > 12) return null;
    if (year < 1924 || year > DateTime.now().year) return null;
    try { return DateTime(year, month, day); } catch (e) { return null; }
  }

  int? _calculateAge() {
    final birthDate = _getBirthDateFromFields();
    if (birthDate == null) return null;
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month || (now.month == birthDate.month && now.day < birthDate.day)) age--;
    return age;
  }

  String? _selectedGender;
  String? _selectedRelationshipGoal;
  final List<String> _selectedInterests = [];
  final List<XFile?> _profilePhotos = [null, null, null, null, null, null]; 
  final Map<int, Uint8List> _photoBytes = {}; 

  final List<Map<String, String>> _relationshipGoals = [
    {'id': 'serious', 'label': 'Ciddi İlişki 💍', 'desc': 'Uzun vadeli partner'},
    {'id': 'casual', 'label': 'Eğlence 🥂', 'desc': 'Kısa vadeli takılmaca'},
    {'id': 'chat', 'label': 'Sohbet ☕', 'desc': 'Yeni arkadaşlar'},
    {'id': 'unsure', 'label': 'Belirsiz 🤷‍♂️', 'desc': 'Henüz karar vermedim'},
  ];
  
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
      _showPage(0);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lütfen isminizi giriniz')));
      return;
    }
    if (_getBirthDateFromFields() == null) {
      _showPage(0);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lütfen doğum tarihinizi giriniz')));
      return;
    }

    setState(() => _isLoading = true);
    HapticFeedback.mediumImpact();

    try {
      final userProvider = context.read<UserProvider>();
      List<String> photoUrls = [];
      final List<Future<String>> uploadFutures = [];
      final uid = Provider.of<UserProvider>(context, listen: false).currentUser?.uid ?? 'anon';
      
      for (int i = 0; i < _profilePhotos.length; i++) {
        if (_photoBytes.containsKey(i)) {
          uploadFutures.add(_profileService.uploadProfilePhotoBytes(_photoBytes[i]!, uid));
        }
      }
      if (uploadFutures.isNotEmpty) {
        photoUrls = await Future.wait(uploadFutures).timeout(const Duration(seconds: 30));
      }

      await _profileService.createProfile(
        name: _nameController.text.trim(),
        birthDate: _getBirthDateFromFields(),
        gender: _selectedGender ?? 'Diğer',
        country: _countryController.text.trim(),
        interests: _selectedInterests,
        relationshipGoal: _selectedRelationshipGoal,
        photoUrls: photoUrls.isNotEmpty ? photoUrls : ['https://api.dicebear.com/7.x/initials/png?seed=${_nameController.text.isNotEmpty ? _nameController.text[0] : "D"}'],
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
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profil oluşturulamadı: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _submitProfileMinimal() async {
    setState(() => _isLoading = true);
    try {
      final userProvider = context.read<UserProvider>();
      final name = _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : 'Kullanıcı';
      await _profileService.createProfile(
        name: name,
        birthDate: _getBirthDateFromFields() ?? DateTime(2000, 1, 1),
        gender: _selectedGender ?? 'Belirtilmemiş',
        country: _countryController.text.trim().isNotEmpty ? _countryController.text.trim() : 'Dünya',
        interests: _selectedInterests,
        relationshipGoal: _selectedRelationshipGoal,
        photoUrls: ['https://api.dicebear.com/7.x/initials/png?seed=${name[0]}'],
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
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    } else {
      _submitProfile();
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    }
  }

  void _showPage(int index) {
    _pageController.animateToPage(index, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        toolbarHeight: 80,
        shape: const Border(bottom: BorderSide(color: Colors.black, width: 4)),
        leading: _currentPage > 0 
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
              onPressed: _prevPage,
            )
          : TextButton(
              onPressed: _isLoading ? null : () => _showSkipDialog(),
              child: Text('SONRA', style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w900)),
            ),
        title: Column(
          children: [
            Text(
              'PROFİLİNİ OLUŞTUR',
              style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: -0.5, color: Colors.black),
            ),
            const SizedBox(height: 8),
            _buildStepProgress(),
          ],
        ),
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : Column(
              children: [
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (page) => setState(() => _currentPage = page),
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildPage0(), // Identity
                      _buildPage1(), // Bio/Job
                      _buildPage2(), // Photos
                      _buildPage3(), // Identity/Goals
                      _buildPage4(), // Interests
                    ],
                  ),
                ),
                _buildBottomNavigation(),
              ],
            ),
    );
  }

  Widget _buildStepProgress() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(_totalPages, (index) {
        final isActive = index <= _currentPage;
        return Container(
          width: 24,
          height: 6,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : Colors.black.withOpacity(0.05),
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: Colors.black, width: 1),
          ),
        );
      }),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.black, width: 4)),
      ),
      child: Row(
        children: [
          if (_currentPage > 0)
            Expanded(
              child: GestureDetector(
                onTap: _prevPage,
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.black, width: 3),
                  ),
                  child: Center(
                    child: Text('GERİ', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, color: Colors.black)),
                  ),
                ),
              ),
            ),
          if (_currentPage > 0) const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: _nextPage,
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.black, width: 3),
                  boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(4, 4))],
                ),
                child: Center(
                  child: Text(
                    _currentPage == _totalPages - 1 ? 'TAMAMLA' : 'İLERLE',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.w900, color: Colors.black),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Page Builders ---

  Widget _buildPage0() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           _buildStepTitle('KİMLİK', 'Seni tanımakla başlayalım.'),
           _buildModernInput(
             controller: _nameController,
             label: 'AD SOYAD',
             placeholder: 'ARDA YILMAZ',
             validator: (v) => v!.isEmpty ? 'Gerekli' : null,
           ),
           const SizedBox(height: 24),
           _buildSectionHeader('DOĞUM TARİHİ'),
           _buildBirthDateInputs(),
           const SizedBox(height: 24),
           _buildSectionHeader('ÜLKE'),
           _buildCountryDropdown(),
        ],
      ),
    );
  }

  Widget _buildPage1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           _buildStepTitle('MODUNU BELİRLE', 'Kendinden kısaca bahset.'),
           _buildModernInput(
             controller: _jobController,
             label: 'MESLEK',
             placeholder: 'FİNANS DİREKTÖRÜ',
           ),
           _buildModernInput(
             controller: _bioController,
             label: 'HAKKINDA',
             placeholder: 'KENDİNDEN BAHSET...',
             maxLines: 5,
           ),
        ],
      ),
    );
  }

  Widget _buildPage2() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              children: [
                _buildStepTitle('FOTOĞRAFLAR', 'En güzel karelerini yükle.'),
                _buildPhotoHeader(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPage3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           _buildStepTitle('NİYETİN NEDİR?', 'Cinsiyetin ve ne aradığın önemli.'),
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
           const SizedBox(height: 32),
           _buildSectionHeader('İLİŞKİ HEDEFİ'),
           _buildRelationshipGoalSelector(),
        ],
      ),
    );
  }

  Widget _buildPage4() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           _buildStepTitle('İLGİ ALANLARI', 'Sana uygun kişileri bulalım.'),
           _buildInterestsGrid(),
           const SizedBox(height: 40),
           Padding(
             padding: const EdgeInsets.symmetric(horizontal: 40),
             child: Text(
               'HARİKA! HER ŞEY HAZIR GÖRÜNÜYOR. TAMAMLA BUTONUNA BASARAK ARAMIZA KATILABİLİRSİN.',
               textAlign: TextAlign.center,
               style: GoogleFonts.outfit(color: AppColors.textSecondary, fontWeight: FontWeight.w700, fontSize: 13),
             ),
           ),
        ],
      ),
    );
  }

  Widget _buildStepTitle(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.black, letterSpacing: -1)),
          const SizedBox(height: 8),
          Text(subtitle.toUpperCase(), style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textSecondary)),
          const SizedBox(height: 16),
          Container(width: 60, height: 6, decoration: BoxDecoration(color: AppColors.primary, border: Border.all(color: Colors.black, width: 2))),
        ],
      ),
    );
  }

  // --- Helper Widgets (Borrowed from existing or slightly tweaked) ---

  void _showSkipDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: const BorderSide(color: Colors.black, width: 4)),
        title: Text('SONRA TAMAMLA?', style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.w900)),
        content: Text('PROFİLİNİ DAHA SONRA TAMAMLAYABİLİRSİN. ANCAK TAMAMLANMAMIŞ PROFİLLER DAHA AZ GÖRÜNÜRLÜK ALIR.', style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.w700)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('KAPAT', style: GoogleFonts.outfit(color: AppColors.textSecondary, fontWeight: FontWeight.w900))),
          ElevatedButton(
            onPressed: () { Navigator.pop(ctx); _submitProfileMinimal(); },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Colors.black, width: 2.5)), elevation: 0),
            child: Text('DEVAM ET', style: GoogleFonts.outfit(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      child: Text(title, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1.0, color: Colors.black)),
    );
  }

  Widget _buildModernInput({required TextEditingController controller, required String label, required String placeholder, int maxLines = 1, String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(padding: const EdgeInsets.only(left: 4, bottom: 8), child: Text(label, style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.black))),
          TextFormField(
            controller: controller,
            maxLines: maxLines,
            validator: validator,
            style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black),
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: GoogleFonts.outfit(color: Colors.black.withOpacity(0.2)),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.all(20),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.black, width: 3)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.black, width: 3)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.primary, width: 4)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBirthDateInputs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          _buildDatePartInput(_dayController, 'GÜN', '01', 2),
          const SizedBox(width: 12),
          _buildDatePartInput(_monthController, 'AY', '01', 2),
          const SizedBox(width: 12),
          _buildDatePartInput(_yearController, 'YIL', '2000', 4, flex: 2),
        ],
      ),
    );
  }

  Widget _buildDatePartInput(TextEditingController controller, String label, String hint, int length, {int flex = 1}) {
    return Expanded(flex: flex, child: TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(length)],
      style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.w800),
      decoration: InputDecoration(
        labelText: label, hintText: hint, filled: true, fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.black, width: 2.5)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.black, width: 2.5)),
        labelStyle: GoogleFonts.outfit(color: Colors.black.withOpacity(0.5), fontWeight: FontWeight.w900, fontSize: 11),
      ),
      onChanged: (_) => setState(() {}),
    ));
  }

  Widget _buildCountryDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: DropdownButtonFormField<String>(
        value: _countryController.text.isEmpty ? null : _countryController.text,
        style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.w800),
        decoration: InputDecoration(
          filled: true, fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.black, width: 2.5)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.black, width: 2.5)),
        ),
        dropdownColor: Colors.white,
        items: ['Türkiye 🇹🇷', 'Almanya 🇩🇪', 'Fransa 🇫🇷', 'İngiltere 🇬🇧', 'ABD 🇺🇸', 'Hollanda 🇳🇱', 'Diğer'].map((c) => DropdownMenuItem(value: c, child: Text(c.toUpperCase()))).toList(),
        onChanged: (v) => setState(() => _countryController.text = v ?? ''),
      ),
    );
  }

  Widget _buildPhotoHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => _pickImage(0),
            child: Stack(
              children: [
                Container(
                  width: 180, height: 180,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white, border: Border.all(color: Colors.black, width: 5), boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(8, 8))]),
                  child: _photoBytes.containsKey(0) ? ClipOval(child: Image.memory(_photoBytes[0]!, fit: BoxFit.cover)) : const Icon(Icons.person, size: 90, color: Colors.black12),
                ),
                Positioned(bottom: 12, right: 12, child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle, border: Border.all(color: Colors.black, width: 3)), child: const Icon(Icons.photo_camera_rounded, size: 24, color: Colors.black))),
              ],
            ),
          ),
          const SizedBox(height: 48),
          SizedBox(
            height: 110,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24), scrollDirection: Axis.horizontal, itemCount: 5,
              itemBuilder: (context, index) {
                final realIndex = index + 1;
                return GestureDetector(
                  onTap: () => _pickImage(realIndex),
                  child: Container(
                    width: 90, margin: const EdgeInsets.only(right: 16),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: Colors.white, border: Border.all(color: _photoBytes.containsKey(realIndex) ? AppColors.primary : Colors.black, width: 3), boxShadow: _photoBytes.containsKey(realIndex) ? null : const [BoxShadow(color: Colors.black, offset: Offset(3, 3))]),
                    child: _photoBytes.containsKey(realIndex) ? ClipRRect(borderRadius: BorderRadius.circular(17), child: Image.memory(_photoBytes[realIndex]!, fit: BoxFit.cover)) : const Icon(Icons.add_rounded, color: Colors.black26, size: 40),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderChip(String label, IconData icon) {
    final isSelected = _selectedGender == label;
    return Expanded(child: GestureDetector(
      onTap: () => setState(() => _selectedGender = label),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(color: isSelected ? AppColors.primary : Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.black, width: 3), boxShadow: [BoxShadow(color: Colors.black, offset: isSelected ? const Offset(2, 2) : const Offset(6, 6))]),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, color: Colors.black, size: 28), const SizedBox(width: 12), Text(label.toUpperCase(), style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 18))]),
      ),
    ));
  }

  Widget _buildInterestsGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Wrap(
        spacing: 12, runSpacing: 12,
        children: _interests.map((interest) {
          final isSelected = _selectedInterests.contains(interest['name']);
          return GestureDetector(
            onTap: () {
              setState(() {
                if (isSelected) { _selectedInterests.remove(interest['name']); }
                else if (_selectedInterests.length < 5) { _selectedInterests.add(interest['name']); }
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(color: isSelected ? AppColors.blue : Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.black, width: 3), boxShadow: [BoxShadow(color: Colors.black, offset: isSelected ? const Offset(2, 2) : const Offset(4, 4))]),
              child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(interest['icon'] as IconData, size: 20, color: Colors.black), const SizedBox(width: 10), Text((interest['name'] as String).toUpperCase(), style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 14))]),
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
            onTap: () => setState(() => _selectedRelationshipGoal = goal['id']),
            child: Container(
              margin: const EdgeInsets.only(bottom: 16), padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: isSelected ? AppColors.secondary : Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.black, width: 3.5), boxShadow: [BoxShadow(color: Colors.black, offset: isSelected ? const Offset(2, 2) : const Offset(5, 5))]),
              child: Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(goal['label']!.toUpperCase(), style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 18)), Text(goal['desc']!.toUpperCase(), style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.black54))])), if (isSelected) const Icon(Icons.check_circle_rounded, color: Colors.black, size: 28)]),
            ),
          );
        }).toList(),
      ),
    );
  }
}
