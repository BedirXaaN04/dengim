import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

/// Advanced Discovery Filters Modal
class AdvancedFiltersModal extends StatefulWidget {
  final Map<String, dynamic> currentFilters;
  final Function(Map<String, dynamic>) onApplyFilters;

  const AdvancedFiltersModal({
    super.key,
    required this.currentFilters,
    required this.onApplyFilters,
    this.isPremium = false,
  });

  final bool isPremium;

  @override
  State<AdvancedFiltersModal> createState() => _AdvancedFiltersModalState();
}

class _AdvancedFiltersModalState extends State<AdvancedFiltersModal> {
  late RangeValues _ageRange;
  late double _distance;
  late String _gender;
  late List<String> _selectedInterests;
  late String? _relationshipGoal;
  late bool _verifiedOnly;
  late bool _hasPhotoOnly;
  late bool _onlineOnly;

  final List<String> _allInterests = [
    'Spor',
    'Müzik',
    'Sanat',
    'Film',
    'Okuma',
    'Seyahat',
    'Yeme-İçme',
    'Fotoğrafçılık',
    'Dans',
    'Yoga',
    'Oyun',
    'Fitness',
    'Moda',
    'Doğa',
    'Teknoloji',
    'Girişimcilik',
    'Tarih',
    'Müze',
    'Konser',
    'Tiyatro',
  ];

  final List<Map<String, String>> _relationshipGoals = [
    {'id': 'all', 'label': 'Tümü', 'emoji': '🌍'},
    {'id': 'serious', 'label': 'Ciddi İlişki', 'emoji': '💍'},
    {'id': 'casual', 'label': 'Eğlence', 'emoji': '🥂'},
    {'id': 'chat', 'label': 'Sohbet', 'emoji': '☕'},
    {'id': 'unsure', 'label': 'Belirsiz', 'emoji': '🤷'},
  ];

  @override
  void initState() {
    super.initState();
    _ageRange = RangeValues(
      (widget.currentFilters['minAge'] ?? 18).toDouble(),
      (widget.currentFilters['maxAge'] ?? 50).toDouble(),
    );
    _distance = (widget.currentFilters['maxDistance'] ?? 50).toDouble();
    _gender = widget.currentFilters['gender'] ?? 'all';
    _selectedInterests =
        List<String>.from(widget.currentFilters['interests'] ?? []);
    _relationshipGoal = widget.currentFilters['relationshipGoal'];
    _verifiedOnly = widget.currentFilters['verifiedOnly'] ?? false;
    _hasPhotoOnly = widget.currentFilters['hasPhotoOnly'] ?? true;
    _onlineOnly = widget.currentFilters['onlineOnly'] ?? false;
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'GELİŞMİŞ FİLTRELER',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                TextButton(
                  onPressed: _resetFilters,
                  child: Text(
                    'Sıfırla',
                    style: GoogleFonts.plusJakartaSans(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(color: Colors.white10, height: 1),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Age Range
                  _buildSectionHeader('YAŞ ARALIĞI'),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildAgeChip(_ageRange.start.round().toString()),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Container(
                            height: 2,
                            color: AppColors.primary.withOpacity(0.3),
                          ),
                        ),
                      ),
                      _buildAgeChip(_ageRange.end.round().toString()),
                    ],
                  ),
                  RangeSlider(
                    values: _ageRange,
                    min: 18,
                    max: 80,
                    divisions: 62,
                    activeColor: AppColors.primary,
                    inactiveColor: Colors.white10,
                    onChanged: (RangeValues values) {
                      setState(() => _ageRange = values);
                    },
                  ),

                  const SizedBox(height: 32),

