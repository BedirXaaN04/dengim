# ANTIGRAVITY İÇİN DENGİM GELİŞTİRME PROMPTLARI

Bu dokümanda, DENGİM flört uygulamanızı geliştirmek için Antigravity AI'ya vereceğiniz detaylı promptlar bulunmaktadır. Her prompt, öncelik sırasına göre düzenlenmiştir.

---

## 🔴 FAZ 1: ACİL ÖNCELİKLER (0-4 Hafta)

### PROMPT 1: iOS In-App Purchase (IAP) Entegrasyonu

```
DENGİM adlı Flutter flört uygulamamız için iOS In-App Purchase sistemini eksiksiz şekilde entegre et:

MEVCUT DURUM:
- Flutter 3.24.5 kullanıyoruz
- Firebase Auth ve Firestore aktif
- pubspec.yaml dosyasında minimal IAP paketi var ama tam çalışmıyor

YAPILMASI GEREKENLER:

1. PAKET KURULUMU:
   - in_app_purchase: ^3.1.13 paketini ekle ve güncelle
   - iOS için StoreKit 2 konfigürasyonunu yap
   
2. ÜÇ ABONELIK PAKETİ OLUŞTUR:
   a) GOLD Paket:
      - Product ID: "dengim_gold_1month" (₺249/ay)
      - Product ID: "dengim_gold_3months" (₺599/3ay)
      - Product ID: "dengim_gold_6months" (₺999/6ay)
   
   b) PLATINUM Paket:
      - Product ID: "dengim_platinum_1month" (₺449/ay)
      - Product ID: "dengim_platinum_3months" (₺1,099/3ay)
      - Product ID: "dengim_platinum_6months" (₺1,899/6ay)

3. KOD YAPISI:
   - lib/services/purchase_service.dart dosyası oluştur
   - Subscription state'ini yönetmek için Provider kullan
   - Auto-renewal subscription mantığı
   - Receipt validation (server-side Firebase Cloud Functions ile)
   
4. EKRANLAR:
   - Premium satın alma ekranı (lib/features/premium/premium_screen.dart)
   - "Gold" ve "Platinum" paketleri görsel olarak karşılaştırmalı göster
   - Her paketin özelliklerini bullet point ile listele
   - "İlk ay %50 indirim" promo banner'ı ekle
   
5. ÖZELLİK KILITLEME:
   - Feature flagging sistemi: lib/core/utils/feature_flags.dart
   - Kullanıcının subscription durumunu kontrol et
   - Premium olmayan kullanıcılara kilitli özelliklerde "Premium'a geç" butonu göster
   
6. RESTORE PURCHASE:
   - "Satın alımları geri yükle" butonu ekle
   - Kullanıcı hesap değiştirirse subscription'ı taşı

7. APP STORE CONNECT AYARLARI:
   - Gerekli tüm product ID'leri ve fiyatları ekle
   - Sandbox test için test account bilgileri ver
   - Screenshot'lar ve submission için gerekli metinleri hazırla

ÇIKTI BEKLENTİSİ:
- Tam çalışan IAP kodu
- Test edilebilir sandbox kurulumu
- Kullanıcı dostu satın alma akışı
- Hata yönetimi (network hatası, iptal edilme, vb.)
- Analytics entegrasyonu (satın alma eventleri)

ÖNEMLI NOTLAR:
- Türk Lirası (TRY) fiyatlandırma kullan
- Tüm metinler Türkçe olsun
- KVKK uyumlu gizlilik metni ekle
- Kullanıcıya subscription iptal etme linki göster
```

---

### PROMPT 2: Android Google Play Billing Entegrasyonu

```
DENGİM Flutter uygulaması için Google Play Billing Library v5+ entegrasyonunu yap:

MEVCUT DURUM:
- Flutter 3.24.5
- Firebase backend aktif
- iOS IAP'i tamamlandı (yukardaki prompt ile)

YAPILMASI GEREKENLER:

1. PAKET:
   - in_app_purchase paketinin Android kısmını aktif et
   - Google Play Billing Library 5.x entegrasyonu

2. PRODUCT TANIMLARI:
   iOS ile aynı product ID'leri kullan ama Google Play Console'da tanımla:
   - Base Plan: "dengim-gold-monthly" (₺249)
   - Base Plan: "dengim-platinum-monthly" (₺449)
   - Her biri için 1-3-6 aylık offer'lar oluştur

3. KOD PAYLAŞIMI:
   - lib/services/purchase_service.dart'ı hem iOS hem Android için çalıştır
   - Platform-specific konfigürasyon: Platform.isIOS / Platform.isAndroid
   
4. GOOGLE PLAY CONSOLE AYARLARI:
   - Subscription products oluştur
   - Base plan ve offers tanımla
   - License testing ekle (test email adresleri)
   - Sandbox test yap
   
5. ÖZEL AYARLAR:
   - ProGuard rules (obfuscation için)
   - Google Play Developer API key'i Cloud Functions'a ekle
   - Server-side receipt validation

6. DEFERRED BILLING:
   - Grace period (3 gün ödeme yapılmazsa)
   - Account hold (ödeme başarısız olursa)
   
ÇIKTI:
- Android'de çalışan IAP sistemi
- iOS ile aynı feature set
- Test edilmiş sandbox akışı
- Kullanıcıya subscription yönetim linki (Google Play Settings)
```

