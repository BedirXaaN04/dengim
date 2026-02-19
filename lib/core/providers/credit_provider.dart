import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/credit_service.dart';
import '../utils/log_service.dart';

/// Kredi bakiyesini ve streak bilgisini yöneten Provider
class CreditProvider extends ChangeNotifier {
  final CreditService _creditService = CreditService();

  int _balance = 0;
  int _streak = 0;
  bool _dailyRewardClaimed = false;
  int _todayAdWatches = 0;
  bool _isLoading = false;

  StreamSubscription? _balanceSubscription;

  // Getters
  int get balance => _balance;
  int get streak => _streak;
  bool get dailyRewardClaimed => _dailyRewardClaimed;
  int get todayAdWatches => _todayAdWatches;
  int get remainingAdWatches => CreditService.maxDailyAdWatches - _todayAdWatches;
  bool get canWatchAd => _todayAdWatches < CreditService.maxDailyAdWatches;
  bool get isLoading => _isLoading;

  /// Provider'ı başlat
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Bakiye stream'ini dinle
      _balanceSubscription?.cancel();
      _balanceSubscription = _creditService.getBalanceStream().listen((balance) {
        _balance = balance;
        notifyListeners();
      });

      // Streak bilgisini çek
      final streakInfo = await _creditService.getStreakInfo();
      _streak = streakInfo['streak'] ?? 0;
      _dailyRewardClaimed = streakInfo['claimed'] ?? false;

      // Bugünkü reklam izleme sayısını çek
      _todayAdWatches = await _creditService.getTodayAdWatchCount();

      LogService.i("CreditProvider initialized - Balance: $_balance, Streak: $_streak");
    } catch (e) {
      LogService.e("CreditProvider init error", e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Günlük giriş ödülünü al
  Future<bool> claimDailyReward() async {
    if (_dailyRewardClaimed) return false;

    final success = await _creditService.claimDailyLoginReward();
    if (success) {
      _dailyRewardClaimed = true;
      final streakInfo = await _creditService.getStreakInfo();
      _streak = streakInfo['streak'] ?? 0;
      notifyListeners();
    }
    return success;
  }

  /// Reklam izleme sonrası ödül al
  Future<bool> rewardAdWatch() async {
    if (!canWatchAd) return false;

    final success = await _creditService.rewardForAdWatch();
    if (success) {
      _todayAdWatches++;
      notifyListeners();
    }
    return success;
  }

  /// Kredi harca
  Future<bool> spend(int amount, String reason) async {
    if (_balance < amount) return false;
    return await _creditService.spendCredits(amount, reason);
  }

  /// Super Like harca
  Future<bool> spendSuperLike() => spend(CreditService.costSuperLike, 'super_like');

  /// Boost harca
  Future<bool> spendBoost() => spend(CreditService.costBoost, 'boost');

  /// Beğenenleri gör harca
  Future<bool> spendSeeWhoLiked() => spend(CreditService.costSeeWhoLikedYou, 'see_who_liked');

  /// Geri al harca
  Future<bool> spendUndo() => spend(CreditService.costUndoSwipe, 'undo_swipe');

  /// 10 ekstra swipe harca
  Future<bool> spendExtraSwipes() => spend(CreditService.costExtraSwipes10, 'extra_swipes');

  @override
  void dispose() {
    _balanceSubscription?.cancel();
    super.dispose();
  }
}
