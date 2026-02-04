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

import 'package:flutter/foundation.dart';

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
    print("DENGİM: Firebase başlatılıyor...");
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
    print("DENGİM: Firebase başlatıldı.");
    
    if (kIsWeb) {
      FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: false);
    }
  } catch (e) {
    print("DENGİM: Firebase başlatma hatası: $e");
  }
  
  runApp(const DengimApp());
}

class DengimApp extends StatelessWidget {
  const DengimApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DENGİM',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      // Web ve Desktop için responsive wrapper
      builder: (context, child) => ResponsiveCenterWrapper(child: child!),
      home: const SplashScreen(),
    );
  }
}

/// Açılış Ekranı - Kullanıcının ilk giriş durumunu kontrol eder
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
    print("SPLASH: Waiting 2 seconds...");
    // 2 saniyelik yapay bekleme (logo görünmesi için)
    await Future.delayed(const Duration(seconds: 2));
    print("SPLASH: Waited.");

    try {
      print("SPLASH: Getting SharedPreferences...");
      final prefs = await SharedPreferences.getInstance();
      print("SPLASH: Got SharedPreferences.");
      final isFirstTime = prefs.getBool('isFirstTime') ?? true;
      print("SPLASH: isFirstTime: $isFirstTime");

      if (!mounted) {
        print("SPLASH: Context not mounted!");
        return;
      }

      if (isFirstTime) {
        print("SPLASH: Navigating to OnboardingScreen...");
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
        );
      } else {
        // Auth kontrolü
        print("SPLASH: Checking Auth...");
        final user = FirebaseAuth.instance.currentUser;
        print("SPLASH: User: $user");
        
        if (user == null) {
          print("SPLASH: Navigating to LoginScreen...");
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        } else {
          // Profil kontrolü
          print("SPLASH: Checking Profile...");
          try {
            final hasProfile = await AuthService().hasProfile();
            
            if (!mounted) return;

            if (hasProfile) {
              print("SPLASH: Profile exists. Navigating to MainScaffold...");
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const MainScaffold()),
              );
            } else {
              print("SPLASH: Profile missing. Navigating to CreateProfileScreen...");
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const CreateProfileScreen()),
              );
            }
          } catch (e) {
            print("SPLASH: Profile check error: $e");
            // Hata durumunda create profile'a yönlendir (güvenli taraf)
             if (mounted) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const CreateProfileScreen()),
              );
            }
          }
        }
      }
    } catch (e) {
      print("SPLASH ERROR: $e");
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
            // Logo
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
            // Başlık
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
            // Yükleniyor
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