---

### PROMPT 3: Firebase Remote Config - Feature Flagging Sistemi

```
DENGİM uygulamasında kullanıcının üyelik durumuna göre özellikleri açıp kapatmak için Firebase Remote Config kullanarak feature flagging sistemi kur:

AMAÇ:
Kullanıcılar FREE/GOLD/PLATINUM üyelik seviyelerine göre farklı özellikler görsünler.

YAPILMASI GEREKENLER:

1. FIREBASE REMOTE CONFIG SETUP:
   - Firebase Console'da Remote Config aktif et
   - Aşağıdaki parametreleri oluştur:
   
   {
     "free_daily_swipe_limit": 25,
     "gold_daily_swipe_limit": 999999,
     "platinum_daily_swipe_limit": 999999,
     
     "free_super_likes_per_day": 0,
     "gold_super_likes_per_day": 5,
     "platinum_super_likes_per_day": 10,
     
     "free_voice_message_enabled": false,
     "gold_voice_message_enabled": true,
     "platinum_voice_message_enabled": true,
     
     "free_video_call_enabled": false,
     "gold_video_call_enabled": false,
     "platinum_video_call_enabled": true,
     
     "free_read_receipts_enabled": false,
     "gold_read_receipts_enabled": true,
     "platinum_read_receipts_enabled": true,
     
     "free_stories_enabled": false,
     "gold_stories_limit": 3,
     "platinum_stories_limit": 999999,
     
     "free_spaces_per_day": 1,
     "gold_spaces_limit": 999999,
     "platinum_spaces_limit": 999999,
     "platinum_can_create_spaces": true,
     
     "free_max_photos": 4,
     "gold_max_photos": 8,
     "platinum_max_photos": 12,
     
     "show_ads_to_free_users": true,
     "show_ads_to_gold_users": true,
     "show_ads_to_platinum_users": false
   }

2. FLUTTER KOD:
   - lib/core/services/feature_flag_service.dart oluştur
   - Firebase Remote Config SDK'sını entegre et
   - Kullanıcının subscription tier'ını Firestore'dan al
   - Dinamik olarak özellikleri aç/kapat

3. ÖZELLİK KONTROLÜ:
   Her özelliği kullanmadan önce kontrol:
   
   ```dart
   bool canSendVoiceMessage = await FeatureFlagService.isEnabled('voice_message');
   if (!canSendVoiceMessage) {
     // "Premium'a geç" modali göster
   }
   ```

4. PREMIUM UPGRADE MODAL:
   - lib/core/widgets/premium_required_modal.dart
   - Hangi özellik için premium gerekiyor göster
   - "Hemen Yükselt" butonu → Premium satın alma ekranına yönlendir
   - Özellikleri karşılaştırmalı listele

5. KULLANICI PROFİLİNDE TIER GÖSTER:
   - Firestore'da: users/{userId}/subscriptionTier: "free" | "gold" | "platinum"
   - Profilde rozet göster (Gold/Platinum badge)

ÇIKTI:
- Dinamik feature flagging
- A/B test yapabilme yeteneği (Remote Config ile)
- Kullanıcıya özelleştirilmiş deneyim
```

---

### PROMPT 4: Google AdMob Reklam Entegrasyonu

