/// Dengim Özellik Erişim Matrisi
/// Hangi tier'da hangi özellik var, net tanımlı.
class TierLimits {
  TierLimits._();

  // ══════════════════════════════════════════
  //  FREE (Freemium) Kullanıcı Limitleri
  // ══════════════════════════════════════════
  static const int freeDailyLikes = 25;
  static const int freeDailySuperLikes = 0;  // Kredi ile alınabilir
  static const int freeMaxPhotos = 4;
  static const int freeRewindsPerDay = 0;    // Kredi ile alınabilir
  static const bool freeCanSeeWhoLiked = false;
  static const bool freeCanVideoCall = false;
  static const bool freeCanVoiceCall = false;
  static const bool freeCanSendVoiceMessage = false;
  static const bool freeHasAdvancedFilters = false;
  static const bool freeCanBoost = false;    // Kredi ile alınabilir
  static const bool freeShowsAds = true;
  static const bool freeCanUseIncognito = false;
  static const bool freeCanSeeReadReceipts = false;
  static const int freeMaxSwipesPerDay = 25;

  // ══════════════════════════════════════════
  //  GOLD Kullanıcı Limitleri
  // ══════════════════════════════════════════
  static const int goldDailyLikes = 1000;
  static const int goldDailySuperLikes = 5;
  static const int goldMaxPhotos = 8;
  static const int goldRewindsPerDay = 5;
  static const bool goldCanSeeWhoLiked = false;
  static const bool goldCanVideoCall = false;
  static const bool goldCanVoiceCall = true;
  static const bool goldCanSendVoiceMessage = true;
  static const bool goldHasAdvancedFilters = true;
  static const bool goldCanBoost = true;  // Haftada 1
  static const bool goldShowsAds = false;
  static const bool goldCanUseIncognito = false;
  static const bool goldCanSeeReadReceipts = true;
  static const int goldMaxSwipesPerDay = 1000;

  // ══════════════════════════════════════════
  //  PLATINUM Kullanıcı Limitleri
  // ══════════════════════════════════════════
  static const int platinumDailyLikes = 999999; // Sınırsız
  static const int platinumDailySuperLikes = 10;
  static const int platinumMaxPhotos = 12;
  static const int platinumRewindsPerDay = 999999; // Sınırsız
  static const bool platinumCanSeeWhoLiked = true;
  static const bool platinumCanVideoCall = true;
  static const bool platinumCanVoiceCall = true;
  static const bool platinumCanSendVoiceMessage = true;
  static const bool platinumHasAdvancedFilters = true;
  static const bool platinumCanBoost = true;  // Haftada 3
  static const bool platinumShowsAds = false;
  static const bool platinumCanUseIncognito = true;
  static const bool platinumCanSeeReadReceipts = true;
  static const int platinumMaxSwipesPerDay = 999999;

  // ══════════════════════════════════════════
  //  TIER BAZLI ERİŞİM
  // ══════════════════════════════════════════

  static int getDailyLikes(String tier) {
    switch (tier) {
      case 'platinum': return platinumDailyLikes;
      case 'gold': return goldDailyLikes;
      default: return freeDailyLikes;
    }
  }

  static int getDailySuperLikes(String tier) {
    switch (tier) {
      case 'platinum': return platinumDailySuperLikes;
      case 'gold': return goldDailySuperLikes;
      default: return freeDailySuperLikes;
    }
  }

  static int getMaxPhotos(String tier) {
    switch (tier) {
      case 'platinum': return platinumMaxPhotos;
      case 'gold': return goldMaxPhotos;
      default: return freeMaxPhotos;
    }
  }

  static int getRewindsPerDay(String tier) {
    switch (tier) {
      case 'platinum': return platinumRewindsPerDay;
      case 'gold': return goldRewindsPerDay;
      default: return freeRewindsPerDay;
    }
  }

