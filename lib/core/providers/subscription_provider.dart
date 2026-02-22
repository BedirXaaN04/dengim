import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../../services/purchase_service.dart';
import '../utils/log_service.dart';

class SubscriptionProvider with ChangeNotifier {
  final PurchaseService _purchaseService = PurchaseService();
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<ProductDetails> get products => _purchaseService.products;
  bool get isAvailable => _purchaseService.isAvailable;

  String _currentTier = 'free';
  String get currentTier => _currentTier;
  
  bool get isGold => _currentTier == 'gold' || _currentTier == 'platinum';
  bool get isPlatinum => _currentTier == 'platinum';

  Future<void> init() async {
    try {
      _setLoading(true);
      // Timeout added to prevent permanent loading loop if store hangs
      await _purchaseService.init().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          LogService.w("Purchase Service init timed out");
        },
      );
    } catch (e) {
      LogService.e("Subscription Provider init error", e);
    } finally {
      _setLoading(false);
    }
  }

  void updateTier(String tier) {
    _currentTier = tier;
    notifyListeners();
  }

  Future<void> buyProduct(ProductDetails product) async {
    try {
      _setLoading(true);
      await _purchaseService.buyProduct(product);
    } catch (e) {
      LogService.e("Purchase error", e);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> restorePurchases() async {
    try {
      _setLoading(true);
      await _purchaseService.restorePurchases();
    } catch (e) {
      LogService.e("Restore error", e);
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