```
DENGİM uygulamasına Google AdMob reklam sistemi entegre et. Sadece FREE kullanıcılara reklam göster, GOLD ve PLATINUM kullanıcılar reklamsız deneyim yaşasın:

MEVCUT DURUM:
- Flutter 3.24.5
- Feature flagging sistemi mevcut
- Subscription sistemi çalışıyor

YAPILMASI GEREKENLER:

1. ADMOB SDK KURULUMU:
   - google_mobile_ads: ^4.0.0 paketini ekle
   - iOS: Info.plist'e GADApplicationIdentifier ekle
   - Android: AndroidManifest.xml'e AdMob App ID ekle

2. AD UNIT TANIMLARI:
   Hem iOS hem Android için ayrı Ad Unit ID'ler oluştur:
   
   a) Banner Ad (Alt kısımda küçük reklam):
      - iOS: ca-app-pub-XXXXX/BANNER_IOS
      - Android: ca-app-pub-XXXXX/BANNER_ANDROID
   
   b) Interstitial Ad (Tam ekran geçiş reklamı):
      - iOS: ca-app-pub-XXXXX/INTERSTITIAL_IOS
      - Android: ca-app-pub-XXXXX/INTERSTITIAL_ANDROID
   
   c) Rewarded Ad (Video izleyip bonus kazan):
      - iOS: ca-app-pub-XXXXX/REWARDED_IOS
      - Android: ca-app-pub-XXXXX/REWARDED_ANDROID
   
   d) Native Ad (İçeriğe entegre reklam):
      - iOS: ca-app-pub-XXXXX/NATIVE_IOS
      - Android: ca-app-pub-XXXXX/NATIVE_ANDROID

3. REKLAM YERLEŞİM STRATEJİSİ:

   a) BANNER AD:
      - Spaces odası girişinde alt banner
      - Profile list scrolling'de her 10 profilde 1 native ad
   
   b) INTERSTITIAL AD:
      - Günlük swipe limitine (25) ulaştıktan sonra göster
      - Message: "Günlük limitine ulaştın! Premium'a geç veya yarın tekrar dene"
      - Maksimum 1 interstitial / 15 dakika (kullanıcıyı rahatsız etme)
   
   c) REWARDED AD:
      - "5 ekstra swipe için reklam izle" butonu
      - İzledikten sonra 5 swipe hediye et
      - Günde maksimum 3 kez izlenebilir
   
   d) NATIVE AD:
      - Discover page'de profile kartları arasında (her 8-10 profilde 1)

4. KOD YAPISI:
   - lib/core/services/ad_service.dart oluştur
   - Singleton pattern kullan
   - Ad loading, showing, error handling
   - Analytics: Hangi reklam gösterildi, tıklandı mı?

5. KULLANICI KONTROLÜ:
   Reklamları göstermeden önce kontrol:
   
   ```dart
   bool shouldShowAds = await FeatureFlagService.shouldShowAds();
   if (shouldShowAds && userTier == 'free') {
     AdService.showBannerAd();
   }
   ```

6. GDPR/KVKK CONSENT:
   - google_mobile_ads paketinin consent management kullan
   - İlk açılışta: "Kişiselleştirilmiş reklamlar için izin verin"
   - Ayarlar'da: Reklam tercihlerini değiştir

7. TEST MODU:
   - Test Ad Unit ID'leri kullan
   - Debug mode'da gerçek reklamlar gösterme
   - Release'den önce gerçek Ad Unit ID'lere geç

REKLAM FREKANS LİMİTLERİ:
- Banner: Sürekli gösterilebilir (bottom sticky)
- Interstitial: Max 1 / 15 dakika
- Rewarded: Kullanıcı başlatır (unlimited)
- Native: Her 8-10 içerikte 1

ÇIKTI:
- Tam çalışan AdMob entegrasyonu
- FREE kullanıcılara reklam
- GOLD/PLATINUM reklamsız
- GDPR/KVKK uyumlu
- Analytics tracking
```

---

### PROMPT 5: Firebase Analytics - Gelir ve Kullanıcı Takibi

