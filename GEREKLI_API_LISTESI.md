# 🔑 DENGİM - Gerekli API Anahtarları ve Platform Listesi

**Oluşturma Tarihi:** 8 Şubat 2026  
**Toplam Maliyet Tahmini:** $0-50/ay (başlangıç için)

---

## 📋 Öncelik Sıralaması

| Öncelik | Servis | Amaç | Maliyet |
|:-------:|--------|------|---------|
| 🔴 1 | RevenueCat | Premium satışları, abonelik yönetimi | Ücretsiz (10K$ gelire kadar) |
| 🔴 2 | Google AdMob | Reklamlar (Premium olmayanlara) | Ücretsiz (gelir paylaşımlı) |
| 🟠 3 | OneSignal | Push bildirimleri | Ücretsiz (10K cihaza kadar) |
| 🟠 4 | Sightengine | Uygunsuz fotoğraf engelleme (NSFW) | $10/ay (5K görsel) |
| 🟡 5 | Google Gemini API | Profil içeriği analizi, chatbot | Ücretsiz (belirli limite kadar) |
| 🟡 6 | Perspective API | Toksik mesaj engelleme | Ücretsiz |
| 🟢 7 | Iyzico | Türkiye ödeme altyapısı (alternatif) | İşlem başına %2.79 |
| 🟢 8 | SendGrid/Mailgun | E-posta bildirimleri | Ücretsiz (günde 100 e-posta) |

---

## 🔴 KRİTİK - Hemen Alınması Gereken API'ler

### 1. RevenueCat (Premium Abonelik Yönetimi)
**Zaten pubspec.yaml'da mevcut:** `purchases_flutter: ^6.25.0`

**Neden Gerekli:**
- App Store ve Google Play abonelik yönetimi
- Otomatik yenileme işlemleri
- Gelir takibi ve analytics
- Cross-platform satın alma senkronizasyonu

**Nasıl Alınır:**
1. https://www.revenuecat.com/ adresine git
2. Ücretsiz hesap oluştur
3. Dashboard'da yeni proje oluştur
4. API Key'leri al:
   - **Public SDK Key** (uygulama için)
   - **Secret API Key** (sadece backend için, admin panelinde kullanılabilir)

**Verilecek Bilgiler:**
```
REVENUECAT_PUBLIC_KEY = [buraya yapıştır]
REVENUECAT_SECRET_KEY = [buraya yapıştır] (opsiyonel)
```

---

### 2. Google AdMob (Reklam Gelirleri)
**Zaten pubspec.yaml'da mevcut:** `google_mobile_ads: ^5.0.0`

**Neden Gerekli:**
- Non-premium kullanıcılara reklam gösterme
- Pasif gelir kaynağı
- Banner, Interstitial, Rewarded reklamlar

**Nasıl Alınır:**
1. https://admob.google.com/ adresine git
2. Google hesabınla giriş yap
3. Yeni uygulama ekle (Android + iOS)
4. Her reklam birimi için Ad Unit ID al

**Verilecek Bilgiler:**
```
# Android
ADMOB_APP_ID_ANDROID = ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX
ADMOB_BANNER_ID_ANDROID = ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX
ADMOB_INTERSTITIAL_ID_ANDROID = ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX

# iOS
ADMOB_APP_ID_IOS = ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX
ADMOB_BANNER_ID_IOS = ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX
ADMOB_INTERSTITIAL_ID_IOS = ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX
```

---

## 🟠 YÜKSEK ÖNCELİK - Bu Hafta İçinde Alınmalı

### 3. OneSignal (Push Bildirimleri)

**Neden Gerekli:**
- "Yeni eşleşme geldi!" bildirimleri
- Mesaj bildirimleri
- Kampanya/promosyon bildirimleri
- Segmentasyon desteği (premium, yeni üyeler, inaktif)

**Maliyet:** Ücretsiz (10,000 cihaza kadar)

