import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/log_service.dart';

class ConfigService {
  static final ConfigService _instance = ConfigService._internal();
  factory ConfigService() => _instance;
  ConfigService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isVipEnabled = false;
  bool isAdsEnabled = true;
  bool isCreditsEnabled = false;

  Future<void> init() async {
    try {
      // Get initial config
      final doc = await _firestore.collection('system').doc('config').get();
      if (doc.exists) {
        _updateConfig(doc.data()!);
      }

      // Listen for real-time changes
      _firestore.collection('system').doc('config').snapshots().listen((snapshot) {
        if (snapshot.exists && snapshot.data() != null) {
          _updateConfig(snapshot.data()!);
        }
      });
      
      LogService.i("Config Service initialized.");
    } catch (e) {
      LogService.e("Error initializing Config Service", e);
    }
  }

  void _updateConfig(Map<String, dynamic> data) {
    isVipEnabled = data['isVipEnabled'] ?? false;
    isAdsEnabled = data['isAdsEnabled'] ?? true;
    isCreditsEnabled = data['isCreditsEnabled'] ?? false;
    LogService.i("Config updated: VIP=$isVipEnabled, Ads=$isAdsEnabled, Credits=$isCreditsEnabled");
  }
}
