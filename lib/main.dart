import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'features/main/main_scaffold.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'core/theme/app_colors.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'features/auth/login_screen.dart';
import 'core/utils/error_handler.dart';
import 'features/create_profile/create_profile_screen.dart';
import 'core/widgets/responsive_center_wrapper.dart'; // Web Wrapper
import 'core/widgets/network_wrapper.dart'; // Network Wrapper
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'core/providers/user_provider.dart';
import 'core/providers/discovery_provider.dart';
import 'core/providers/chat_provider.dart';
import 'core/providers/connectivity_provider.dart';
import 'core/providers/badge_provider.dart';
import 'core/providers/likes_provider.dart';
import 'core/providers/map_provider.dart';
import 'core/providers/story_provider.dart';
import 'core/providers/system_config_provider.dart';
import 'core/providers/subscription_provider.dart';
import 'core/providers/credit_provider.dart';
import 'core/utils/log_service.dart';

import 'features/auth/services/profile_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/config_service.dart';
import 'core/services/feature_flag_service.dart';
import 'features/ads/services/ad_service.dart';

import 'features/spaces/providers/space_provider.dart';
import 'core/widgets/maintenance_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Global error handling
  ErrorHandler.initialize();
  
  if (!kIsWeb) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  try {
    LogService.i("Firebase initializing...");
    await Firebase.initializeApp(
      options: kIsWeb 
        ? const FirebaseOptions(
            apiKey: "AIzaSyCQRAqILl3fdNCwEvGAJeIzQ-XSfiyeVp8",
            authDomain: "dengim-kim.firebaseapp.com",
            projectId: "dengim-kim",
            storageBucket: "dengim-kim.firebasestorage.app",
            messagingSenderId: "12239103870",
            appId: "1:12239103870:web:b0dd97ac27cda36a21f52f",
            measurementId: "G-7TK4QPEWFN"
          )
        : null,
    );
    LogService.i("Firebase initialized successfully.");

    // Remote Configuration'ı başlat
    await ConfigService().init();
    await FeatureFlagService().init();
    await AdService().init();

    // Bildirim servisini başlat
    try {
      await NotificationService().initialize();
    } catch (e) {
      LogService.w("Notification init warning: $e");
    }
    
    if (kIsWeb) {
      FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: false);
    }
  } catch (e) {
    LogService.e("Firebase initialization error", e);
  }
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => DiscoveryProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => ConnectivityProvider()),
        ChangeNotifierProvider(create: (_) => BadgeProvider()..initialize()),
        ChangeNotifierProvider(create: (_) => LikesProvider()),
        ChangeNotifierProvider(create: (_) => MapProvider()),
        ChangeNotifierProvider(create: (_) => StoryProvider()),
        ChangeNotifierProvider(create: (_) => SystemConfigProvider()),
        ChangeNotifierProvider(create: (_) => SpaceProvider()),
        ChangeNotifierProvider(create: (_) => SubscriptionProvider()..init()),
        ChangeNotifierProvider(create: (_) => CreditProvider()),
      ],
      child: const DengimApp(),
    ),
  );
}




class DengimApp extends StatefulWidget {
  const DengimApp({super.key});

  @override
  State<DengimApp> createState() => _DengimAppState();
}

class _DengimAppState extends State<DengimApp> with WidgetsBindingObserver {
  final ProfileService _profileService = ProfileService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _updateStatus(true);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _updateStatus(false);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _updateStatus(true);
    } else {
      _updateStatus(false);
    }
  }

  void _updateStatus(bool isOnline) {
    if (FirebaseAuth.instance.currentUser != null) {
      _profileService.updateOnlineStatus(isOnline);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SystemConfigProvider>(
      builder: (context, config, child) {
        return MaterialApp(
          title: 'DENGİM',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.darkTheme,
          builder: (context, child) => ResponsiveCenterWrapper(
            child: NetworkWrapper(child: child!),
          ),
          home: config.isMaintenanceMode 
              ? const MaintenanceScreen() 
              : const SplashScreen(),
        );
      },
    );
  }
}


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.8, curve: Curves.easeOutBack)),
    );

    _controller.forward();
    _checkFirstTime();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _checkFirstTime() async {
    // Biraz bekleyelim ki animasyon tadı çıksın
    await Future.delayed(const Duration(seconds: 2));

    try {
      final prefs = await SharedPreferences.getInstance();
      final isFirstTime = prefs.getBool('isFirstTime') ?? true;

      if (!mounted) return;

      if (isFirstTime) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const OnboardingScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      } else {
        final user = FirebaseAuth.instance.currentUser;
        
        if (user == null) {
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          );
        } else {
          try {
            final userProvider = Provider.of<UserProvider>(context, listen: false);
            await userProvider.loadCurrentUser();
            
            if (!mounted) return;

            // Kredi sağlayıcısını başlat ve günlük ödülü kontrol et
            final creditProvider = Provider.of<CreditProvider>(context, listen: false);
            await creditProvider.init();
            await creditProvider.claimDailyReward();

            Widget nextScreen = userProvider.currentUser != null 
                ? const MainScaffold() 
                : const CreateProfileScreen();

            Navigator.of(context).pushReplacement(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => nextScreen,
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
              ),
            );
          } catch (e) {
            LogService.e("Profile check error", e);
            if (mounted) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const CreateProfileScreen()),
              );
            }
          }
        }
      }
    } catch (e) {
      LogService.e("SPLASH ERROR", e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F), // Darker, more premium black
      body: Stack(
        children: [
          // Background Glows
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.05),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                child: Container(),
              ),
            ),
          ),
          
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo Container
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.2),
                            blurRadius: 40,
                            spreadRadius: 5,
                          ),
                        ],
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, Color(0xFFE5A110)], // Sophisticated gold gradient
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.local_fire_department_rounded,
                          size: 70,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Brand Name
                    RichText(
                      text: TextSpan(
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 42,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -1,
                        ),
                        children: [
                          const TextSpan(text: 'DENG'),
                          TextSpan(
                            text: 'İM',
                            style: TextStyle(
                              color: AppColors.primary,
                              shadows: [
                                Shadow(
                                  color: AppColors.primary.withOpacity(0.4),
                                  blurRadius: 15,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'DENGİNİ BURADA BUL',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white38,
                        letterSpacing: 4.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Bottom Loading Indicator
          Positioned(
            bottom: 64,
            left: 0,
            right: 0,
            child: Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    const SizedBox(
                      width: 32,
                      child: LinearProgressIndicator(
                        backgroundColor: Colors.white10,
                        color: AppColors.primary,
                        minHeight: 2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'BAŞLATILIYOR',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white24,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
