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
        color: const Color(0xFF121212), // Deep black background for web outer space
        alignment: Alignment.center,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 480), // Mobile width on web
          decoration: const BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black,
                offset: Offset(8, 8),
                blurRadius: 0,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: child,
          ),
        ),
      );
    }
    
    // Mobilde direkt içeriği göster
    return child;
  }
}
