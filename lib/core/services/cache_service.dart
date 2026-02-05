import 'dart:async';
import '../utils/log_service.dart';

/// Basit in-memory cache servisi
/// Kullanıcı profilleri gibi sık erişilen verileri cache'ler
class CacheService {
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  final Map<String, _CacheEntry> _cache = {};
  
  /// Varsayılan cache süresi (5 dakika)
  static const Duration defaultDuration = Duration(minutes: 5);

  /// Veriyi cache'e ekle
  void set<T>(String key, T value, {Duration? duration}) {
    final expiry = DateTime.now().add(duration ?? defaultDuration);
    _cache[key] = _CacheEntry(value: value, expiry: expiry);
    LogService.d('Cache set: $key (expires: $expiry)');
  }

  /// Veriyi cache'den al
  T? get<T>(String key) {
    final entry = _cache[key];
    if (entry == null) return null;
    
    if (entry.isExpired) {
      _cache.remove(key);
      LogService.d('Cache expired: $key');
      return null;
    }
    
    LogService.d('Cache hit: $key');
    return entry.value as T?;
  }

  /// Cache'de var mı kontrol et
  bool has(String key) {
    final entry = _cache[key];
    if (entry == null) return false;
    if (entry.isExpired) {
      _cache.remove(key);
      return false;
    }
    return true;
  }

  /// Belirli key'i sil
  void remove(String key) {
    _cache.remove(key);
    LogService.d('Cache removed: $key');
  }

  /// Prefix ile başlayan tüm key'leri sil
  void removeByPrefix(String prefix) {
    _cache.removeWhere((key, _) => key.startsWith(prefix));
    LogService.d('Cache cleared with prefix: $prefix');
  }

  /// Tüm cache'i temizle
  void clear() {
    _cache.clear();
    LogService.d('Cache cleared completely');
  }

  /// Süresi dolmuş cache'leri temizle
  void cleanExpired() {
    final expiredKeys = _cache.entries
        .where((e) => e.value.isExpired)
        .map((e) => e.key)
        .toList();
    
    for (var key in expiredKeys) {
      _cache.remove(key);
    }
    
    if (expiredKeys.isNotEmpty) {
      LogService.d('Cleaned ${expiredKeys.length} expired cache entries');
    }
  }

  /// Cache boyutunu al
  int get size => _cache.length;

  /// Getir veya yükle (cache-aside pattern)
  Future<T?> getOrFetch<T>(
    String key,
    Future<T?> Function() fetcher, {
    Duration? duration,
  }) async {
    // Önce cache'e bak
    final cached = get<T>(key);
    if (cached != null) return cached;

    // Cache'de yoksa fetch et
    try {
      final data = await fetcher();
      if (data != null) {
        set(key, data, duration: duration);
      }
      return data;
    } catch (e) {
      LogService.e('Cache fetch error for $key', e);
      return null;
    }
  }
}

/// Cache entry - değer ve son kullanma tarihi tutar
class _CacheEntry {
  final dynamic value;
  final DateTime expiry;

  _CacheEntry({required this.value, required this.expiry});

  bool get isExpired => DateTime.now().isAfter(expiry);
}

/// Cache key oluşturucular
class CacheKeys {
  static String userProfile(String uid) => 'user_profile_$uid';
  static String userPhotos(String uid) => 'user_photos_$uid';
  static String matches(String uid) => 'matches_$uid';
  static String conversations(String uid) => 'conversations_$uid';
  static String nearbyUsers(String uid) => 'nearby_users_$uid';
  static String stories(String uid) => 'stories_$uid';
}
