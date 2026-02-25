import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/error_handler.dart';
import '../auth/services/profile_service.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  File? _selfieImage;
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _takeSelfie() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
      imageQuality: 80,
    );

    if (photo != null) {
      setState(() {
        _selfieImage = File(photo.path);
      });
    }
  }

  Future<void> _submitVerification() async {
    if (_selfieImage == null) return;

    setState(() => _isUploading = true);

    try {
      await ProfileService().requestVerification(XFile(_selfieImage!.path));
      
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: const BorderSide(color: Colors.black, width: 4),
            ),
            title: Text('BAŞVURU ALINDI ✅', style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.w900)),
            content: Text(
              'PROFİL DOĞRULAMA İSTEĞİN BİZE ULAŞTI. EDİTÖRLERİMİZ İNCELEYİP ONAYLAYACAK.',
              style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.w700),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Dialog
                  Navigator.pop(context); // Screen
                },
                child: Text('TAMAM', style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.w900)),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showError(context, "Yükleme hatası: $e");
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        shape: const Border(bottom: BorderSide(color: Colors.black, width: 4)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "PROFİLİ DOĞRULA",
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
            color: Colors.black,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Spacer(),
            // Icon & Info
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 4),
                boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(4, 4))],
              ),
              child: const Icon(Icons.verified_user_rounded, size: 60, color: Colors.black),
            ),
            const SizedBox(height: 32),
            Text(
              "MAVİ TİK AL ☑️",
              style: GoogleFonts.outfit(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "SAHTE PROFİLLERDEN BİZ DE SIKILDIK. GERÇEK BİR KİŞİ OLDUĞUNU KANITLAMAK İÇİN ANLIK BİR SELFİE ÇEK.",
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: Colors.black,
                fontWeight: FontWeight.w700,
                height: 1.5,
              ),
            ),
            const Spacer(),
            
            // Image Preview Area
            if (_selfieImage != null)
              Container(
                height: 300,
                width: 300,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.black, width: 4),
                  boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(4, 4))],
                  image: DecorationImage(
                    image: FileImage(_selfieImage!),
                    fit: BoxFit.cover,
                  ),
                ),
              )
            else
              GestureDetector(
                onTap: _takeSelfie,
                child: Container(
                  height: 300,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.black, width: 4),
                    boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(4, 4))],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.camera_alt_outlined, size: 64, color: Colors.black),
                      const SizedBox(height: 16),
                      Text(
                        "SELFİE ÇEKMEK İÇİN DOKUN", 
                        style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.w900)
                      ),
                    ],
                  ),
                ),
              ),
              
            const Spacer(),
            
            // Buttons
            if (_selfieImage == null)
              SizedBox(
                width: double.infinity,
                height: 64,
                child: ElevatedButton.icon(
                  onPressed: _takeSelfie,
                  icon: const Icon(Icons.camera_alt, color: Colors.black),
                  label: Text("KAMERAYI AÇ", style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: Colors.black, width: 3),
                    ),
                    elevation: 0,
                  ),
                ),
              )
            else
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 64,
                      child: OutlinedButton(
                        onPressed: _isUploading ? null : _takeSelfie,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black,
                          side: const BorderSide(color: Colors.black, width: 3),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text("TEKRAR ÇEK", style: GoogleFonts.outfit(fontWeight: FontWeight.w900)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SizedBox(
                      height: 64,
                      child: ElevatedButton(
                        onPressed: _isUploading ? null : _submitVerification,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: const BorderSide(color: Colors.black, width: 3),
                          ),
                          elevation: 0,
                        ),
                        child: _isUploading 
                          ? const CircularProgressIndicator(color: Colors.black)
                          : Text("GÖNDER", style: GoogleFonts.outfit(fontWeight: FontWeight.w900)),
                      ),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
