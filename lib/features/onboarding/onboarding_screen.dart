import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_colors.dart';
import '../auth/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
      title: 'Mükemmel Dengini Bul',
      description: 'Zevklerinize ve yaşam tarzınıza en uygun kişilerle tanışın. Sizin için rafine edilmiş bir deneyim.',
      imageUrl: 'https://images.unsplash.com/photo-1529333166437-7750a6dd5a70?w=800&q=80',
    ),
    OnboardingData(
      title: 'Güvenli ve Prestijli',
      description: 'Doğrulanmış profiller ve elit bir topluluk. DENGİM\'de her etkileşim değerlidir.',
      imageUrl: 'https://images.unsplash.com/photo-1543807535-eceef0bc6599?w=800&q=80',
    ),
    OnboardingData(
      title: 'Anı Yakala',
      description: 'Yeni insanlarla tanışmanın en estetik yolu. Şimdi katılın ve ayrıcalıklı hissedin.',
      imageUrl: 'https://images.unsplash.com/photo-1516589091380-5d8e87df6999?w=800&q=80',
    ),
  ];

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstTime', false);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: Stack(
        children: [
          // Background Imagery
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              return Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(_pages[index].imageUrl, fit: BoxFit.cover),
                  _buildGradientOverlay(),
                ],
              );
            },
          ),

          // Content
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 2),
                // Indicators
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_pages.length, (index) => _buildIndicator(index)),
                ),
                const SizedBox(height: 48),
                // Text Area
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    children: [
                      Text(
                        _pages[_currentPage].title,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _pages[_currentPage].description,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.6),
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // Button
                Padding(
                  padding: const EdgeInsets.all(40),
                  child: SizedBox(
                    width: double.infinity,
                    height: 64,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentPage < _pages.length - 1) {
                          _pageController.nextPage(duration: const Duration(milliseconds: 600), curve: Curves.easeInOutCubic);
                        } else {
                          _completeOnboarding();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                        elevation: 0,
                      ),
                      child: Text(
                        _currentPage == _pages.length - 1 ? 'BAŞLA' : 'İLERLE',
                        style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, letterSpacing: 1),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradientOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            AppColors.scaffold.withOpacity(0.4),
            AppColors.scaffold,
          ],
          stops: const [0.0, 0.4, 0.8],
        ),
      ),
    );
  }

  Widget _buildIndicator(int index) {
    final active = _currentPage == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 4,
      width: active ? 24 : 8,
      decoration: BoxDecoration(
        color: active ? Colors.white : Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class OnboardingData {
  final String title;
  final String description;
  final String imageUrl;

  OnboardingData({required this.title, required this.description, required this.imageUrl});
}
