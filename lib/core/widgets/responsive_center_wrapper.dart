import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';


/// Web ve Desktop için içeriği mobil boyutlarında ortalayan wrapper.
class ResponsiveCenterWrapper extends StatelessWidget {
  final Widget child;

  const ResponsiveCenterWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // Sadece Web veya Desktop ise uygula
    if (kIsWeb || (defaultTargetPlatform != TargetPlatform.android && defaultTargetPlatform != TargetPlatform.iOS)) {
      return Container(
        color: const Color(0xFF0F1115), // Arka plan (Scaffold rengiyle uyumlu koyu)
        alignment: Alignment.center,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 480), // Maksimum mobil genişliği
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: ClipRRect(
            // Web'de scroll bar'ın taşmasını engellemek için clip
            child: child,
          ),
        ),
      );
    }
    
    // Mobilde direkt içeriği göster
    return child;
  }
}
