import 'package:flutter/material.dart';
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
import 'features/auth/services/auth_service.dart';
import 'features/create_profile/create_profile_screen.dart';
import 'core/widgets/responsive_center_wrapper.dart'; // Web Wrapper
import 'core/widgets/network_wrapper.dart'; // Network Wrapper
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'core/providers/user_provider.dart';
import 'core/providers/discovery_provider.dart';
import 'core/providers/chat_provider.dart';
import 'core/providers/connectivity_provider.dart';
import 'core/providers/likes_provider.dart';
import 'core/providers/map_provider.dart';
import 'core/utils/log_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
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
        ChangeNotifierProvider(create: (_) => LikesProvider()),
        ChangeNotifierProvider(create: (_) => MapProvider()),
      ],
      child: const DengimApp(),
    ),
  );
}

import 'features/auth/services/profile_service.dart';

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
    return MaterialApp(
      title: 'DENGİM',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      builder: (context, child) => ResponsiveCenterWrapper(
        child: NetworkWrapper(child: child!),
      ),
      home: const SplashScreen(),
    );
  }
}


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkFirstTime();
  }

  Future<void> _checkFirstTime() async {
    await Future.delayed(const Duration(seconds: 2));

    try {
      final prefs = await SharedPreferences.getInstance();
      final isFirstTime = prefs.getBool('isFirstTime') ?? true;

      if (!mounted) return;

      if (isFirstTime) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
        );
      } else {
        final user = FirebaseAuth.instance.currentUser;
        
        if (user == null) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        } else {
          try {
            final userProvider = Provider.of<UserProvider>(context, listen: false);
            await userProvider.loadCurrentUser();
            
            if (!mounted) return;

            if (userProvider.currentUser != null) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const MainScaffold()),
              );
            } else {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const CreateProfileScreen()),
              );
            }
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
      backgroundColor: AppColors.scaffold,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withAlpha(100),
                    blurRadius: 30,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: const Icon(
                Icons.local_fire_department_rounded,
                size: 60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
                children: [
                  const TextSpan(text: 'DENG'),
                  TextSpan(
                    text: 'İM',
                    style: TextStyle(
                      color: AppColors.primary,
                      shadows: [
                        Shadow(
                          color: AppColors.primary.withAlpha(150),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
