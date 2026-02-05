# 🚀 DENGIM - Kapsamlı Geliştirme Planı

**Versiyon:** 2.0  
**Oluşturulma Tarihi:** 5 Şubat 2026  
**Mevcut Versiyon:** 1.0.0+1

---

## 📊 MEVCUT DURUM ANALİZİ

### ✅ Tamamlanmış Özellikler

| Modül | Özellik | Durum |
|-------|---------|-------|
| **Auth** | Google Sign-In | ✅ |
| **Auth** | Email/Password Kayıt & Giriş | ✅ |
| **Auth** | Şifre Sıfırlama | ✅ |
| **Auth** | Hesap Silme | ✅ |
| **Profil** | Profil Oluşturma | ✅ |
| **Profil** | Profil Düzenleme | ✅ |
| **Profil** | Çoklu Fotoğraf Yükleme | ✅ |
| **Keşfet** | Tinder-style Swipe Kartları | ✅ |
| **Keşfet** | Beğen/Beğenme/Süper Beğen | ✅ |
| **Keşfet** | Eşleşme Animasyonu | ✅ |
| **Keşfet** | Filtreleme (Yaş, Cinsiyet) | ✅ |
| **Stories** | 24 Saat Hikaye Paylaşımı | ✅ |
| **Stories** | Hikaye Görüntüleme | ✅ |
| **Stories** | Karşılıklı Eşleşme Görünürlüğü | ✅ |
| **Stories** | Premium/Verified Vitrin | ✅ |
| **Harita** | OpenStreetMap Entegrasyonu | ✅ |
| **Harita** | Yakındaki Kullanıcılar | ✅ |
| **Harita** | Konum Bazlı Keşif | ✅ |
| **Mesajlaşma** | Gerçek Zamanlı Chat | ✅ |
| **Mesajlaşma** | Okundu Bilgisi | ✅ |
| **Mesajlaşma** | Eşleşmeler Arası Sohbet | ✅ |
| **Beğeniler** | Eşleşmeler Listesi | ✅ |
| **Beğeniler** | Beğenenler (VIP/Premium) | ✅ |
| **Premium** | RevenueCat Entegrasyonu | ✅ |
| **Premium** | Premium Teklif Ekranı | ✅ |
| **Reklam** | Google AdMob Altyapısı | ✅ |
| **CI/CD** | GitHub Actions Deployment | ✅ |
| **UI/UX** | Dark Theme | ✅ |
| **UI/UX** | Glassmorphism Tasarım | ✅ |

### ⚠️ Eksik/Geliştirilmesi Gereken Alanlar

1. **Push Bildirimleri** - Firebase Cloud Messaging (FCM) entegrasyonu yok
2. **Video Mesaj** - Sadece metin mesajlaşma mevcut
3. **Sesli Mesaj** - Eksik
4. **Video Call** - Eksik
5. **Profil Doğrulama** - Selfie doğrulama sistemi yok
6. **Spam/Kötüye Kullanım Raporlama** - Eksik
7. **Engelleme Sistemi** - Eksik
8. **Offline Modu** - Sınırlı destek
9. **Dil Desteği** - Sadece Türkçe
10. **Analytics** - Firebase Analytics entegrasyonu yok

---

## 🎯 GELİŞTİRME PLANI - ÖNCELİK SIRASI

---

### 📌 PHASE 1: GÜVENLİK & TEMEL SOSYAL ÖZELLİKLER (Yüksek Öncelik)
**Tahmini Süre:** 3-5 gün

#### 1.1 Push Bildirimler (Firebase Cloud Messaging)
- [ ] FCM paketini ekle
- [ ] Token yönetimi (save/update)
- [ ] Bildirim türleri:
  - Yeni eşleşme
  - Yeni mesaj
  - Biri seni beğendi
  - Yeni hikaye
- [ ] Foreground/Background handling
- [ ] Bildirim tercihleri ekranı

**Dosyalar:**
```
lib/core/services/notification_service.dart
lib/core/providers/notification_provider.dart
lib/features/profile/notification_settings_screen.dart
```