  static bool canSeeWhoLiked(String tier) {
    switch (tier) {
      case 'platinum': return platinumCanSeeWhoLiked;
      case 'gold': return goldCanSeeWhoLiked;
      default: return freeCanSeeWhoLiked;
    }
  }

  static bool canVideoCall(String tier) {
    switch (tier) {
      case 'platinum': return platinumCanVideoCall;
      case 'gold': return goldCanVideoCall;
      default: return freeCanVideoCall;
    }
  }

  static bool canVoiceCall(String tier) {
    switch (tier) {
      case 'platinum': return platinumCanVoiceCall;
      case 'gold': return goldCanVoiceCall;
      default: return freeCanVoiceCall;
    }
  }

  static bool canSendVoiceMessage(String tier) {
    switch (tier) {
      case 'platinum': return platinumCanSendVoiceMessage;
      case 'gold': return goldCanSendVoiceMessage;
      default: return freeCanSendVoiceMessage;
    }
  }

  static bool hasAdvancedFilters(String tier) {
    switch (tier) {
      case 'platinum': return platinumHasAdvancedFilters;
      case 'gold': return goldHasAdvancedFilters;
      default: return freeHasAdvancedFilters;
    }
  }

  static bool canBoost(String tier) {
    switch (tier) {
      case 'platinum': return platinumCanBoost;
      case 'gold': return goldCanBoost;
      default: return freeCanBoost;
    }
  }

  static bool showsAds(String tier) {
    switch (tier) {
      case 'platinum': return platinumShowsAds;
      case 'gold': return goldShowsAds;
      default: return freeShowsAds;
    }
  }

  static bool canUseIncognito(String tier) {
    switch (tier) {
      case 'platinum': return platinumCanUseIncognito;
      case 'gold': return goldCanUseIncognito;
      default: return freeCanUseIncognito;
    }
  }

  static bool canSeeReadReceipts(String tier) {
    switch (tier) {
      case 'platinum': return platinumCanSeeReadReceipts;
      case 'gold': return goldCanSeeReadReceipts;
      default: return freeCanSeeReadReceipts;
    }
  }

  static int getMaxSwipesPerDay(String tier) {
    switch (tier) {
      case 'platinum': return platinumMaxSwipesPerDay;
      case 'gold': return goldMaxSwipesPerDay;
      default: return freeMaxSwipesPerDay;
    }
  }

  /// Tier'ın Türkçe görünen adını döner
  static String getTierDisplayName(String tier) {
    switch (tier) {
      case 'platinum': return 'Platinum';
      case 'gold': return 'Gold';
      default: return 'Ücretsiz';
    }
  }

  /// Tier'ın tüm özelliklerinin listesi (Premium ekranı için)
  static List<String> getFeaturesFor(String tier) {
    switch (tier) {
      case 'gold':
        return [
          'Günde $goldDailyLikes beğeni hakkı',
          'Günde $goldDailySuperLikes Super Like',
          '$goldMaxPhotos fotoğraf yükleme',
          'Günde $goldRewindsPerDay geri alma',
          'Sesli mesaj gönderme',
          'Gelişmiş filtreler',
          'Reklamsız deneyim',
          'Okundu bilgisi',
        ];
      case 'platinum':
        return [
          'Sınırsız beğeni hakkı',
          'Günde $platinumDailySuperLikes Super Like',
          '$platinumMaxPhotos fotoğraf yükleme',
          'Sınırsız geri alma',
          'Seni beğenenleri görme',
          'Görüntülü ve sesli arama',
          'Gizli mod (Incognito)',
          'Haftada 3 Boost',
          'Aramalarda öncelik',
          'Reklamsız deneyim',
        ];
      default:
        return [
          'Günde $freeDailyLikes beğeni hakkı',
          '$freeMaxPhotos fotoğraf yükleme',
          'Temel arama',
          'Reklam izleyerek kredi kazan',
        ];
    }
  }
}