```
DENGİM uygulaması için detaylı Firebase Analytics kurulumu yap. Gelir (revenue), kullanıcı davranışları, retention ve conversion tracking:

AMAÇ:
Her şeyi ölçmek: Kaç kullanıcı kayıt oldu, kaçı premium aldı, reklam geliri ne, churn rate ne?

YAPILMASI GEREKENLER:

1. FIREBASE ANALYTICS SDK:
   - firebase_analytics: ^10.8.0 paketi ekle
   - iOS ve Android'de doğru konfigüre et

2. CUSTOM EVENTS TANIMLA:

   a) AUTHENTICATION EVENTS:
      - "user_signup" (method: email/google/apple)
      - "user_login"
      - "user_logout"
   
   b) PROFILE EVENTS:
      - "profile_created"
      - "profile_photo_uploaded" (photo_count: int)
      - "profile_verification_requested"
      - "profile_verification_approved"
   
   c) DISCOVERY & MATCHING:
      - "swipe_right" (target_user_id: string)
      - "swipe_left"
      - "super_like_sent"
      - "match_created" (match_id: string)
      - "swipe_limit_reached"
   
   d) MESSAGING:
      - "message_sent" (type: text/image/voice)
      - "voice_message_sent" (duration_seconds: int)
      - "video_call_started"
      - "video_call_ended" (duration_seconds: int)
   
   e) MONETIZATION EVENTS (ÖNEMLİ):
      - "view_premium_page" (from_source: string)
      - "premium_purchase_initiated" (tier: gold/platinum, duration: 1m/3m/6m)
      - "premium_purchase_completed" (tier, duration, price_tl: double)
      - "premium_purchase_failed" (reason: string)
      - "a_la_carte_purchase" (item: super_like/boost/spotlight, quantity: int, price_tl: double)
      - "subscription_renewed" (tier: string)
      - "subscription_cancelled" (tier: string, reason: string)
   
   f) AD EVENTS:
      - "ad_impression" (ad_type: banner/interstitial/rewarded/native, ad_network: admob)
      - "ad_clicked" (ad_type, ad_network)
      - "rewarded_ad_watched" (reward: extra_swipes)
   
   g) ENGAGEMENT:
      - "story_posted"
      - "story_viewed" (author_user_id: string)
      - "spaces_joined" (room_id: string)
      - "spaces_created" (room_name: string)
   
   h) RETENTION & CHURN:
      - "app_opened" (session_number: int)
      - "daily_return" (days_since_signup: int)
      - "user_inactive_7days"
      - "user_inactive_30days"

3. USER PROPERTIES:
   Kullanıcı özellikleri set et:
   - subscription_tier: "free" / "gold" / "platinum"
   - signup_date: timestamp
   - gender: "male" / "female" / "other"
   - age_group: "18-24" / "25-34" / "35-44" / "45+"
   - city: string
   - total_matches: int
   - total_messages_sent: int
   - is_verified: bool

4. REVENUE TRACKING:
   Firebase'in built-in revenue eventi kullan:
   
   ```dart
   await analytics.logPurchase(
     value: 249.0,
     currency: 'TRY',
     items: [
       AnalyticsEventItem(
         itemId: 'dengim_gold_1month',
         itemName: 'Gold 1 Aylık',
         itemCategory: 'subscription',
         price: 249.0,
       ),
     ],
   );
   ```

5. FUNNEL ANALYSIS:
   Premium satın alma hunisi:
   1. view_premium_page
   2. premium_purchase_initiated
   3. premium_purchase_completed
   
   → Her adımda kaç kullanıcı düştü? Conversion rate nedir?

6. COHORT ANALYSIS:
   - Kullanıcıları kayıt tarihine göre grupla
   - Her cohort'un retention'ını ölç (Day 1, 7, 30 retention)
   - Hangi cohort daha çok para harcıyor?

7. DASHBOARD:
   Firebase Console'da custom dashboards oluştur:
   - Daily Active Users (DAU)
   - Monthly Active Users (MAU)
   - DAU/MAU ratio
   - Total revenue (daily/weekly/monthly)
   - ARPU (Average Revenue Per User)
   - ARPPU (Average Revenue Per Paying User)
   - Conversion rate (Free → Paid)
   - Churn rate (Subscription iptal eden %)

8. BIGQUERY EXPORT (Opsiyonel):
   - Firebase Analytics verilerini BigQuery'ye export et
   - Daha derinlemesine SQL analizi yap
   - Custom reports oluştur

ÇIKTI:
- Her önemli aksiyon loglanıyor
- Revenue tracking doğru çalışıyor
- Firebase Console'da canlı dashboardlar
- Retention ve conversion metrikleri görülüyor
```

---

## 🟡 FAZ 2: ORTA ÖNCELİKLİ GELİŞTİRMELER (4-12 Hafta)

### PROMPT 6: Akıllı Eşleştirme Algoritması (AI/ML)

```
DENGİM uygulaması için kullanıcıların swipe davranışlarını öğrenen ve daha uyumlu eşleşmeler öneren akıllı bir algoritma geliştir:

MEVCUT DURUM:
- Şu anda basit location + age + gender filtrelemesi var
- Kullanıcı swipe yapıyor ama algoritma öğrenmiyor

HEDEF:
Her kullanıcıya, beğenme olasılığı yüksek profilleri göster. Netflix'in film önerisi gibi ama flört için.

YAPILMASI GEREKENLER:

1. VERİ TOPLAMA:
   Firestore'da her swipe'ı kaydet:
   
   Collection: user_swipes
   {
     user_id: "abc123",
     target_user_id: "xyz789",
     action: "like" / "pass",
     timestamp: timestamp,
     target_user_attributes: {
       age: 28,
       gender: "female",
       interests: ["yoga", "travel", "music"],
       education: "university",
       distance_km: 5.2
     }
   }

2. ÖZELLIK ÇIKARMA (Feature Engineering):
   Her profil için özellikler:
   - Demografik: yaş, cinsiyet, eğitim seviyesi, meslek
   - İlgi alanları: ortak ilgi alanı sayısı
   - Aktiflik: son giriş zamanı, günlük mesaj sayısı
   - Sosyal proof: kaç kişi beğendi, kaç eşleşmesi var
   - Fiziksel: mesafe (km), boy (opsiyonel)

3. COLLABORATIVE FILTERING:
   "Bu kullanıcıya benzer kullanıcılar hangi profilleri beğendi?"
   
   - User-based collaborative filtering kullan
   - Cosine similarity ile benzer kullanıcıları bul
   - Onların beğendiği ama henüz görmediği profilleri öner

4. CONTENT-BASED FILTERING:
   "Bu kullanıcı geçmişte hangi özelliklere sahip profilleri beğendi?"
   
   - Kullanıcının beğendiği profillerin özelliklerini analiz et
   - Benzer özelliklere sahip yeni profilleri öner

5. SKORU HESAPLAMA:
   Her profile bir "match score" ver (0-100):
   
   Score = 
     0.3 * (ortak ilgi alanı oranı) +
     0.2 * (yaş uyumu - yaş farkı ne kadar az o kadar yüksek) +
     0.15 * (mesafe uyumu - yakın olması +) +
     0.15 * (collaborative filtering score) +
     0.1 * (aktiflik skoru - aktif kullanıcılar +) +
     0.1 * (sosyal proof - popüler profiller +)

6. SKOR TABANLARI SIRALAMA:
   Discovery page'de profilleri score'a göre göster:
   - Yüksek skorlu profiller önce
   - Random element ekle (%20 - sürpriz için)
   - Aynı kişiyi 24 saat içinde tekrar gösterme

7. FEEDBACk LOOP:
   - Kullanıcı swipe yaptıkça algoritma öğrensin
   - Her 100 swipe'da bir modeli güncelle
   - A/B test: Algoritmalı vs random

8. BACKEND:
   - Firebase Cloud Functions ile score hesaplama
   - Scheduled function: Her gece tüm kullanıcılar için skorları güncelle
   - Cache: Firestore'da calculated_scores collection'ı

9. FRONTEND:
   - lib/features/discover/discovery_service.dart
   - Profilleri score'a göre getir ve göster
   - "Önerilenler" vs "Yakındakiler" sekmesi

10. A/B TEST:
    - %50 kullanıcıya algoritmalı göster
    - %50 kullanıcıya eski sistem (random)
    - Firebase Remote Config ile kontrol et
    - Hangi grup daha fazla eşleşiyor? Hangi grup daha mutlu?

BEKLENEN SONUÇ:
- %30-50 daha fazla mutual like (karşılıklı beğeni)
- Daha kaliteli eşleşmeler
- Kullanıcı memnuniyeti artışı
- Retention iyileşmesi
```