#### 1.2 Engelleme Sistemi
- [ ] Kullanıcı engelleme fonksiyonu
- [ ] Engellenen kullanıcılar listesi
- [ ] Engellenen kullanıcıları keşiften ve sohbetten gizle
- [ ] Engellenmiş kullanıcılar yönetim ekranı

**Dosyalar:**
```
lib/features/auth/services/block_service.dart
lib/features/profile/blocked_users_screen.dart
```

#### 1.3 Raporlama Sistemi
- [ ] Rapor nedenleri (Spam, Sahte Profil, Uygunsuz İçerik, Taciz)
- [ ] Rapor gönderme işlevi
- [ ] Firebase'de rapor koleksiyonu
- [ ] Admin panel için rapor listesi (opsiyonel)

**Dosyalar:**
```
lib/features/auth/services/report_service.dart
lib/features/profile/widgets/report_dialog.dart
```

---

### 📌 PHASE 2: İLETİŞİM GELİŞTİRMELERİ (Orta-Yüksek Öncelik)
**Tahmini Süre:** 4-6 gün

#### 2.1 Fotoğraf Mesajı
- [ ] Galeri/Kameradan fotoğraf seçme
- [ ] Firebase Storage'a yükleme
- [ ] Sohbette fotoğraf görüntüleme
- [ ] Fotoğraf tam ekran görüntüleme

**Dosyalar:**
```
lib/features/chats/services/chat_service.dart (güncelle)
lib/features/chats/widgets/image_message_bubble.dart
lib/features/chats/widgets/image_viewer.dart
```

#### 2.2 Sesli Mesaj
- [ ] Ses kayıt özelliği
- [ ] Ses dosyası yükleme
- [ ] Ses oynatıcı widget'ı
- [ ] Dalga formu gösterimi

**Paketler:** `record`, `audioplayers`

**Dosyalar:**
```
lib/features/chats/widgets/voice_recorder.dart
lib/features/chats/widgets/voice_message_bubble.dart
```

#### 2.3 Mesaj Durumları
- [ ] Gönderildi / İletildi / Okundu ikonları
- [ ] Yazıyor... göstergesi
- [ ] Son görülme zamanı

**Dosyalar:**
```
lib/features/chats/models/chat_models.dart (güncelle)
lib/features/chats/widgets/typing_indicator.dart
```

#### 2.4 Emoji Picker & GIF Desteği
- [ ] Emoji picker entegrasyonu
- [ ] GIF arama ve gönderme (Giphy API)

**Paketler:** `emoji_picker_flutter`, `giphy_get`

---

### 📌 PHASE 3: DOĞRULAMA & GÜVENİLİRLİK (Orta Öncelik)
**Tahmini Süre:** 3-4 gün

#### 3.1 Profil Doğrulama (Selfie Verification)
- [ ] Belirli poz ile selfie çekme ekranı
- [ ] Profil fotoğrafı ile karşılaştırma (basit hash veya ML)
- [ ] Doğrulama durumu badge'i
- [ ] Manuel inceleme kuyruğu

**Dosyalar:**
```
lib/features/profile/verification_selfie_screen.dart
lib/features/auth/services/verification_service.dart
```

#### 3.2 Telefon Numarası Doğrulama
- [ ] SMS OTP gönderimi (Firebase Phone Auth)
- [ ] Telefon numarası ile hesap bağlama
- [ ] Telefon değiştirme akışı

---

### 📌 PHASE 4: PREMIUM & MONETİZASYON GELİŞTİRMELERİ (Orta Öncelik)
**Tahmini Süre:** 3-4 gün

#### 4.1 Super Like & Boost
- [ ] Super Like limiti (günlük)
- [ ] Boost özelliği (30 dakika öne çıkma)
- [ ] Boost sırasında gösterim artışı
- [ ] Premium için sınır kaldırma

**Dosyalar:**
```
lib/features/discover/services/boost_service.dart
lib/core/providers/boost_provider.dart
```

#### 4.2 Rewind (Geri Al)
- [ ] Son swipe'ı geri alma (Premium)
- [ ] Günlük limit (Free: 1, Premium: Sınırsız)

