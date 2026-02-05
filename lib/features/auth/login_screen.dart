import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import 'services/auth_service.dart';
import 'register_screen.dart';
import '../create_profile/create_profile_screen.dart';
import '../../features/main/main_scaffold.dart';

import 'package:provider/provider.dart';
import '../../core/providers/user_provider.dart';
import '../../core/utils/log_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  void _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final userCredential = await _authService.signInWithGoogle();
      if (userCredential != null) {
        if (!mounted) return;
        await _checkProfileAndNavigate();
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      LogService.e("Google Sign In Error", e);
      _showError('Giriş başarısız: ${e.toString()}');
    }
  }

  Future<void> _checkProfileAndNavigate() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.loadCurrentUser();
      
      if (!mounted) return;

      if (userProvider.currentUser != null) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const MainScaffold()),
          (route) => false,
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const CreateProfileScreen()),
        );
      }
    } catch (e) {
      LogService.e("Profile Navigation Error", e);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const CreateProfileScreen()),
      );
    }
  }


  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  // Email Giriş Formunu Aç (Telefon butonu yerine)
  void _showEmailLoginForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.scaffold,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 24,
          right: 24,
          top: 24,
        ),
        child: _EmailLoginForm(
          authService: _authService,
          onSuccess: _checkProfileAndNavigate,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: Stack(
        children: [
          // Background Gradient Glow
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.1),
              ),
              child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100), child: Container()),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                // Top Logo
                Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: Text(
                    'DENGIM',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4.0,
                      color: Colors.white.withOpacity(0.4),
                    ),
                  ),
                ),
                
                const Spacer(),
                
                // Hero Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    children: [
                      Text(
                        'DENGIM',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 48,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Ayrıcalıklı bir dünyaya adım atın.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          color: Colors.white54,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 64),
                
                // Action Buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    children: [
                      _LoginButton(
                        icon: Icons.phone_android_rounded,
                        text: 'Telefon ile Devam Et',
                        color: AppColors.vibrantGold,
                        textColor: Colors.black,
                        onTap: _showEmailLoginForm,
                      ),
                      const SizedBox(height: 16),
                      _LoginButton(
                        icon: Icons.cloud_outlined,
                        text: 'Google ile Devam Et',
                        color: Colors.white.withOpacity(0.05),
                        textColor: Colors.white,
                        borderColor: Colors.white.withOpacity(0.1),
                        isImage: true,
                        imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/768px-Google_%22G%22_logo.svg.png',
                        onTap: _isLoading ? null : _signInWithGoogle,
                      ),
                      const SizedBox(height: 16),
                      _LoginButton(
                        icon: Icons.apple,
                        text: 'Apple ile Devam Et',
                        color: Colors.white.withOpacity(0.05),
                        textColor: Colors.white,
                        borderColor: Colors.white.withOpacity(0.1),
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
                
                const Spacer(),
                
                // Footer
                Padding(
                  padding: const EdgeInsets.fromLTRB(48, 0, 48, 32),
                  child: Text(
                    'Devam ederek Kullanım Koşullarını ve Gizlilik Politikamızı kabul etmiş olursunuz.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: Colors.white24,
                      height: 1.6,
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
}

class _LoginButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  final Color textColor;
  final Color? borderColor;
  final VoidCallback? onTap;
  final bool isImage;
  final String? imageUrl;

  const _LoginButton({
    required this.icon,
    required this.text,
    required this.color,
    required this.textColor,
    this.borderColor,
    this.onTap,
    this.isImage = false,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(16), // Rounded-xl
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: borderColor != null ? Border.all(color: borderColor!) : null,
          ),
          child: Row(
            children: [
              if (isImage && imageUrl != null)
                Image.network(imageUrl!, width: 20, height: 20)
              else
                Icon(icon, color: textColor, size: 20),
              
              Expanded(
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w500, // Medium
                    color: textColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(width: 20), // Balance icon
            ],
          ),
        ),
      ),
    );
  }
}

// Bottom Sheet Form for Email/Password
class _EmailLoginForm extends StatefulWidget {
  final AuthService authService;
  final VoidCallback onSuccess;

  const _EmailLoginForm({required this.authService, required this.onSuccess});

  @override
  State<_EmailLoginForm> createState() => _EmailLoginFormState();
}

class _EmailLoginFormState extends State<_EmailLoginForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  void _login() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      await widget.authService.signInWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
      );
      widget.onSuccess();
    } catch (e) {
      if (mounted) setState(() { _isLoading = false; _error = "Hatalı e-posta veya şifre."; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'E-posta ile Giriş',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 24),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(_error!, style: const TextStyle(color: Colors.red)),
          ),
        TextField(
          controller: _emailController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'E-posta',
            hintStyle: const TextStyle(color: Colors.white54),
            filled: true,
            fillColor: Colors.white10,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _passwordController,
          obscureText: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Şifre',
            hintStyle: const TextStyle(color: Colors.white54),
            filled: true,
            fillColor: Colors.white10,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _isLoading ? null : _login,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.vibrantGold,
            foregroundColor: Colors.black,
            minimumSize: const Size(double.infinity, 50),
          ),
          child: _isLoading 
            ? const CircularProgressIndicator(color: Colors.black) 
            : const Text('Giriş Yap'),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (c) => const RegisterScreen()));
          },
          child: Text('Hesabın yok mu? Kayıt Ol', style: TextStyle(color: AppColors.secondary)),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}
