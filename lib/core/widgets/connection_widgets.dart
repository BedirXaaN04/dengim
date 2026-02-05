import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/connectivity_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Bağlantı durumu banner'ı
/// Offline olunca ekranın üstünde uyarı gösterir
class ConnectionBanner extends StatelessWidget {
  final Widget child;

  const ConnectionBanner({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityProvider>(
      builder: (context, connectivity, _) {
        final isOffline = connectivity.connectionStatus.contains(ConnectivityResult.none);
        
        return Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: isOffline ? 32 : 0,
              color: Colors.red.shade700,
              child: isOffline
                  ? const Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.wifi_off, color: Colors.white, size: 16),
                          SizedBox(width: 8),
                          Text(
                            'İnternet bağlantısı yok',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ),
                    )
                  : null,
            ),
            Expanded(child: child),
          ],
        );
      },
    );
  }
}

/// Internet bağlantısı gerekli widget wrapper
/// Offline ise alternatif içerik gösterir
class RequiresConnection extends StatelessWidget {
  final Widget child;
  final Widget? offlineWidget;

  const RequiresConnection({
    super.key,
    required this.child,
    this.offlineWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityProvider>(
      builder: (context, connectivity, _) {
        if (!connectivity.isConnected) {
          return offlineWidget ?? _buildDefaultOffline();
        }
        return child;
      },
    );
  }

  Widget _buildDefaultOffline() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off, size: 80, color: Colors.white.withOpacity(0.3)),
            const SizedBox(height: 24),
            const Text(
              'Çevrimdışısınız',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Bu özellik için internet bağlantısı gerekli.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withOpacity(0.5)),
            ),
          ],
        ),
      ),
    );
  }
}