#### 4.3 Kredi Sistemi Geliştirmeleri
- [ ] Super Like için kredi harcama
- [ ] Boost için kredi harcama
- [ ] Kredi satın alma paketleri
- [ ] Kredi geçmişi

**Dosyalar:**
```
lib/features/payment/credit_packages_screen.dart
lib/features/payment/services/credit_service.dart
```

#### 4.4 Reklam Optimizasyonu
- [ ] Interstitial reklamlar (swipe arası)
- [ ] Rewarded ads (bedava kredi için)
- [ ] Banner reklam konumları
- [ ] Premium için reklamsız deneyim

---

### 📌 PHASE 5: SOSYAL & DISCOVERY GELİŞTİRMELERİ (Düşük-Orta Öncelik)
**Tahmini Süre:** 4-5 gün

#### 5.1 Gelişmiş Filtreleme
- [ ] Mesafe filtresi (km)
- [ ] İlgi alanlarına göre filtreleme
- [ ] Eğitim durumu filtresi
- [ ] Boy filtresi
- [ ] Burç filtresi

**Dosyalar:**
```
lib/features/discover/widgets/advanced_filter_sheet.dart
lib/features/discover/models/filter_model.dart
```

#### 5.2 Ortak İlgi Alanları Gösterimi
- [ ] Kart üzerinde ortak ilgi sayısı
- [ ] Ortak ilgi alanları listesi
- [ ] Uyum yüzdesi hesaplama

#### 5.3 İlk Mesaj Önerileri (Ice Breakers)
- [ ] Ortak ilgi alanlarına dayalı öneriler
- [ ] Hazır soru kartları
- [ ] One-tap mesaj gönderimi

**Dosyalar:**
```
lib/features/chats/widgets/ice_breaker_suggestions.dart
```

#### 5.4 Prompts (Hinge-style)
- [ ] Profilde soru-cevap bölümü
- [ ] Önceden tanımlı sorular listesi
- [ ] Cevaplara beğeni yapabilme

**Dosyalar:**
```
lib/features/profile/prompts_screen.dart
lib/features/auth/models/user_profile.dart (güncelle)
```

---

### 📌 PHASE 6: VIDEO & ADVANCED FEATURES (Düşük Öncelik)
**Tahmini Süre:** 5-7 gün

#### 6.1 Video Arama
- [ ] WebRTC entegrasyonu
- [ ] 1-1 video görüşme
- [ ] Görüşme kabul/reddet
- [ ] Mikrofon/Kamera toggle

**Paketler:** `flutter_webrtc`, `agora_rtc_engine` (alternatif)

**Dosyalar:**
```
lib/features/chats/video_call_screen.dart
lib/features/chats/services/video_call_service.dart
```

#### 6.2 Video Profil
- [ ] Profil videosu yükleme (max 30 sn)
- [ ] Video önizleme
- [ ] Kartlarda video oynatma

#### 6.3 Hikaye Geliştirmeleri
- [ ] Video hikaye desteği
- [ ] Hikaye yanıtlama
- [ ] Hikaye reaksiyonları
- [ ] Müzik ekleme

---

### 📌 PHASE 7: ANALİTİK & OPTİMİZASYON (Sürekli)
**Tahmini Süre:** 2-3 gün

#### 7.1 Firebase Analytics
- [ ] Event tracking
- [ ] User properties
- [ ] Funnel analizi
- [ ] A/B Testing entegrasyonu

**Dosyalar:**
```
lib/core/services/analytics_service.dart
```

#### 7.2 Performans Optimizasyonu
- [ ] Lazy loading iyileştirmeleri
- [ ] Image caching optimizasyonu
- [ ] Infinite scroll pagination
- [ ] Memory leak kontrolleri

#### 7.3 Crashlytics
- [ ] Firebase Crashlytics entegrasyonu
- [ ] Error boundary widget'ı
- [ ] Custom error reporting

---

### 📌 PHASE 8: LOKALIZASYON & ERIŞILEBILIRLIK (Opsiyonel)
**Tahmini Süre:** 3-4 gün

