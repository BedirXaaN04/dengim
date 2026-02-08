# 🗺️ DENGİM - API Anahtarları Adım Adım Alma Rehberi

**Oluşturma Tarihi:** 8 Şubat 2026  
**Tahmini Süre:** ~45 dakika (tüm kritik API'ler için)

---

# 🔴 ADIM 1: RevenueCat (Premium Abonelik Sistemi)
**Tahmini Süre:** 10 dakika  
**Maliyet:** Ücretsiz (aylık 10.000$ gelire kadar)

## Neden Önemli?
- Premium üyelik satışlarınızı yönetir
- Google Play ve App Store aboneliklerini tek yerden kontrol
- Otomatik yenileme, iptal, geri ödeme işlemleri
- Gelir analitikleri

## Adım Adım Yapılacaklar:

### 1.1 Hesap Oluşturma
1. Tarayıcınızda şu adrese gidin: **https://app.revenuecat.com/signup**
2. Aşağıdaki seçeneklerden biriyle kayıt olun:
   - **Google ile** (Önerilen - Firebase ile aynı hesap)
   - GitHub ile
   - E-posta ile
3. Kayıt formunu doldurun:
   - Company Name: `DENGİM` veya şirket adınız
   - Your Role: `Founder` veya `Developer`

### 1.2 Proje Oluşturma
1. Dashboard'a girdikten sonra **"Create New Project"** butonuna tıklayın
2. Proje bilgilerini girin:
   - **Project Name:** `DENGİM`
   - **Project Type:** `Mobile App`
3. **"Create Project"** butonuna tıklayın

### 1.3 Uygulama Ekleme
1. Sol menüden **"Apps"** sekmesine tıklayın
2. **"+ New"** butonuna tıklayın
3. Platform seçin: **Android** (Google Play)
4. Bilgileri doldurun:
   - **App Name:** `DENGİM Android`
   - **Package Name:** `com.dengim.app` (pubspec.yaml'daki ile aynı olmalı)
5. **"Add App"** butonuna tıklayın
6. iOS için aynı adımları tekrarlayın (ileride App Store'a çıkarken)

### 1.4 API Key'leri Alma
1. Sol menüden **"API Keys"** sekmesine tıklayın
2. Burada iki anahtar göreceksiniz:
   - **Public SDK Key** → Bu anahtarı mobil uygulamada kullanacak
   - **Secret API Key** → Bu anahtarı sadece backend/admin panelinde kullanacak

### 1.5 Bana Vereceğiniz Bilgiler:
```
REVENUECAT_PUBLIC_KEY = appl_XXXXXXXXXXXXXXXXXXXX
REVENUECAT_SECRET_KEY = sk_XXXXXXXXXXXXXXXXXXXX (opsiyonel)
```

### 📸 Ekran Görüntüsü Yardımı:
Dashboard'da şöyle görünecek:
```
┌─────────────────────────────────────────┐
│  RevenueCat Dashboard                   │
├─────────────────────────────────────────┤
│  Projects > DENGİM > API Keys           │
│                                         │
│  Public SDK Key (App)                   │
│  ┌─────────────────────────────────┐   │
│  │ appl_ABCdefGHI123456789...      │   │ ← BUNU KOPYALA
│  └─────────────────────────────────┘   │
│                                         │
│  Secret API Key (Server)                │
│  ┌─────────────────────────────────┐   │
│  │ sk_ABCdefGHI123456789...        │   │ ← BUNU KOPYALA
│  └─────────────────────────────────┘   │
└─────────────────────────────────────────┘
```

---

# 🔴 ADIM 2: Google AdMob (Reklam Gelirleri)
**Tahmini Süre:** 15 dakika  
**Maliyet:** Ücretsiz (Google reklamlardan pay alır)

## Neden Önemli?
- Non-premium kullanıcılara reklam gösterme
- Pasif gelir kaynağı
- Premium'a geçiş motivasyonu

## Adım Adım Yapılacaklar:

### 2.1 AdMob Hesabı Oluşturma
1. Tarayıcınızda şu adrese gidin: **https://admob.google.com/**
2. **"Başlayın"** veya **"Get Started"** butonuna tıklayın
3. Google hesabınızla giriş yapın (Firebase ile aynı hesabı kullanın)
4. Ülke ve saat dilimini seçin: **Türkiye**
5. Ödeme bilgilerini şimdilik atlayabilirsiniz (sonra eklersiniz)

### 2.2 Yeni Uygulama Ekleme
1. Sol menüden **"Uygulamalar"** → **"Uygulama Ekle"** tıklayın
2. Platform seçin: **Android**
3. Soru: "Uygulamanız yayınlandı mı?"
   - Yayınlandıysa: **"Evet"** → Google Play'de arayın
   - Yayınlanmadıysa: **"Hayır"** → Manuel ekleyin
4. Uygulama adı: `DENGİM`
5. **"Ekle"** butonuna tıklayın

### 2.3 App ID'yi Kaydetme
Uygulama ekledikten sonra size bir **App ID** verilecek:
```
ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX
```
**⚠️ Bu ID'yi hemen kaydedin!**

### 2.4 Reklam Birimleri Oluşturma

#### Banner Reklam (Ana sayfa alt kısmı için):
1. Uygulamanıza tıklayın
2. **"Reklam birimleri"** → **"Reklam birimi ekle"**
3. **"Banner"** seçin
4. Reklam birimi adı: `DENGİM_Banner_Bottom`
5. **"Reklam birimi oluştur"** tıklayın
6. Verilen **Ad Unit ID**'yi kaydedin

#### Interstitial Reklam (Swipe aralarında gösterilecek):
1. **"Reklam birimi ekle"** → **"Geçiş Reklamı (Interstitial)"**
2. Reklam birimi adı: `DENGİM_Interstitial_Swipe`
3. **"Reklam birimi oluştur"** tıklayın
4. Verilen **Ad Unit ID**'yi kaydedin

#### Rewarded Reklam (Ekstra beğeni hakkı için):
1. **"Reklam birimi ekle"** → **"Ödüllü"**
2. Reklam birimi adı: `DENGİM_Rewarded_ExtraLikes`
3. **"Reklam birimi oluştur"** tıklayın
4. Verilen **Ad Unit ID**'yi kaydedin

### 2.5 Bana Vereceğiniz Bilgiler:
```
# Android
ADMOB_APP_ID_ANDROID = ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX
ADMOB_BANNER_ID_ANDROID = ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX
ADMOB_INTERSTITIAL_ID_ANDROID = ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX
ADMOB_REWARDED_ID_ANDROID = ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX
```

### 📸 Ekran Görüntüsü Yardımı:
```
┌─────────────────────────────────────────────────┐
│  AdMob > Uygulamalar > DENGİM > Reklam Birimleri│
├─────────────────────────────────────────────────┤
│                                                 │
│  DENGİM_Banner_Bottom          Banner           │
│  ca-app-pub-123.../456...     ← BUNU KOPYALA   │
│                                                 │
│  DENGİM_Interstitial_Swipe     Interstitial    │
│  ca-app-pub-123.../789...     ← BUNU KOPYALA   │
│                                                 │
│  DENGİM_Rewarded_ExtraLikes    Rewarded        │
│  ca-app-pub-123.../012...     ← BUNU KOPYALA   │
│                                                 │
└─────────────────────────────────────────────────┘
```

---

# 🟠 ADIM 3: OneSignal (Push Bildirimleri)
**Tahmini Süre:** 10 dakika  
**Maliyet:** Ücretsiz (10.000 cihaza kadar)

## Neden Önemli?
- "Yeni eşleşmen var!" bildirimleri
- "Birisi seni beğendi!" bildirimleri
- Mesaj bildirimleri
- Admin panelinden toplu bildirim gönderme

## Adım Adım Yapılacaklar:

### 3.1 Hesap Oluşturma
1. Tarayıcınızda şu adrese gidin: **https://onesignal.com/**
2. **"Start for Free"** butonuna tıklayın
3. Google, GitHub veya e-posta ile kayıt olun
4. Hesap türü: **"Free"** seçin

### 3.2 Yeni App Oluşturma
1. Dashboard'da **"New App/Website"** butonuna tıklayın
2. App bilgilerini girin:
   - **App Name:** `DENGİM`
   - **Organization:** Yeni oluşturun veya mevcut seçin
3. **"Configure Your Platform"** adımında **"Google Android (FCM)"** seçin

### 3.3 Firebase ile Bağlantı (ÖNEMLİ!)
OneSignal, Firebase FCM üzerinden bildirim gönderir. Bağlantı için:

1. **Firebase Console**'a gidin: https://console.firebase.google.com/
2. DENGİM projenizi seçin
3. Sol menüden **⚙️ Proje Ayarları** → **"Cloud Messaging"** sekmesi
4. **"Cloud Messaging API (V1)"** bölümünden:
   - Eğer devre dışıysa **"Enable"** tıklayın
5. **"Service Account"** bölümünden:
   - **"Manage Service Accounts"** tıklayın
   - Firebase Admin SDK için bir JSON key indirin
   
   VEYA daha kolay yöntem:
   
5. **"Server Key"** ve **"Sender ID"**'yi kopyalayın
   - ⚠️ Yeni Firebase projelerde Server Key olmayabilir
   - Bu durumda Firebase Cloud Messaging API (V1) kullanılır

### 3.4 OneSignal'e Firebase Bilgilerini Girme
1. OneSignal'da **"Google Android (FCM)"** seçili iken
2. Firebase'den aldığınız bilgileri girin:
   - **Firebase Server Key** veya **Service Account JSON**
   - **Firebase Sender ID**
3. **"Save & Continue"** tıklayın

### 3.5 API Anahtarlarını Alma
1. Sol menüden **"Settings"** → **"Keys & IDs"** tıklayın
2. Burada göreceğiniz:
   - **OneSignal App ID** (bu uygulamada kullanılacak)
   - **REST API Key** (admin panelde kullanılacak)

### 3.6 Bana Vereceğiniz Bilgiler:
```
ONESIGNAL_APP_ID = xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
ONESIGNAL_REST_API_KEY = xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

### 📸 Ekran Görüntüsü Yardımı:
```
┌─────────────────────────────────────────────────┐
│  OneSignal > Settings > Keys & IDs              │
├─────────────────────────────────────────────────┤
│                                                 │
│  ONESIGNAL APP ID                               │
│  ┌─────────────────────────────────────────┐   │
│  │ a1b2c3d4-e5f6-7890-abcd-ef1234567890    │   │ ← BUNU KOPYALA
│  └─────────────────────────────────────────┘   │
│                                                 │
│  REST API KEY                                   │
│  ┌─────────────────────────────────────────┐   │
│  │ NjEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIz...     │   │ ← BUNU KOPYALA
│  └─────────────────────────────────────────┘   │
│                                                 │
└─────────────────────────────────────────────────┘
```

---

# 🟠 ADIM 4: Sightengine (Uygunsuz İçerik Engelleme)
**Tahmini Süre:** 5 dakika  
**Maliyet:** 500 görsel/ay ücretsiz, sonra $10/ay

## Neden Önemli?
- Çıplak/müstehcen fotoğrafları otomatik engelliyor
- Uygulama mağazalarından ban yememek için ŞART
- Sahte profil fotoğraflarını tespit ediyor
- Şiddet içeren görselleri filtreliyor

## Adım Adım Yapılacaklar:

### 4.1 Hesap Oluşturma
1. Tarayıcınızda şu adrese gidin: **https://sightengine.com/**
2. Sağ üstten **"Sign Up"** butonuna tıklayın
3. Kayıt formunu doldurun:
   - E-posta adresi
   - Şifre
   - Company: `DENGİM`
4. E-posta doğrulaması yapın

### 4.2 API Anahtarlarını Alma
1. Dashboard'a giriş yaptıktan sonra
2. Ana sayfada veya **"API Keys"** bölümünde göreceksiniz:
   - **API User** (sayısal bir ID)
   - **API Secret** (uzun bir string)

### 4.3 Bana Vereceğiniz Bilgiler:
```
SIGHTENGINE_API_USER = 123456789
SIGHTENGINE_API_SECRET = AbCdEfGhIjKlMnOpQrStUvWxYz123456
```

### 📸 Ekran Görüntüsü Yardımı:
```
┌─────────────────────────────────────────────────┐
│  Sightengine Dashboard                          │
├─────────────────────────────────────────────────┤
│                                                 │
│  Your API Credentials                           │
│                                                 │
│  API User                                       │
│  ┌─────────────────────────┐                   │
│  │ 123456789               │ ← BUNU KOPYALA    │
│  └─────────────────────────┘                   │
│                                                 │
│  API Secret                                     │
│  ┌─────────────────────────────────────────┐   │
│  │ AbCdEfGhIjKlMnOpQrStUvWxYz123456       │   │ ← BUNU KOPYALA
│  └─────────────────────────────────────────┘   │
│                                                 │
└─────────────────────────────────────────────────┘
```

---

# ✅ ÖZET: Toplanacak Bilgiler Listesi

Tüm adımları tamamladıktan sonra bana şu bilgileri verin:

```
# ========================================
# DENGİM API ANAHTARLARI
# ========================================

# 1. RevenueCat
REVENUECAT_PUBLIC_KEY = 
REVENUECAT_SECRET_KEY = 

# 2. AdMob (Android)
ADMOB_APP_ID_ANDROID = 
ADMOB_BANNER_ID_ANDROID = 
ADMOB_INTERSTITIAL_ID_ANDROID = 
ADMOB_REWARDED_ID_ANDROID = 

# 3. OneSignal
ONESIGNAL_APP_ID = 
ONESIGNAL_REST_API_KEY = 

# 4. Sightengine
SIGHTENGINE_API_USER = 
SIGHTENGINE_API_SECRET = 
```

---

# 🚀 Başlayalım!

**İlk adım olarak RevenueCat'e gidelim:**

👉 **https://app.revenuecat.com/signup**

Hesabı oluşturunca bana haber verin, adım adım ilerleyelim!