                  // Distance
                  _buildSectionHeader('MESAFE'),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_distance.round()} km',
                        style: GoogleFonts.plusJakartaSans(
                          color: AppColors.primary,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Maksimum uzaklık',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _distance,
                    min: 1,
                    max: 500,
                    divisions: 99,
                    activeColor: AppColors.primary,
                    inactiveColor: Colors.white10,
                    onChanged: (value) {
                      setState(() => _distance = value);
                    },
                  ),

                  const SizedBox(height: 32),

                  // Gender
                  _buildSectionHeader('CİNSİYET'),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildGenderChip('all', 'Tümü', Icons.people),
                      const SizedBox(width: 12),
                      _buildGenderChip('male', 'Erkek', Icons.male),
                      const SizedBox(width: 12),
                      _buildGenderChip('female', 'Kadın', Icons.female),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Relationship Goal
                  _buildSectionHeader('İLİŞKİ HEDEFİ'),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _relationshipGoals.map((goal) {
                      final isSelected = _relationshipGoal == goal['id'];
                      return GestureDetector(
                        onTap: () {
                          if (!widget.isPremium) {
                             Navigator.push(context, MaterialPageRoute(builder: (_) => const PremiumOfferScreen()));
                             return;
                          }
                          setState(() {
                            _relationshipGoal =
                                isSelected ? null : goal['id'];
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary.withOpacity(0.2)
                                : Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : Colors.white10,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                goal['emoji']!,
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                goal['label']!,
                                style: GoogleFonts.plusJakartaSans(
                                  color: isSelected
                                      ? AppColors.primary
                                      : Colors.white70,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  fontSize: 13,
                                ),
                              ),
                              if (!widget.isPremium && goal['id'] != 'all') ...[
                                const SizedBox(width: 4),
                                const Icon(Icons.lock_outline_rounded, color: AppColors.primary, size: 12),
                              ],
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 32),

                  // Interests
                  _buildSectionHeader(
                      'İLGİ ALANLARI (${_selectedInterests.length})'),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _allInterests.map((interest) {
                      final isSelected = _selectedInterests.contains(interest);
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              _selectedInterests.remove(interest);
                            } else {
                              _selectedInterests.add(interest);
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary.withOpacity(0.2)
                                : Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : Colors.white10,
                            ),
                          ),
                          child: Text(
                            interest,
                            style: GoogleFonts.plusJakartaSans(
                              color: isSelected
                                  ? AppColors.primary
                                  : Colors.white70,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 32),

                  // Quick Filters
                  _buildSectionHeader('HIZLI FİLTRELER'),
                  const SizedBox(height: 16),
                  _buildToggleOption(
                    'Sadece Doğrulanmış Profiller',
                    Icons.verified,
                    _verifiedOnly,
                    (value) => setState(() => _verifiedOnly = value),
                  ),
                  const SizedBox(height: 12),
                  _buildToggleOption(
                    'Fotoğrafı Olanlar',
                    Icons.photo_camera,
                    _hasPhotoOnly,
                    (value) => setState(() => _hasPhotoOnly = value),
                  ),
                  const SizedBox(height: 12),
                  _buildToggleOption(
                    'Sadece Çevrimiçi',
                    Icons.circle,
                    _onlineOnly,
                    (value) => setState(() => _onlineOnly = value),
                    isPremiumOnly: true,
                  ),

                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),

          // Apply Button
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
                  onPressed: _applyFilters,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'FİLTRELERİ UYGULA',
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

  Widget _buildAgeChip(String age) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary),
      ),
      child: Text(
        age,
        style: GoogleFonts.plusJakartaSans(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildGenderChip(String value, String label, IconData icon) {
    final isSelected = _gender == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _gender = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withOpacity(0.2)
                : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.white10,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.primary : Colors.white54,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  color: isSelected ? AppColors.primary : Colors.white70,
                  fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleOption(
    String label,
    IconData icon,
    bool value,
    Function(bool) onChanged, {
    bool isPremiumOnly = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Icon(icon, color: value ? AppColors.primary : Colors.white54, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              children: [
                Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                if (isPremiumOnly && !widget.isPremium) ...[
                  const SizedBox(width: 8),
                  const Icon(Icons.lock_outline_rounded, color: AppColors.primary, size: 14),
                ],
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: (val) {
              if (isPremiumOnly && !widget.isPremium) {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const PremiumOfferScreen()));
                return;
              }
              onChanged(val);
            },
            activeColor: AppColors.primary,
            activeTrackColor: AppColors.primary.withOpacity(0.5),
          ),
        ],
      ),
    );
  }

  void _resetFilters() {
    setState(() {
      _ageRange = const RangeValues(18, 50);
      _distance = 50;
      _gender = 'all';
      _selectedInterests = [];
      _relationshipGoal = null;
      _verifiedOnly = false;
      _hasPhotoOnly = true;
      _onlineOnly = false;
    });
  }

  void _applyFilters() {
    final filters = {
      'minAge': _ageRange.start.round(),
      'maxAge': _ageRange.end.round(),
      'maxDistance': _distance.round(),
      'gender': _gender,
      'interests': _selectedInterests,
      'relationshipGoal': _relationshipGoal,
      'verifiedOnly': _verifiedOnly,
      'hasPhotoOnly': _hasPhotoOnly,
      'onlineOnly': _onlineOnly,
    };

    widget.onApplyFilters(filters);
    Navigator.pop(context);
  }
}