#### 8.1 Çoklu Dil Desteği
- [ ] flutter_localizations entegrasyonu
- [ ] Türkçe (varsayılan)
- [ ] İngilizce
- [ ] Arapça
- [ ] Dil seçim ekranı

**Dosyalar:**
```
lib/l10n/
  ├── app_tr.arb
  ├── app_en.arb
  └── app_ar.arb
```

#### 8.2 Erişilebilirlik
- [ ] Semantics label'lar
- [ ] Yüksek kontrast desteği
- [ ] Dinamik font boyutu

---

## 📋 HIZLI BAŞLANGIÇ ÖNERİSİ

Öncelik sırasına göre **ilk yapılması önerilen özellikler:**

### 🔴 Acil (Bu Hafta)
1. **Push Bildirimleri** - Kullanıcı etkileşimini artırır
2. **Engelleme Sistemi** - Güvenlik için kritik
3. **Raporlama Sistemi** - Platform sağlığı için gerekli

### 🟡 Önemli (Önümüzdeki 2 Hafta)
4. **Fotoğraf Mesajı** - Kullanıcı deneyimini zenginleştirir
5. **Yazıyor... Göstergesi** - Gerçek zamanlı iletişim hissi
6. **Gelişmiş Filtreleme** - Keşif kalitesini artırır

### 🟢 Sonraki Sprint
7. **Sesli Mesaj**
8. **Super Like & Boost**
9. **Profil Doğrulama**

---

## 🛠️ TEKNİK BORÇ & REFACTORING

1. **Deprecated API Uyarıları** - `withOpacity()` → `withValues()` geçişi
2. **Unused Imports** - Temizlik gerekli
3. **Test Coverage** - Unit ve widget testleri eksik
4. **Error Handling** - Global error boundary eklenmeli
5. **Code Documentation** - DartDoc eksik

---

## 📁 DOSYA YAPISI ÖNERİSİ (Güncellenmiş)

```
lib/
├── core/
│   ├── providers/
│   ├── services/
│   │   ├── notification_service.dart (yeni)
│   │   ├── analytics_service.dart (yeni)
│   │   └── crashlytics_service.dart (yeni)
│   ├── theme/
│   ├── utils/
│   └── widgets/
├── features/
│   ├── auth/
│   │   └── services/
│   │       ├── block_service.dart (yeni)
│   │       ├── report_service.dart (yeni)
│   │       └── verification_service.dart (yeni)
│   ├── chats/
│   │   ├── services/
│   │   │   └── video_call_service.dart (yeni)
│   │   └── widgets/
│   │       ├── voice_recorder.dart (yeni)
│   │       ├── voice_message_bubble.dart (yeni)
│   │       ├── image_message_bubble.dart (yeni)
│   │       └── typing_indicator.dart (yeni)
│   ├── discover/
│   │   └── services/
│   │       └── boost_service.dart (yeni)
│   ├── payment/
│   │   └── services/
│   │       └── credit_service.dart (yeni)
│   └── profile/
│       ├── blocked_users_screen.dart (yeni)
│       ├── notification_settings_screen.dart (yeni)
│       └── verification_selfie_screen.dart (yeni)
└── l10n/ (yeni)
```

---

## 📊 BAŞARI METRİKLERİ

| Metrik | Mevcut | Hedef |
|--------|--------|-------|
| DAU (Günlük Aktif Kullanıcı) | - | Ölçüm başlat |
| Swipe/Kullanıcı/Gün | - | 50+ |
| Mesaj/Eşleşme | - | 5+ |
| Premium Dönüşüm | - | %3-5 |
| Retention D1 | - | %40+ |
| Retention D7 | - | %20+ |

---

## 🎬 SONRAKI ADIM

**Hangi Phase ile başlamak istersiniz?**

1. **Phase 1** - Güvenlik & Push Bildirimler 🔒
2. **Phase 2** - İletişim Geliştirmeleri 💬
3. **Phase 3** - Doğrulama Sistemi ✅
4. **Phase 4** - Premium & Monetizasyon 💎
5. **Phase 5** - Sosyal Özellikler 🤝

Veya belirli bir özellik seçebilirsiniz (örn: "Push bildirimleri ile başla")