**Nasıl Alınır:**
1. https://onesignal.com/ adresine git
2. Ücretsiz hesap oluştur
3. Yeni App oluştur
4. Android için Firebase Server Key'i bağla
5. iOS için Apple Push Certificate yükle

**Verilecek Bilgiler:**
```
ONESIGNAL_APP_ID = [buraya yapıştır]
ONESIGNAL_REST_API_KEY = [buraya yapıştır]
```

---

### 4. Sightengine (NSFW/Uygunsuz İçerik Engelleme)

**Neden Gerekli:**
- Yüklenen fotoğraflarda çıplaklık/şiddet tespiti
- Sahte profil fotoğrafı tespiti
- Ünlü/AI-generated yüz tespiti
- Uygulama mağazalarından ban yememek için şart!

**Maliyet:** 
- 500 görsel/ay: Ücretsiz
- 5,000 görsel/ay: $10/ay
- 25,000 görsel/ay: $20/ay

**Nasıl Alınır:**
1. https://sightengine.com/ adresine git
2. Hesap oluştur
3. Dashboard'dan API credentials al

**Verilecek Bilgiler:**
```
SIGHTENGINE_API_USER = [buraya yapıştır]
SIGHTENGINE_API_SECRET = [buraya yapıştır]
```

**Alternatifler:**
- Google Cloud Vision (SafeSearch) - Daha pahalı ama daha doğru
- Amazon Rekognition - AWS ekosistemindesiniz ise

---

## 🟡 ORTA ÖNCELİK - 1-2 Hafta İçinde

### 5. Google Gemini API (AI Özellikleri)

**Neden Gerekli:**
- Profil biyografisi analizi ve iyileştirme önerileri
- Şüpheli içerik/bot tespiti
- Akıllı mesaj önerileri
- Admin panel chatbot (desteğe yardımcı)

**Maliyet:** Ücretsiz tier mevcut (Gemini 1.5 Flash)

**Nasıl Alınır:**
1. https://aistudio.google.com/ adresine git
2. Google hesabıyla giriş yap
3. "Get API Key" butonuna tıkla
4. Yeni proje oluştur veya mevcut Firebase projenizi seçin

**Verilecek Bilgiler:**
```
GEMINI_API_KEY = [buraya yapıştır]
```

---

### 6. Perspective API (Toksik Mesaj Engelleme)

**Neden Gerekli:**
- Chat'te küfür/hakaret engelleme
- Tehdit içeren mesajları işaretleme
- Spam/reklam filtresi
- Kullanıcı güvenliği

**Maliyet:** Tamamen ücretsiz

**Nasıl Alınır:**
1. https://perspectiveapi.com/ adresine git
2. "Get Started" butonuna tıkla
3. Google Cloud projesi oluştur/seç
4. API'yi etkinleştir
5. API Key oluştur

**Verilecek Bilgiler:**
```
PERSPECTIVE_API_KEY = [buraya yapıştır]
```

---

## 🟢 DÜŞÜK ÖNCELİK - İleride Eklenebilir

### 7. Iyzico (Türkiye Ödeme Altyapısı)

**Neden Gerekli:**
- RevenueCat alternatifi veya tamamlayıcısı
- Web üzerinden ödeme için
- Türk kartlarıyla sorunsuz çalışır

**Maliyet:** İşlem başına %2.79 + 0.35₺

**Nasıl Alınır:**
1. https://www.iyzico.com/ adresine git
2. Merchant (işyeri) hesabı oluştur
3. Gerekli evrakları yükle (vergi levhası vs.)
4. Sandbox (test) API'leri hemen al
5. Production anahtarlar onay sonrası

**Verilecek Bilgiler:**
```
IYZICO_API_KEY = [buraya yapıştır]
IYZICO_SECRET_KEY = [buraya yapıştır]
IYZICO_BASE_URL = https://sandbox-api.iyzipay.com (test için)
```

---

### 8. SendGrid/Mailgun (E-posta Servisi)