---

### PROMPT 7: Referral (Davet) Sistemi

```
DENGİM uygulaması için viral büyüme sağlayacak bir arkadaşını davet et (referral) sistemi oluştur:

AMAÇ:
Kullanıcılar arkadaşlarını davet etsin, hem davet eden hem de davet edilen ödül kazansın (örneğin 1 hafta ücretsiz premium).

YAPILMASI GEREKENLER:

1. REFERRAL CODE SİSTEMİ:
   - Her kullanıcıya unique referral code ata (örn: "BEDIR42XA")
   - Firestore'da sakla:
   
   users/{userId}/referralCode: "BEDIR42XA"
   users/{userId}/referredBy: "ALI123XX" (kim davet etti)
   users/{userId}/referralCount: 5 (kaç kişi davet etti)

2. DAVET AKIŞI:
   
   a) Davet Eden Kullanıcı:
      - Profil → "Arkadaşını Davet Et" butonu
      - Referral code ve paylaşım linki göster
      - Link: https://dengim.app/invite/BEDIR42XA
      - "Paylaş" butonu → WhatsApp, Instagram, SMS, Clipboard
   
   b) Davet Edilen Kullanıcı:
      - Link'e tıkladığında app açılır
      - Kayıt ekranında: "BEDIR42XA kodu ile davet edildiniz!"
      - Kayıt olduğunda otomatik referral code uygula

3. ÖDÜL SİSTEMİ:
   - Davet edilen: 7 gün ücretsiz Gold üyelik
   - Davet eden: Her başarılı davet için 7 gün Gold üyelik ekle
   - 5 kişi davet edene: 1 ay ücretsiz Platinum
   - 10 kişi davet edene: Lifetime badge "Top Referrer"

4. DEEP LINKING:
   - Branch.io veya Firebase Dynamic Links kullan
   - iOS App Store ve Google Play'e yönlendir
   - App yüklü değilse: Store'a yönlendir
   - App yüklüyse: Direkt app içinde aç

5. TRACKING:
   - Firestore'da referrals collection:
   
   {
     referrer_user_id: "abc123",
     referred_user_id: "xyz789",
     referral_code: "BEDIR42XA",
     status: "pending" / "completed" / "expired",
     created_at: timestamp,
     completed_at: timestamp,
     reward_given: true/false
   }

6. FIREBASE CLOUD FUNCTION:
   - Yeni kullanıcı kayıt olduğunda:
     * Referral code varsa doğrula
     * Davet edene ödül ver
     * Davet edilene ödül ver
     * Status'u "completed" yap
     * Analytics event logla

7. LEADerboard (Opsiyonel):
   - "En çok davet eden kullanıcılar"
   - Gamification: Top 10'a özel rozetler

8. EKRAN TASARIMI:
   - lib/features/referral/referral_screen.dart
   - Davet kodunu büyük göster
   - QR kod ile paylaşım (opsiyonel)
   - "5 arkadaşın daha davet et, Platinum kazan!" progress bar
   - Davet ettiğin kişilerin listesi

9. ANALYTİCS:
   - "referral_link_shared" event
   - "referral_signup_completed" event
   - Virality coefficient: Her kullanıcı ortalama kaç kişi davet ediyor?

BEKLENEN SONUÇ:
- Organik kullanıcı kazanımı (CAC = $0)
- Viral loop: 1 kullanıcı → 1.5 kullanıcı (K-factor > 1)
- %20-30 kayıtların referral'dan gelmesi
```

