# 🧹 DENGIM — Temizlik & Geliştirme Planı
> Tarih: 25 Şubat 2026

---

## BÖLÜM 1: SİLİNECEK / TEMİZLENECEK DOSYALAR

### 🔴 1.1 — Kök Dizindeki Gereksiz Dosyalar (Toplam ~1.2 MB metin)

Bu dosyalar geliştirme sürecinde üretilmiş raporlar ve log dosyaları. Uygulama tarafından hiçbir yerde referans edilmiyorlar:

| Dosya | Boyut | Sebep |
|-------|-------|-------|
| `ADMIN_PANEL_ANALIZ_RAPORU.md` | 10 KB | Eski analiz raporu |
| `ANALIZ_RAPORU.md` | 16 KB | Eski rapor |
| `API_ALMA_REHBERI.md` | 14 KB | Eski rehber |
| `BUG_REPORT.md` | 7 KB | Eski hata raporu |
| `CALISMAYAN_AKSAMLAR_RAPORU.md` | 6 KB | Eski rapor |
| `DECENTRALIZED_DATA.md` | 3 KB | Kullanılmayan doküman |
| `DEPLOY.md` | 1 KB | Eski dağıtım notları |
| `DEPLOYMENT_RAPORU.md` | 4 KB | Eski rapor |
| `ENTEGRASYON_RAPORU_v2.md` | 8 KB | Eski rapor |
| `FINAL_ENTEGRASYON_RAPORU_v3.md` | 13 KB | Eski rapor |
| `FINAL_GENEL_OZET.md` | 10 KB | Eski özet |
| `GELISTIRMELER_OZET.md` | 4 KB | Eski özet |
| `GENEL_DURUM_RAPORU.md` | 7 KB | Eski rapor |
| `GEREKLI_API_LISTESI.md` | 8 KB | Eski API listesi |
| `HATA_DUZELTME_RAPORU.md` | 2 KB | Eski hata raporu |
| `IYILESTIRME_RAPORU_09_02_2026.md` | 5 KB | Eski rapor |
| `MAJOR_GELISTIRMELER_RAPORU.md` | 10 KB | Eski rapor |
| `ROADMAP_FOR_LAUNCH.md` | 3 KB | Eski roadmap |
| `TAMAMLANAN_DUZELTMELER.md` | 5 KB | Eski rapor |
| `UYGULAMA_ANALIZ_RAPORU.md` | 10 KB | Eski rapor |
| `project_completion_report.md` | 2 KB | Eski rapor |
| `dengim_pazar_analizi_2026.md` | 28 KB | Pazar analizi (geliştirme ile ilgisiz) |
| `antigravity_prompt_dengim.md` | 32 KB | AI prompt dosyası |
| `analysis_output.txt` | 822 KB | Flutter analyze çıktısı |
| `analysis_report.txt` | 118 KB | Analiz raporu |
| `analysis_results.txt` | 28 KB | Analiz sonuçları |
| `analyze_output.txt` | 41 KB | Analiz çıktısı |
| `analyze_report.txt` | 38 KB | Analiz raporu |
| `analyze_report_2.txt` | 41 KB | Analiz raporu |
| `analyze_report_3.txt` | 29 KB | Analiz raporu |
| `build_errors.txt` | 1 KB | Build hataları |
| `build_log.txt` | 2 KB | Build logu |
| `build_log2.txt` | 1 KB | Build logu |
| `build_log3.txt` | 1 KB | Build logu |
| `build_log4.txt` | 8 KB | Build logu |
| `build_log5.txt` | 5 B | Boş build logu |
| `errors_only.txt` | 6 KB | Hatalar |
| `errors_only_3.txt` | 348 B | Hatalar |
| `extract_errors.py` | 270 B | Python script (kullanılmıyor) |
| `issues.txt` | 3 KB | Eski issue listesi |
| `results.txt` | 25 KB | Sonuçlar |

### 🔴 1.2 — Gereksiz Görsel Klasörleri