**Neden Gerekli:**
- Hoş geldin e-postaları
- Şifre sıfırlama
- Eşleşme bildirimleri
- Haftalık özet e-postaları

**Maliyet:** Günde 100 e-posta ücretsiz (SendGrid)

**Nasıl Alınır (SendGrid):**
1. https://sendgrid.com/ adresine git
2. Ücretsiz hesap oluştur
3. Domain doğrulama yap
4. API Key oluştur

**Verilecek Bilgiler:**
```
SENDGRID_API_KEY = [buraya yapıştır]
SENDGRID_FROM_EMAIL = noreply@dengim.app
```

---

## 🔧 Zaten Yapılandırılmış Servisler

### Firebase (Mevcut ✅)
```
# Admin Panel
apiKey: AIzaSyAlCLMEbzY45Ff3Lrj22EspoyNO1O3qFfs

# Flutter App  
apiKey: AIzaSyCQRAqILl3fdNCwEvGAJeIzQ-XSfiyeVp8
```

Firebase şu servisleri kullanıyor:
- ✅ Authentication (E-posta, Google Sign-In)
- ✅ Firestore Database
- ✅ Storage (Fotoğraflar)
- ✅ Cloud Messaging (FCM) - OneSignal ile genişletilebilir
- ⏳ Cloud Functions (henüz kurulmamış)

---

## 📱 Opsiyonel / Gelişmiş Servisler

### Veriff veya Sumsub (KYC/Kimlik Doğrulama)
- Fiyat: $2-5 per verification
- Amaç: ID doğrulama, yaş kontrolü
- Ne zaman: Uygulamanız büyüdüğünde

### Stream Chat
- Fiyat: Ücretsiz tier mevcut
- Amaç: Profesyonel chat altyapısı
- Ne zaman: Kendi chat'iniz yetersiz kalırsa

### Algolia
- Fiyat: Ücretsiz tier mevcut
- Amaç: Gelişmiş kullanıcı arama
- Ne zaman: Kullanıcı sayısı 50K+ olduğunda

---

## 📋 API Key Toplama Formu

Aşağıdaki bilgileri topladıktan sonra bana verin, entegrasyonu yapayım:

```
# === KRİTİK (Hemen) ===

# RevenueCat
REVENUECAT_PUBLIC_KEY = 
REVENUECAT_SECRET_KEY = 

# AdMob (Android)
ADMOB_APP_ID_ANDROID = 
ADMOB_BANNER_ID_ANDROID = 
ADMOB_INTERSTITIAL_ID_ANDROID = 

# AdMob (iOS) - iOS yayını yapılacaksa
ADMOB_APP_ID_IOS = 
ADMOB_BANNER_ID_IOS = 
ADMOB_INTERSTITIAL_ID_IOS = 


# === YÜKSEK ÖNCELİK (Bu hafta) ===

# OneSignal
ONESIGNAL_APP_ID = 
ONESIGNAL_REST_API_KEY = 

# Sightengine
SIGHTENGINE_API_USER = 
SIGHTENGINE_API_SECRET = 


# === ORTA ÖNCELİK (1-2 hafta) ===

# Google Gemini
GEMINI_API_KEY = 

# Perspective API
PERSPECTIVE_API_KEY = 


# === DÜŞÜK ÖNCELİK (Sonra) ===

# Iyzico (Opsiyonel)
IYZICO_API_KEY = 
IYZICO_SECRET_KEY = 

# SendGrid (Opsiyonel)
SENDGRID_API_KEY = 
SENDGRID_FROM_EMAIL = 
```

---

## 🎯 Sonraki Adımlar

1. **Bugün:** RevenueCat ve AdMob hesaplarını oluştur
2. **Bu hafta:** OneSignal ve Sightengine ekle
3. **Gelecek hafta:** AI API'lerini entegre et
4. **Sonra:** E-posta ve ek ödeme seçenekleri

---

**Not:** API anahtarlarını asla GitHub'a pushlamayın! `.env` dosyası veya Firebase Remote Config kullanın.
