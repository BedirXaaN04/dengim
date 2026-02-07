import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

/// Offline mode banner widget
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      color: Colors.black87,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.red.shade900, Colors.red.shade700],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.red.shade900.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'İnternet bağlantısı yok',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              'Çevrimdışı',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Connection status banner (can show WiFi, Mobile, etc.)
class ConnectionStatusBanner extends StatelessWidget {
  final String connectionType;
  final bool isReconnected;
  
  const ConnectionStatusBanner({
    super.key,
    required this.connectionType,
    this.isReconnected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade700, Colors.green.shade500],
          ),
        ),
        child: Row(
          children: [
            Icon(
              _getIconForConnectionType(connectionType),
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                isReconnected ? 'Bağlantı yeniden kuruldu' : 'Bağlı: $connectionType',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  IconData _getIconForConnectionType(String type) {
    if (type.contains('WiFi')) return Icons.wifi;
    if (type.contains('Mobil')) return Icons.signal_cellular_alt;
    return Icons.check_circle_outline;
  }
}
