import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../payment/premium_offer_screen.dart';

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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: Color(0xFFEEEEEE), width: 1.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.symmetric(vertical: 16),
            width: 60,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(3),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'FİLTRELER',
                  style: GoogleFonts.outfit(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                    letterSpacing: -1,
                  ),
                ),
                GestureDetector(
                  onTap: _resetFilters,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      border: Border.all(color: Color(0xFFEEEEEE), width: 1.0),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [AppColors.neoShadowSmall],
                    ),
                    child: Text(
                      'SIFIRLA',
                      style: GoogleFonts.outfit(
                        color: Colors.black,
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(color: Colors.black, height: 1, thickness: AppColors.neoBorderWidthSmallPixels),

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
                      _buildAgeChip(_ageRange.end.round().toString()),
                    ],
                  ),
                  SliderTheme(
                    data: SliderThemeData(
                      thumbColor: Colors.black,
                      activeTrackColor: AppColors.primary,
                      inactiveTrackColor: Colors.grey.shade300,
                      trackHeight: 8,
                    ),
                    child: RangeSlider(
                      values: _ageRange,
                      min: 18,
                      max: 80,
                      divisions: 62,
                      onChanged: (RangeValues values) {
                        setState(() => _ageRange = values);
                      },
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Distance
                  _buildSectionHeader('MESAFE'),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_distance.round()} KM',
                        style: GoogleFonts.outfit(
                          color: Colors.black,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  SliderTheme(
                    data: SliderThemeData(
                      thumbColor: Colors.black,
                      activeTrackColor: AppColors.primary,
                      inactiveTrackColor: Colors.grey.shade300,
                      trackHeight: 8,
                    ),
                    child: Slider(
                      value: _distance,
                      min: 1,
                      max: 500,
                      divisions: 99,
                      onChanged: (value) {
                        setState(() => _distance = value);
                      },
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Gender
                  _buildSectionHeader('CİNSİYET'),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildGenderChip('all', 'TÜMÜ', Icons.people),
                      const SizedBox(width: 12),
                      _buildGenderChip('male', 'ERKEK', Icons.male),
                      const SizedBox(width: 12),
                      _buildGenderChip('female', 'KADIN', Icons.female),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Relationship Goal
                  _buildSectionHeader('İLİŞKİ HEDEFİ'),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
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
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Color(0xFFEEEEEE), width: 1.0),
                            boxShadow: [
                              if (isSelected) AppColors.neoShadowSmall,
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                goal['emoji']!,
                                style: const TextStyle(fontSize: 18),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                goal['label']!.toUpperCase(),
                                style: GoogleFonts.outfit(
                                  color: isSelected ? Colors.white : Colors.black,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14,
                                ),
                              ),
                              if (!widget.isPremium && goal['id'] != 'all') ...[
                                const SizedBox(width: 6),
                                const Icon(Icons.lock_rounded, color: Colors.black, size: 14),
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
                    spacing: 10,
                    runSpacing: 10,
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
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.blue : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Color(0xFFEEEEEE), width: 1.0),
                            boxShadow: [
                              if (isSelected) AppColors.neoShadowSmall,
                            ],
                          ),
                          child: Text(
                            interest.toUpperCase(),
                            style: GoogleFonts.outfit(
                              color: isSelected ? Colors.white : Colors.black,
                              fontWeight: FontWeight.w900,
                              fontSize: 13,
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
                    'SADECE DOĞRULANMIŞ',
                    Icons.verified_rounded,
                    _verifiedOnly,
                    (value) => setState(() => _verifiedOnly = value),
                  ),
                  const SizedBox(height: 16),
                  _buildToggleOption(
                    'FOTOĞRAFI OLANLAR',
                    Icons.photo_camera_rounded,
                    _hasPhotoOnly,
                    (value) => setState(() => _hasPhotoOnly = value),
                  ),
                  const SizedBox(height: 16),
                  _buildToggleOption(
                    'SADECE ÇEVRİMİÇİ',
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
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFEEEEEE), width: 1.0)),
            ),
            child: SafeArea(
              child: GestureDetector(
                onTap: _applyFilters,
                child: Container(
                  width: double.infinity,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Color(0xFFEEEEEE), width: 1.0),
                    boxShadow: [AppColors.neoShadowSmall],
                  ),
                  child: Center(
                    child: Text(
                      'FİLTRELERİ UYGULA',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                        letterSpacing: 1,
                        color: Colors.white,
                      ),
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
      style: GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.w900,
        color: Colors.black,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildAgeChip(String age) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color(0xFFEEEEEE), width: 1.0),
        boxShadow: [AppColors.neoShadowSmall],
      ),
      child: Text(
        age,
        style: GoogleFonts.outfit(
          color: Colors.black,
          fontWeight: FontWeight.w900,
          fontSize: 20,
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
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Color(0xFFEEEEEE), width: 1.0),
            boxShadow: [
              if (isSelected) AppColors.neoShadowSmall,
            ],
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: Colors.black,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: GoogleFonts.outfit(
                  color: isSelected ? Colors.white : Colors.black,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color(0xFFEEEEEE), width: 1.0),
        boxShadow: [AppColors.neoShadowSmall],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.black, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Row(
              children: [
                Text(
                  label,
                  style: GoogleFonts.outfit(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (isPremiumOnly && !widget.isPremium) ...[
                  const SizedBox(width: 8),
                  const Icon(Icons.lock_rounded, color: Colors.black, size: 18),
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
            activeThumbColor: Colors.black,
            activeTrackColor: AppColors.primary,
            inactiveThumbColor: Colors.grey.shade600,
            inactiveTrackColor: Colors.grey.shade300,
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
