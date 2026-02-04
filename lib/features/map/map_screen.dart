import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/theme/app_colors.dart';
import 'models/nearby_user.dart';
import 'widgets/nearby_users_list.dart';
import '../auth/services/auth_service.dart';
import 'dart:math' as math;

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  final AuthService _authService = AuthService();
  
  List<NearbyUser> _nearbyUsers = [];
  List<CircleMarker> _heatCircles = []; 
  
  LatLng _currentLocation = const LatLng(41.0082, 28.9784); // Default Istanbul
  double _initialZoom = 13.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    await _determinePosition();
    await _fetchNearbyUsers();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Konum servisleri kapalı.')));
      }
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Konum izni reddedildi.')));
        }
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Konum izni kalıcı olarak reddedildi.')));
      }
      return;
    }

    final position = await Geolocator.getCurrentPosition();
    
    // Konumu Firestore'a güncelle
    _authService.updateLocation(position.latitude, position.longitude);

    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
    });
    
    // Haritayı kullanıcının konumuna taşı
    _mapController.move(_currentLocation, _initialZoom);
  }

  Future<void> _fetchNearbyUsers() async {
    try {
      final usersData = await _authService.getUsersToMatch();
      
      final List<NearbyUser> loadedUsers = [];

      for (var data in usersData) {
        // Konum verisi olmayan kullanıcıları atla
        if (data['latitude'] == null || data['longitude'] == null) continue;

        double userLat = (data['latitude'] as num).toDouble();
        double userLng = (data['longitude'] as num).toDouble();
        
        // Mesafe hesapla
        final Distance distanceCalc = const Distance();
        double distKm = distanceCalc.as(LengthUnit.Kilometer, _currentLocation, LatLng(userLat, userLng));

        // İsteğe bağlı: Çok uzak kullanıcıları gösterme (örneğin > 100km)
        // if (distKm > 100) continue;

        loadedUsers.add(NearbyUser(
          id: data['uid'] ?? '',
          name: data['name'] ?? 'İsimsiz',
          age: data['age'] ?? 18,
          avatarUrl: (data['photoUrls'] != null && (data['photoUrls'] as List).isNotEmpty)
              ? data['photoUrls'][0]
              : 'https://images.unsplash.com/photo-1511367461989-f85a21fda167?w=500&auto=format&fit=crop&q=60',
          latitude: userLat,
          longitude: userLng,
          distance: distKm,
          isOnline: data['isOnline'] ?? false,
        ));
      }

      setState(() {
        _nearbyUsers = loadedUsers;
        _isLoading = false;
      });

    } catch (e) {
      print("Error fetching nearby users: $e");
      setState(() => _isLoading = false);
    }
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
    _animatedMapMove(_currentLocation, 15);
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
                        width: 84, height: 84, // 3px border + 84 image
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.scaffold, width: 3),
                        ),
                        child: ClipOval(child: Image.network(user.avatarUrl, fit: BoxFit.cover)),
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
                          // Mesajlaşma veya Profile git
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
      body: Stack(
        children: [
          // Koyu Harita Katmanı
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentLocation,
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
                    // Haritayı aşırı koyu ve 'Midnight Blue' tonuna çekiyoruz
                    colorFilter: const ColorFilter.matrix(<double>[
                      0.2126, 0.7152, 0.0722, 0, -20, // R (Daha karanlık)
                      0.2126, 0.7152, 0.0722, 0, -20, // G
                      0.2126, 0.7152, 0.0722, 0, -10, // B (Hafif mavi kalsın)
                      0, 0, 0, 1, 0,
                    ]),
                    child: ColorFiltered(
                      colorFilter: ColorFilter.mode(const Color(0xFF0F172A).withOpacity(0.6), BlendMode.srcOver), // Lacivert overlay
                      child: tileWidget,
                    ),
                  );
                },
              ),
              MarkerLayer(
                markers: [
                  // Benim Konumum (Altın Radar Efekti)
                  Marker(
                    point: _currentLocation,
                    width: 80, height: 80,
                    child: _buildMyLocationMarker(),
                  ),
                  ..._nearbyUsers.map((user) => Marker(
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
          
          if (_isLoading)
            const Center(child: CircularProgressIndicator(color: AppColors.primary)),
            
          Positioned(top: 0, left: 0, right: 0, child: _buildTopBar()),
          Positioned(right: 20, bottom: 240, child: _buildZoomControls()),
          Positioned(bottom: 0, left: 0, right: 0, child: NearbyUsersList(users: _nearbyUsers, onUserTap: _onUserTap)),
        ],
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

  Widget _buildTopBar() {
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
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Text(
                      '${_nearbyUsers.length} AKTİF',
                      style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary),
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