---

### PROMPT 8: Gamification - Achievement & Streak Sistemi

```
DENGİM uygulamasına engagement artırmak için oyunlaştırma (gamification) özellikleri ekle: Rozetler (achievements), günlük streak sistemi, görevler (challenges):

AMAÇ:
Kullanıcıları uygulamayı her gün açmaya ve aktif olmaya teşvik et. Snapchat'teki streak sistemi gibi.

YAPILMASI GEREKENLER:

1. STREAK SİSTEMİ:
   
   a) Login Streak (Günlük Giriş Serisi):
      - Her gün uygulamayı aç → streak artar
      - 1 gün atlarsan → streak sıfırlanır
      - UI: "🔥 12 günlük seri!"
      - Milestone ödüller:
        * 7 gün → 5 bonus super like
        * 14 gün → 1 gün ücretsiz Boost
        * 30 gün → 1 hafta Gold üyelik
        * 100 gün → Özel "Sadık Kullanıcı" rozeti
   
   b) Messaging Streak:
      - Eşleştiğin biriyle ardışık günler mesajlaş
      - UI: Match profili yanında "💬 5 gün"
   
   Firestore:
   users/{userId}/streaks: {
     login_streak: 12,
     login_streak_last_update: timestamp,
     messaging_streaks: {
       "match_id_1": 5,
       "match_id_2": 3
     }
   }

2. ACHIEVEMENT (BAŞARI) SİSTEMİ:
   
   Kategoriler:
   
   a) Profile Completion:
      - "İlk Adım" - Hesap oluştur
      - "Fotoğraf Sanatçısı" - 6+ fotoğraf ekle
      - "Detaylı Profil" - Bio ve tüm ilgi alanlarını doldur
      - "Doğrulanmış Kullanıcı" - Profile verification tamamla
   
   b) Social:
      - "İlk Eşleşme" - İlk match'ini yap
      - "Popüler" - 50 kişiden beğeni al
      - "Sosyal Kelebek" - 100 eşleşme yap
      - "Mesaj Makinesi" - 1000 mesaj gönder
   
   c) Daily Challenges:
      - "Günün Görevi: 10 kişi ile eşleş"
      - "Haftanın Görevi: 3 farklı kişiyle video call yap"
   
   d) Special:
      - "Erken Kuş" - İlk 1000 kullanıcıdan ol
      - "Beta Tester" - Beta programına katıl
   
   Her achievement:
   {
     id: "first_match",
     title: "İlk Eşleşme",
     description: "İlk match'ini yaptın!",
     icon: "🎉",
     rarity: "common" / "rare" / "epic" / "legendary",
     progress: 1,
     target: 1,
     unlocked: true,
     unlocked_at: timestamp,
     reward: {
       type: "super_likes",
       amount: 3
     }
   }

3. GÜNLÜK GÖREVLER (Daily Challenges):
   - Her gün sıfırlanır
   - 3 basit görev:
     * "5 profile swipe yap"
     * "1 mesaj gönder"
     * "Profilini güncelle"
   - Hepsini tamamla → Bonus ödül (super like, boost, vb.)

4. LEADERBOARD:
   - Bu hafta en çok eşleşen kullanıcılar
   - En yüksek streak'e sahip kullanıcılar
   - Opt-in olsun (isteyen katılsın)

5. BADGE SHOWCASE:
   - Kullanıcı profili → Achievement tab
   - Kazandığı rozetleri göster
   - Henüz kazanmadıkları gri/kilitli göster
   - "Bu rozeti kazanmak için 5 eşleşme daha yap!"

6. NOTIFICATION:
   - Streak'in bitmek üzere: "12 günlük serini kaybetme! Bugün giriş yap 🔥"
   - Achievement unlock: "Tebrikler! 'Popüler' rozetini kazandın! 🎉"
   - Daily challenge tamamlandı: "Günlük görevleri tamamladın! 3 Super Like kazandın ⭐"

7. KOD YAPISI:
   - lib/core/services/gamification_service.dart
   - lib/features/achievements/
     - achievements_screen.dart (rozet listesi)
     - daily_challenges_widget.dart (ana ekranda widget)
   - lib/core/models/achievement.dart
   - lib/core/models/streak.dart

8. ANALYTICS:
   - "achievement_unlocked" (achievement_id, rarity)
   - "streak_milestone_reached" (type: login/messaging, days: int)
   - "daily_challenge_completed" (challenge_id)

BEKLENEN SONUÇ:
- %40-60 daha yüksek daily retention
- Kullanıcılar her gün açıyor (streak kaybetmemek için)
- Daha fazla engagement
- Eğlenceli kullanıcı deneyimi
```

---

## 🟢 FAZ 3: UZUN VADELİ GELİŞTİRMELER (3-6 Ay)