| Klasör | Dosya Sayısı | Sebep |
|--------|-------------|-------|
| `Admin panel görselleri/` | 25 dosya | Tasarım referansları, uygulama bunları kullanmıyor |
| `alternatif uygulama görselleri/` | 60+ dosya | Eski tasarım alternatifleri, uygulama bunları kullanmıyor |

### 🟡 1.3 — Kod İçinde Kullanılmayan Dart Dosyaları

| Dosya | Durum | Aksiyon |
|-------|-------|---------|
| `lib/core/utils/demo_profile_service.dart` | Import ediliyor (map_provider) ama **hiçbir yerde çağrılmıyor** | 🗑️ SİL + import'u kaldır |
| `lib/features/map/utils/map_style.dart` | **Google Maps** stili (uygulama OpenStreetMap kullanıyor) | 🗑️ SİL |
| `lib/features/ads/services/ad_service.dart.bak` | Backup dosyası, referans yok | 🗑️ SİL |
| `lib/core/widgets/connection_widgets.dart` | Hiçbir yerde import edilmiyor (widgets.dart barrel'dan export ediliyor ama barrel da import edilmiyor) | 🗑️ SİL |
| `lib/core/services/cache_service.dart` | Hiçbir yerde import edilmiyor (sadece barrel export) | 🗑️ SİL |
| `lib/core/services/achievement_service.dart` | Hiçbir yerde import edilmiyor | 🗑️ SİL |
| `lib/core/services/referral_service.dart` | Hiçbir yerde import edilmiyor | 🗑️ SİL |
| `lib/core/services/read_receipt_service.dart` | Hiçbir yerde import edilmiyor | 🗑️ SİL |
| `lib/core/services/user_activity_service.dart` | Hiçbir yerde import edilmiyor | 🗑️ SİL |
| `lib/features/profile/vip_screen.dart` | Hiçbir yerde referans edilmiyor | 🗑️ SİL |
| `lib/features/support/support_screen.dart` | Hiçbir yerde navigate edilemiyor | 🗑️ SİL (klasörüyle birlikte) |

### 🟡 1.4 — Temizlenecek Barrel Export Dosyaları

| Dosya | Aksiyon |
|-------|---------|
| `lib/core/services/services.dart` | cache_service export'unu kaldır |
| `lib/core/widgets/widgets.dart` | connection_widgets export'unu kaldır |

### 🟢 1.5 — Admin Panel Build Artifact'leri

| Dosya | Sebep |
|-------|-------|
| `dengim-admin/admin_build_output.txt` | Build logu |
| `dengim-admin/.next/` | Build cache (git'te olmamalı) |
| `dengim-admin/node_modules/` | npm paketleri (git'te olmamalı) |

---

## BÖLÜM 2: MEVCUT ÖZELLİK ANALİZİ

### 📱 2.1 — Aktif Özellikler ve Durumları

| # | Özellik | Dosyalar | Durum | Kalite |
|---|---------|----------|-------|--------|
| 1 | **Giriş/Kayıt** | `auth/login_screen.dart`, `register_screen.dart`, `verification_screen.dart` | ✅ Çalışıyor | ⭐⭐⭐⭐ |
| 2 | **Profil Oluşturma** | `create_profile/create_profile_screen.dart` | ✅ Çalışıyor | ⭐⭐⭐ |
| 3 | **Keşfet (Swipe)** | `discover/discover_screen.dart` (73 KB!) | ✅ Çalışıyor | ⭐⭐ (çok büyük dosya) |
| 4 | **Harita** | `map/map_screen.dart`, `map_provider.dart` | ✅ Çalışıyor | ⭐⭐⭐⭐ |
| 5 | **Mesajlaşma** | `chats/chats_screen.dart`, `chat_detail_screen.dart` | ✅ Çalışıyor | ⭐⭐⭐ |
| 6 | **Sesli Mesaj** | `chat_detail_screen.dart`, `voice_message_widget.dart` | ✅ Çalışıyor | ⭐⭐⭐ |
| 7 | **Görüntülü/Sesli Arama** | `call_screen.dart`, `agora_service.dart` | ⚠️ Agora bağımlı | ⭐⭐ |
| 8 | **Beğeniler** | `likes/likes_screen.dart` | ✅ Çalışıyor | ⭐⭐⭐ |
| 9 | **Profil Yönetimi** | `profile/profile_screen.dart`, `edit_profile_screen.dart` | ✅ Çalışıyor | ⭐⭐⭐ |
| 10 | **Ayarlar** | `profile/settings_screen.dart` | ✅ Çalışıyor | ⭐⭐⭐ |
| 11 | **Hikayeler (Stories)** | `discover/story_viewer_screen.dart`, `story_service.dart` | ✅ Çalışıyor | ⭐⭐⭐ |
| 12 | **Bildirimler** | `notifications/notifications_screen.dart` | ✅ Çalışıyor | ⭐⭐⭐ |
| 13 | **Spaces** | `spaces/` (tüm klasör) | ✅ Çalışıyor | ⭐⭐⭐ |
| 14 | **Premium/Ödeme** | `payment/premium_offer_screen.dart` | ✅ Çalışıyor | ⭐⭐⭐ |
| 15 | **Reklamlar** | `ads/watch_and_earn_screen.dart` | ✅ Çalışıyor | ⭐⭐⭐ |
| 16 | **Raporlama/Engelleme** | `report_dialog.dart`, `report_block_service.dart` | ✅ Çalışıyor | ⭐⭐⭐⭐ |
| 17 | **Doğrulama** | `profile/verification_screen.dart` | ✅ Çalışıyor | ⭐⭐⭐ |
| 18 | **Ziyaretçiler** | `profile/visitors_screen.dart` | ✅ Çalışıyor | ⭐⭐⭐ |
| 19 | **Engellenen Kullanıcılar** | `profile/blocked_users_screen.dart` | ✅ Çalışıyor | ⭐⭐⭐ |
| 20 | **Onboarding** | `onboarding/onboarding_screen.dart` | ✅ Çalışıyor | ⭐⭐⭐ |
| 21 | **Filtreler** | `discover/widgets/filter_bottom_sheet.dart`, `advanced_filters_modal.dart` | ✅ Çalışıyor | ⭐⭐⭐ |

---

## BÖLÜM 3: GELİŞTİRME PLANI

### 🚀 Öncelik 1 — Kritik İyileştirmeler

#### 3.1 `discover_screen.dart` Refactoring (73 KB → ~15-20 KB)
**Sorun:** Tek dosyada 73 KB kod, bakım ve debug imkansız.
**Plan:**
- `DiscoverScreen` → Ana koordinatör widget (max 300 satır)
- `widgets/swipe_card.dart` → Kart widget'ı
- `widgets/story_section.dart` → Hikaye bölümü
- `widgets/swipe_buttons.dart` → Beğeni/reddet butonları  
- `widgets/discover_header.dart` → Üst bar
- `services/swipe_logic.dart` → Swipe mantığı

#### 3.2 Chat Ekranı İyileştirmeleri
**Sorun:** `chat_detail_screen.dart` (34 KB) çok büyük.
**Plan:**
- Mesaj balonlarını ayrı widget'a çıkar
- Medya gönderimi widget'ını ayır
- Typing indicator'ı entegre ve test et

#### 3.3 Performans Optimizasyonu
- **Lazy loading** ekle: Discover'da kullanıcıları sayfalı yükle
- **Image caching** stratejisini gözden geçir
- **Provider rebuild** optimizasyonu (select kullanımı)

---

### 🎯 Öncelik 2 — Özellik Geliştirmeleri

#### 3.4 Keşfet Ekranı Geliştirmeleri
- [ ] **Super Like** animasyonu ve efektleri
- [ ] **Geri al (Undo)** özelliği (son swipe'ı geri al)
- [ ] **Boost** modu (profilinizi 30 dk öne çıkarın)
- [ ] **Swipe istatistikleri** (günlük kaç kişi gördünüz)
- [ ] **Akıllı öneriler** — `interestsWeight`, `locationWeight`, `activityWeight` parametrelerini kullan

#### 3.5 Mesajlaşma Geliştirmeleri
- [ ] **Okundu bilgisi** (read_receipt_service zaten var, entegre et)
- [ ] **Yazıyor...** göstergesi gerçek zamanlı çalışsın
- [ ] **GIF / Sticker** desteği
- [ ] **Mesaj silme/düzenleme**
- [ ] **Mesaj arama** fonksiyonu
- [ ] **Medya galerisi** (sohbetteki tüm medyalar)

#### 3.6 Profil Geliştirmeleri
- [ ] **Video tanıtım** ekleme (kısa video profil)
- [ ] **Spotify / Instagram** entegrasyonu
- [ ] **Profil tamamlama** yüzdesi göstergesi  
- [ ] **"Beni kim beğendi?"** premium özelliği
- [ ] **Profil rozeti sistemi** (doğrulanmış, premium, yeni üye)

#### 3.7 Harita Geliştirmeleri
- [ ] **Cluster markers** — çok fazla kullanıcı olduğunda grupla
- [ ] **Etkinlik pinleri** — yakındaki etkinlikleri göster
- [ ] **"Burada sık ziyaret ediyor"** bilgisi
- [ ] **Isı haritası** (heatmap) — yoğunluk gösterimi

#### 3.8 Hikaye (Stories) Geliştirmeleri
- [ ] **Video hikaye** desteği ekle
- [ ] **Hikayeye tepki** gönderme (emoji reaksiyonlar)
- [ ] **Hikaye highlights** (kalıcı hikayeler)
- [ ] **Müzik ekleme** desteği
- [ ] **Hikaye filtreleri** (metin, çizim, sticker)

---

### 💎 Öncelik 3 — Premium & Monetizasyon

#### 3.9 Premium Sistemi Geliştirmeleri
- [ ] **Tier karşılaştırma tablosu** güncelle (Gold vs Platinum)
- [ ] **Haftalık plan** seçeneği ekle
- [ ] **Ücretsiz deneme** (3 gün Gold)
- [ ] **Kredi sistemi** aktif et (credit_service mevcut, UI eksik)
- [ ] **Referral sistemi** aktif et (referral_service yazılmış ama bağlanmamış)

#### 3.10 Reklam Optimizasyonu
- [ ] **Ödüllü reklam** sonrasında süper beğeni kazandır
- [ ] **Banner reklam** pozisyonlarını optimize et
- [ ] **Premium'da reklam yok** garantisini doğrula

---

### 🔒 Öncelik 4 — Güvenlik & Kararlılık

#### 3.11 Güvenlik İyileştirmeleri
- [ ] **Rate limiting** — aşırı swipe/mesaj engelleme
- [ ] **İçerik moderasyonu** — AI tabanlı fotoğraf kontrolü
- [ ] **Fake profil tespiti** algoritması
- [ ] **İki faktörlü doğrulama** seçeneği

#### 3.12 Hata Yönetimi
- [ ] **Crashlytics** entegrasyonu
- [ ] **Retry mekanizması** — ağ hatalarında otomatik yeniden deneme
- [ ] **Graceful degradation** — özellik kapalıyken bilgilendirme

---

## BÖLÜM 4: TEMİZLİK İŞLEM SIRASI

Aşağıdaki sırayla temizlik yapılacak:

1. ✅ Kök dizindeki rapor/log dosyalarını sil
2. ✅ Görsel klasörlerini sil
3. ✅ Kullanılmayan Dart dosyalarını sil
4. ✅ İlgili import satırlarını temizle
5. ✅ Barrel export dosyalarını güncelle
6. ✅ `flutter analyze` çalıştır — hata olmadığını doğrula
7. ✅ Build test — APK build edilebilir mi kontrol et

---

## BÖLÜM 5: DOSYA BOYUTU ÖZETİ

### Şu Anki Durum:
- Kök dizindeki gereksiz dosyalar: **~1.2 MB**
- Görsel klasörleri: **~85+ dosya** (tahminî 50+ MB)
- Kullanılmayan Dart dosyaları: **11 dosya, ~60 KB**
- **Toplam temizlenecek:** ~50+ MB alan + 11 gereksiz Dart dosyası

### Temizlik Sonrası:
- Daha temiz proje yapısı
- Daha hızlı git operasyonları
- Daha net kod navigasyonu
- Sıfır "dead code"
