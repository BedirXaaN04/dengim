import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

/// Filtre ayarları için model
class FilterSettings {
  RangeValues ageRange;
  String gender; // 'male', 'female', 'other'
  double distance; // in km
  String location;

  FilterSettings({
    this.ageRange = const RangeValues(24, 38),
    this.gender = 'female',
    this.distance = 45,
    this.location = 'İstanbul, Türkiye',
  });

  FilterSettings copyWith({
    RangeValues? ageRange,
    String? gender,
    double? distance,
    String? location,
  }) {
    return FilterSettings(
      ageRange: ageRange ?? this.ageRange,
      gender: gender ?? this.gender,
      distance: distance ?? this.distance,
      location: location ?? this.location,
    );
  }
}

class FilterBottomSheet extends StatefulWidget {
  final FilterSettings initialSettings;
  final Function(FilterSettings) onApply;

  const FilterBottomSheet({
    super.key,
    required this.initialSettings,
    required this.onApply,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late FilterSettings _settings;

  @override
  void initState() {
    super.initState();
    _settings = FilterSettings(
      ageRange: widget.initialSettings.ageRange,
      gender: widget.initialSettings.gender,
      distance: widget.initialSettings.distance,
      location: widget.initialSettings.location,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: AppColors.scaffold,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Stack(
        children: [
          Column(
            children: [
              // TopAppBar
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.close, color: Colors.white, size: 28),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          'Filtreler',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _settings = FilterSettings();
                        });
                      },
                      child: Text(
                        'Sıfırla',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      // Section: Gender Selection
                      Text(
                        'Kimi Görmek İstersin?',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _buildGenderChip('Erkek', 'male'),
                          const SizedBox(width: 12),
                          _buildGenderChip('Kadın', 'female'),
                          const SizedBox(width: 12),
                          _buildGenderChip('Diğer', 'other'),
                        ],
                      ),

                      const SizedBox(height: 40),
                      // Section: Age Range
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Yaş Aralığı',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '${_settings.ageRange.start.toInt()} - ${_settings.ageRange.end.toInt()}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppColors.secondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildRangeSlider(),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('18', style: _labelStyle()),
                          Text('99', style: _labelStyle()),
                        ],
                      ),

                      const SizedBox(height: 48),
                      // Section: Distance
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Mesafe',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '${_settings.distance.toInt()} km',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppColors.secondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildDistanceSlider(),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('1 KM', style: _labelStyle()),
                          Text('100 KM+', style: _labelStyle()),
                        ],
                      ),

                      const SizedBox(height: 48),
                      // Section: Location
                      Text(
                        'Konum',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildLocationPicker(),
                      const SizedBox(height: 100), // Padding for button
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Footer Apply Button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    AppColors.scaffold,
                    AppColors.scaffold.withOpacity(0.95),
                    Colors.transparent,
                  ],
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 64,
                child: ElevatedButton(
                  onPressed: () {
                    widget.onApply(_settings);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary, // Gold in the mock
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 10,
                    shadowColor: AppColors.secondary.withOpacity(0.2),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Filtreleri Uygula',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.check_circle_outline, weight: 700),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderChip(String label, String value) {
    final isSelected = _settings.gender == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _settings.gender = value),
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary.withOpacity(0.2) : Colors.white.withAlpha(20),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? AppColors.primary : Colors.white60,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRangeSlider() {
    return SliderTheme(
      data: SliderThemeData(
        activeTrackColor: AppColors.primary,
        inactiveTrackColor: Colors.white.withAlpha(20),
        thumbColor: Colors.white,
        overlayColor: AppColors.primary.withOpacity(0.2),
        trackHeight: 8,
        rangeThumbShape: const RoundRangeSliderThumbShape(
          enabledThumbRadius: 12,
          elevation: 4,
        ),
      ),
      child: RangeSlider(
        values: _settings.ageRange,
        min: 18,
        max: 99,
        onChanged: (val) => setState(() => _settings.ageRange = val),
      ),
    );
  }

  Widget _buildDistanceSlider() {
    return SliderTheme(
      data: SliderThemeData(
        activeTrackColor: AppColors.primary,
        inactiveTrackColor: Colors.white.withAlpha(20),
        thumbColor: Colors.white,
        overlayColor: AppColors.primary.withOpacity(0.2),
        trackHeight: 8,
        thumbShape: const RoundSliderThumbShape(
          enabledThumbRadius: 12,
          elevation: 4,
        ),
      ),
      child: Slider(
        value: _settings.distance,
        min: 1,
        max: 100,
        onChanged: (val) => setState(() => _settings.distance = val),
      ),
    );
  }

  Widget _buildLocationPicker() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withAlpha(15)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.location_on, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _settings.location,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Text(
                  'Şu anki konumum',
                  style: TextStyle(color: Colors.white38, fontSize: 12),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.white24),
        ],
      ),
    );
  }

  TextStyle _labelStyle() => GoogleFonts.plusJakartaSans(
    fontSize: 12,
    fontWeight: FontWeight.bold,
    color: Colors.white30,
    letterSpacing: 1.2,
  );
}

void showFilterBottomSheet(
  BuildContext context, {
  required FilterSettings currentSettings,
  required Function(FilterSettings) onApply,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => FilterBottomSheet(
      initialSettings: currentSettings,
      onApply: onApply,
    ),
  );
}
