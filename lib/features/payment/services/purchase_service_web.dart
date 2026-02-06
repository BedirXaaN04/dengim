// Stub file for web - PurchaseService
// purchases_flutter (RevenueCat) is not supported on web

import 'package:flutter/foundation.dart';

class PurchaseService {
  static final PurchaseService _instance = PurchaseService._internal();
  factory PurchaseService() => _instance;
  PurchaseService._internal();

  Future<void> init() async {
    if (kIsWeb) {
      debugPrint("PurchaseService: Web platform - purchases disabled.");
      return;
    }
  }

  Future<void> logIn(String userId) async {}
  Future<void> logOut() async {}
  Future<dynamic> getOfferings() async => null;
  Future<bool> purchasePackage(dynamic package) async => false;
  Future<bool> checkPremiumStatus() async => false;
  Future<bool> restorePurchases() async => false;
}