### PROMPT 9: Admin Dashboard v2 - Gelişmiş Yönetim Paneli

```
DENGİM için web tabanlı, kapsamlı bir admin dashboard geliştir. Real-time analytics, kullanıcı yönetimi, content moderation, revenue tracking:

TEKNOLOJİ:
- Frontend: React veya Vue.js (tercihen Next.js)
- Backend: Firebase Admin SDK ile Cloud Functions
- Deploy: Vercel veya Firebase Hosting

ÖZELLİKLER:

1. DASHBOARD HOME:
   - KPI Cards (büyük sayılar):
     * Total Users
     * MAU (Monthly Active Users)
     * DAU (Daily Active Users)
     * Total Revenue (Bu ay)
     * Active Subscriptions (Gold + Platinum)
     * Ad Revenue (Bu ay)
   
   - Grafikler:
     * Günlük kayıt sayısı (line chart, son 30 gün)
     * Revenue trend (bar chart, son 12 ay)
     * Subscription distribution (pie chart: Free vs Gold vs Platinum)
     * DAU/MAU ratio (line chart)

2. KULLANICI YÖNETİMİ:
   - Kullanıcı listesi (paginated, searchable)
   - Filtreleme: Subscription tier, gender, age, location, signup date
   - Kullanıcı detayı:
     * Profil bilgileri
     * Subscription durumu
     * Mesaj geçmişi (özet)
     * Bayrak atılan (reported) içerikler
     * Analytics: Swipe count, match count, message count
   - İşlemler:
     * Kullanıcıyı ban et / unban
     * Subscription ver / iptal et (test için)
     * Profile verification onayla / reddet
     * Kullanıcıyı sil (KVKK right to be forgotten)

3. CONTENT MODERATION:
   - Bayrak atılan içerikler queue:
     * Raporlanan profiller
     * Raporlanan mesajlar
     * Raporlanan fotoğraflar
   - Moderasyon aksiyonları:
     * Approve (sorun yok)
     * Remove content (içeriği sil)
     * Warn user (kullanıcıya uyarı)
     * Ban user (kullanıcıyı yasakla)
   - Auto-moderation stats: AI kaç içerik filtreledi?

4. REVENUE ANALYTICS:
   - Gelir özeti:
     * MRR (Monthly Recurring Revenue)
     * ARR (Annual Recurring Revenue)
     * ARPU (Avg Revenue Per User)
     * ARPPU (Avg Revenue Per Paying User)
   - Subscription analytics:
     * Yeni subscription'lar (bugün/bu hafta/bu ay)
     * Churn rate (iptal oranı)
     * Renewal rate (yenileme oranı)
     * Most popular plan (en çok satılan paket)
   - Transaction log (tüm satın almalar)
   - Refund management (iade talepleri)

5. AD REVENUE TRACKING:
   - AdMob entegre et
   - CPM trends
   - Impression count
   - Click-through rate (CTR)
   - Estimated earnings (günlük/aylık)

6. MARKETING & GROWTH:
   - Referral analytics:
     * En çok davet eden kullanıcılar
     * Viral coefficient (K-factor)
     * Referral conversion rate
   - Campaign management:
     * Push notification gönder (segmented)
     * Email kampanyası (test için)
     * In-app banner yönetimi

7. A/B TEST YÖNETİMİ:
   - Firebase Remote Config'i yönet
   - A/B test sonuçları
   - Feature flag on/off

8. ANALYTICS DASHBOARDS:
   - User retention cohorts
   - Funnel analysis (signup → profile → swipe → match → message)
   - Session duration trends
   - Feature usage stats (video call, voice message, stories, spaces)

9. SYSTEM HEALTH:
   - Firebase Crashlytics özeti
   - Error logs
   - API response times
   - Database query performance

10. EXPORT & REPORTS:
    - Excel export (kullanıcı listesi, transactions)
    - PDF rapor (aylık executive summary)

GÜVENLİK:
- Firebase Authentication: Admin role kontrolü
- Firestore security rules: Admin-only collections
- Sadece özel email adreslerine erişim (@dengim.app)

ÇIKTI BEKLENTİSİ:
- Modern, responsive admin panel
- Real-time data
- Kolay kullanılabilir interface
- Tüm business metrikleri tek yerden görülebilir
```

---

### PROMPT 10: AI-Powered Content Moderation

