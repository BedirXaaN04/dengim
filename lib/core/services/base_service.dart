import '../utils/log_service.dart';

/// Tüm servisler için temel sınıf
/// Error handling, retry logic ve logging sağlar
abstract class BaseService {
  /// Güvenli async operasyon wrapper'ı
  /// Tüm hataları yakalar, loglar ve null/default döner
  Future<T?> safeAsync<T>(
    Future<T> Function() operation, {
    String? operationName,
    T? defaultValue,
    bool rethrowError = false,
  }) async {
    try {
      return await operation();
    } catch (e, stackTrace) {
      LogService.e(
        operationName ?? 'Unknown operation failed',
        e,
        stackTrace,
      );
      if (rethrowError) rethrow;
      return defaultValue;
    }
  }

  /// Retry mekanizması ile async operasyon
  Future<T?> retryAsync<T>(
    Future<T> Function() operation, {
    int maxRetries = 3,
    Duration delay = const Duration(seconds: 1),
    String? operationName,
  }) async {
    int attempts = 0;
    while (attempts < maxRetries) {
      try {
        return await operation();
      } catch (e) {
        attempts++;
        if (attempts >= maxRetries) {
          LogService.e('$operationName failed after $maxRetries attempts', e);
          return null;
        }
        await Future.delayed(delay * attempts);
      }
    }
    return null;
  }

  /// Stream için error handling wrapper
  Stream<T> safeStream<T>(
    Stream<T> Function() streamBuilder, {
    String? streamName,
    T? onErrorValue,
  }) {
    try {
      return streamBuilder().handleError((error) {
        LogService.e('$streamName stream error', error);
      });
    } catch (e) {
      LogService.e('$streamName stream creation failed', e);
      return Stream.empty();
    }
  }
}
