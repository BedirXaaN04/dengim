import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import '../../core/theme/app_colors.dart';
import 'models/nearby_user.dart';
import 'widgets/nearby_users_list.dart';

import 'package:provider/provider.dart';
import '../../core/providers/map_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';


class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  double _initialZoom = 13.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MapProvider>().initializeMap().then((_) {
        // Move camera to current location once initialized
        final loc = context.read<MapProvider>().currentLocation;
        _mapController.move(loc, _initialZoom);
      });
    });
  }

  void _onUserTap(NearbyUser user) {
    _animatedMapMove(LatLng(user.latitude, user.longitude), 16);
    HapticFeedback.mediumImpact();
    _showUserProfile(user);
  }


  void _animatedMapMove(LatLng destLocation, double destZoom) {
    final camera = _mapController.camera;
    final latTween = Tween<double>(begin: camera.center.latitude, end: destLocation.latitude);
    final lngTween = Tween<double>(begin: camera.center.longitude, end: destLocation.longitude);
    final zoomTween = Tween<double>(begin: camera.zoom, end: destZoom);

    final controller = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    final Animation<double> animation = CurvedAnimation(parent: controller, curve: Curves.easeOutCubic);

    controller.addListener(() {
      _mapController.move(
        LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
        zoomTween.evaluate(animation),
      );
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) controller.dispose();
    });

    controller.forward();
  }

  void _centerOnLocation() {
    HapticFeedback.mediumImpact();
    final loc = context.read<MapProvider>().currentLocation;
    _animatedMapMove(loc, 15);
  }

  void _showUserProfile(NearbyUser user) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A).withOpacity(0.9),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Tutamaç
                Container(
                  width: 40, height: 4, margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(2)),
                ),
                
                Row(
                  children: [
                    // Avatar
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppColors.goldGradient,
                      ),
                      child: Container(
                        width: 84, height: 84,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.scaffold, width: 3),
                        ),
                        child: ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: user.avatarUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(color: AppColors.surface),
                            errorWidget: (context, url, error) => const Icon(Icons.person),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${user.name}, ${user.age}', 
                            style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Container(
                                width: 8, height: 8, 
                                decoration: BoxDecoration(
                                  color: user.isOnline ? AppColors.success : Colors.grey, 
                                  shape: BoxShape.circle
                                )
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${user.distance.toStringAsFixed(1)} KM UZAKTA', 
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12, 
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white.withOpacity(0.5),
                                  letterSpacing: 1.0,
                                )
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                
                // Butonlar
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.black,
                          elevation: 0,
                          minimumSize: const Size(double.infinity, 56),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text(
                          'PROFİLE GİT', 
                          style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.0)
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      width: 56, height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: Consumer<MapProvider>(
        builder: (context, provider, child) {
          return Stack(
            children: [
              // Koyu Harita Katmanı
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: provider.currentLocation,
                  initialZoom: _initialZoom,
                  minZoom: 3,
                  maxZoom: 18,
                  backgroundColor: AppColors.scaffold,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.dengim.app',
                    tileBuilder: (context, tileWidget, tile) {
                      return ColorFiltered(
                        colorFilter: const ColorFilter.matrix(<double>[
                          0.2126, 0.7152, 0.0722, 0, -20,
                          0.2126, 0.7152, 0.0722, 0, -20,
                          0.2126, 0.7152, 0.0722, 0, -10,
                          0, 0, 0, 1, 0,
                        ]),
                        child: ColorFiltered(
                          colorFilter: ColorFilter.mode(const Color(0xFF0F172A).withOpacity(0.6), BlendMode.srcOver),
                          child: tileWidget,
                        ),
                      );
                    },
                  ),
                  MarkerLayer(
                    markers: [
                      // Benim Konumum
                      Marker(
                        point: provider.currentLocation,
                        width: 80, height: 80,
                        child: _buildMyLocationMarker(),
                      ),
                      ...provider.nearbyUsers.map((user) => Marker(
                        point: LatLng(user.latitude, user.longitude),
                        width: 60, height: 75,
                        child: GestureDetector(
                          onTap: () => _onUserTap(user),
                          child: _buildUserMarker(user),
                        ),
                      )),
                    ],
                  ),
                ],
              ),
              
              if (provider.isLoading)
                const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                
              Positioned(top: 0, left: 0, right: 0, child: _buildTopBar(provider.nearbyUsers.length)),
              Positioned(right: 20, bottom: 240, child: _buildZoomControls()),
              Positioned(bottom: 0, left: 0, right: 0, child: NearbyUsersList(users: provider.nearbyUsers, onUserTap: _onUserTap)),
            ],
          );
        },
      ),
    );
  }


  Widget _buildMyLocationMarker() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Dış Halka (Glow)
        Container(
          width: 80, height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary.withOpacity(0.15),
          ),
        ),
        // Orta Halka
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary.withOpacity(0.3),
            border: Border.all(color: AppColors.primary, width: 1),
          ),
        ),
        // Merkez
        Container(
          width: 16, height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.6),
                blurRadius: 10,
                spreadRadius: 2,
              )
            ]
          ),
        ),
      ],
    );
  }

  Widget _buildUserMarker(NearbyUser user) {
     return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary, width: 2),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 8, offset: const Offset(0, 4))
            ],
            color: AppColors.scaffold,
          ),
          child: ClipOval(
            child: Image.network(
              user.avatarUrl, 
              fit: BoxFit.cover, 
              errorBuilder: (_,__,___) => Container(color: AppColors.surface, child: const Icon(Icons.person, color: Colors.white54))
            ),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6), 
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Text(
            user.name.toUpperCase(), 
            style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5)
          ),
        ),
      ],
    );
  }

  Widget _buildTopBar(int activeCount) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 12, left: 24, right: 24, bottom: 16),
          decoration: BoxDecoration(
            color: AppColors.scaffold.withOpacity(0.8),
            border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'HARİTA',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 3.0,
                  color: Colors.white,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: activeCount > 0 
                      ? AppColors.primary.withOpacity(0.1)
                      : Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: activeCount > 0 
                        ? AppColors.primary.withOpacity(0.2)
                        : Colors.white.withOpacity(0.1),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 6, 
                      height: 6, 
                      decoration: BoxDecoration(
                        color: activeCount > 0 ? AppColors.primary : Colors.white38, 
                        shape: BoxShape.circle
                      )
                    ),
                    const SizedBox(width: 6),
                    Text(
                      activeCount > 0 
                          ? '$activeCount AKTİF'
                          : 'KEŞFET',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10, 
                        fontWeight: FontWeight.bold, 
                        color: activeCount > 0 ? AppColors.primary : Colors.white38,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildZoomControls() {
    return Column(
      children: [
        _buildControlButton(icon: Icons.gps_fixed_rounded, onTap: _centerOnLocation),
        const SizedBox(height: 12),
        _buildControlButton(icon: Icons.add_rounded, onTap: () => _mapController.move(_mapController.camera.center, _mapController.camera.zoom + 1)),
        const SizedBox(height: 12),
        _buildControlButton(icon: Icons.remove_rounded, onTap: () => _mapController.move(_mapController.camera.center, _mapController.camera.zoom - 1)),
      ],
    );
  }

  Widget _buildControlButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
        ),
      ),
    );
  }
}