```
DENGİM uygulaması için AI/ML kullanarak sahte profil, spam mesaj ve uygunsuz içerik tespiti yap:

AMAÇ:
Uygulama içinde güvenli ortam sağlamak, sahte profilleri engellemek, spam ve taciz içeriklerini otomatik filtrelemek.

YAPILMASI GEREKENLER:

1. SAHTE PROFİL TESPİTİ:
   
   Risk skorlama sistemi (0-100):
   - Profil fotoğrafı yok: +30 risk
   - Bio boş: +20 risk
   - 5 dakikada 50+ swipe: +40 risk
   - Aynı mesajı 10 farklı kişiye gönder: +50 risk
   - Email doğrulaması yok: +25 risk
   - Yeni hesap (<24 saat): +15 risk
   
   Risk > 70 → Otomatik temporary ban + admin review
   
   ML Model (Opsiyonel):
   - Kullanıcı davranış patterni öğren
   - Normal vs anormal davranış
   - Bot detection

2. FOTOĞRAF MODERASYONu:
   
   a) Google Cloud Vision API:
      - Safe Search Detection
      - Adult content: block
      - Violence: block
      - Racy content: review (manuel onay)
   
   b) Face Detection:
      - Profil fotoğrafında yüz var mı?
      - Birden fazla kişi var mı? (group photo warning)
      - Çocuk yüzü var mı? (auto-reject)
   
   c) Celebrity Detection:
      - Ünlü fotoğrafı kullanıyor mu?
      - Auto-flag + verification gerekli

   Firebase Cloud Function:
   ```
   exports.moderateUploadedImage = functions.storage.object().onFinalize(async (object) => {
     // Cloud Vision API çağır
     // Sonuca göre fotoğrafı approve/reject/flag
   });
   ```

3. MESAJ MODERASYONu (NLP):
   
   Yasaklı kelime listesi:
   - Spam: "Tıkla", "Kazanç", "Hemen", link'ler
   - Taciz: Cinsel içerik, tehdit, hakaret
   - Dolandırıcılık: "Bitcoin", "Yatırım", "Para gönder"
   
   a) Basit Keyword Filtering:
      - Mesaj gönderilmeden önce kontrol et
      - Yasaklı kelime varsa: "Bu mesaj gönderilemez. Lütfen içeriğinizi gözden geçirin."
   
   b) AI-Based (Gelişmiş):
      - Google Cloud Natural Language API
      - Sentiment analysis: Çok negatif/agresif mesaj?
      - Entity recognition: Link, telefon no, email algıla
   
   Firebase Cloud Function:
   ```
   exports.moderateMessage = functions.firestore.document('chats/{chatId}/messages/{messageId}')
     .onCreate(async (snap, context) => {
       const message = snap.data().text;
       // NLP API çağır veya keyword check
       // Spam/taciz ise: mesajı sil + kullanıcıyı flag'le
     });
   ```

4. OTOMATIK AKSIYON:
   - Low risk (score 30-50): Log'la, admin bildir
   - Medium risk (50-70): Kullanıcıya uyarı göster
   - High risk (70+): Temporary ban (24 saat) + admin review
   - Very high risk (90+): Permanent ban

5. KULLANICI RAPOR SİSTEMİ:
   - "Bu profili bildir" butonu
   - 8 kategori:
     * Sahte profil
     * Spam
     * Taciz
     * Uygunsuz fotoğraf
     * Dolandırıcılık
     * Çocuk istismarı (acil)
     * Diğer
   - 3+ rapor → Otomatik admin queue'ya düşsün
   - 10+ rapor → Temporary suspend

6. ADMIN MODERATION QUEUE:
   - Admin dashboard'da:
     * Flagged content listesi
     * AI risk skoru
     * Kullanıcı raporları
     * Moderator aksiyon: Approve / Remove / Ban

7. ANALYTICS:
   - Günlük kaç içerik flaglendi?
   - AI accuracy: Doğru tespitler vs yanlış pozitif
   - Admin workload: Kaç moderasyon kararı verildi?

8. PRIVACY:
   - Mesajlar end-to-end encrypted olmadığı için modere edilebilir
   - Gizlilik politikasında belirt: "Güvenlik için mesajlar analiz edilebilir"

BEKLENEN SONUÇ:
- %80-90 sahte profil otomatik engellenir
- Spam mesajlar delivery edilmeden filtrelenir
- Güvenli, temiz platform
- Admin workload azalır
```

---

## 📋 GENEL UYGULAMA NOTU

Bu promptları Antigravity'ye verirken:

1. **Tek tek verin:** Her prompt ayrı bir task olarak
2. **Öncelik sırasını takip edin:** FAZ 1 → FAZ 2 → FAZ 3
3. **Test ettirin:** Her özellik tamamlandığında test edilmeli
4. **Git commit:** Her büyük özellik için ayrı commit
5. **Dokümantasyon:** Antigravity'den kod yorumu ve README güncellemesi isteyin

Her prompt için Antigravity'ye şöyle başlayabilirsiniz:

```
"DENGİM flört uygulamamız için aşağıdaki görevi tamamla:

[PROMPT'U BURAYA YAPIŞTIRIN]

Önemli:
- Tüm kodlar Türkçe yorum satırları içersin
- Hata yönetimi ekle (try-catch)
- Firebase best practices kullan
- Analytics event'leri eklemeyi unutma
- Test edilebilir kod yaz
- README.md'ye eklenen özelliği dokümante et"
```

Başarılar! 🚀
