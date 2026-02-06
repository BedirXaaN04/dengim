// Purchase Service with conditional platform imports
import 'package:flutter/foundation.dart';
import 'purchase_service_mobile.dart' if (dart.library.html) 'purchase_service_web.dart' as purchase;

class PurchaseService {
  static final PurchaseService _instance = PurchaseService._internal();
  factory PurchaseService() => _instance;
  PurchaseService._internal();

  final purchase.PurchaseService _platformService = purchase.PurchaseService();

  Future<void> init() async {
    if (kIsWeb) {
      debugPrint("PurchaseService: Web platform - purchases disabled.");
      return;
    }
    await _platformService.init();
  }

  Future<void> logIn(String userId) async {
    if (kIsWeb) return;
    await _platformService.logIn(userId);
  }

  Future<void> logOut() async {
    if (kIsWeb) return;
    await _platformService.logOut();
  }

  Future<dynamic> getOfferings() async {
    if (kIsWeb) return null;
    return await _platformService.getOfferings();
  }

  Future<bool> purchasePackage(dynamic package) async {
    if (kIsWeb) return false;
    return await _platformService.purchasePackage(package);
  }

  Future<bool> checkPremiumStatus() async {
    if (kIsWeb) return false;
    return await _platformService.checkPremiumStatus();
  }

  Future<bool> restorePurchases() async {
    if (kIsWeb) return false;
    return await _platformService.restorePurchases();
  }
}
