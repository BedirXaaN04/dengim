# 🐛 DENGİM Uygulama Hata Raporu
**Tarih:** 2026-02-25  
**Analiz Yöntemi:** Web sürümü görsel test + Kaynak kod analizi  
**Toplam Tespit:** 14 hata (5 Kritik, 5 Orta, 4 Düşük)

---

## 🔴 KRİTİK HATALAR (Uygulama Kullanımını Engelliyor)

### BUG-001: Ayarlar Sayfası Tamamen Okunamıyor
- **Dosya:** `lib/features/profile/settings_screen.dart`
- **Sorun:** Tüm metin renkleri `Colors.white`, `Colors.white70`, `Colors.white24` olarak kodlanmış. Ancak scaffold arka planı `AppColors.scaffold` (`#F4F4F0` - krem rengi). Beyaz yazı, krem arka plan üzerinde görünmüyor.
- **Etkilenen Alanlar:**
  - AppBar başlığı "AYARLAR" → `Colors.white` (L48)
  - Geri butonu → `Colors.white` (L39)
  - Tüm menü öğeleri → `Colors.white`, `Colors.white70` (L323, L328)
  - Section header'lar → `AppColors.primary` (sarı) (L298) — bu görünür ama diğerleri yok
  - Trailing text'ler → `Colors.white30` (L335)
  - Ok ikonları → `Colors.white24` (L340)
  - Logout butonu → `Colors.white70` (L218)
  - Versiyon text → `Colors.white24` (L259)
- **Kök Neden:** Sayfa dark theme için tasarlanmış ama Neo-Brutalism light tema uygulanmış. Renkler güncellenmemiş.
- **Düzeltme:** Tüm `Colors.white*` referanslarını uygun koyu renklerle (`Colors.black`, `AppColors.textPrimary`, `AppColors.textSecondary`) değiştir. Container arka planlarını (`Colors.white.withOpacity(0.03)`) uygun açık renklere çevir.

### BUG-002: Dialog Renkleri Uyumsuz (Dark Theme Kalıntısı)
- **Dosya:** `lib/features/profile/settings_screen.dart`
- **Sorun:** AlertDialog'lar `backgroundColor: const Color(0xFF1F2937)` (koyu gri) kullanıyor (L386, L404, L478). Bu, Neo-Brutalism temasıyla tamamen uyumsuz.
- **Etkilenen Dialog'lar:**
  - _showInfoDialog (L382-398)
  - _showChangePasswordDialog (L400-442)
  - _showDeleteConfirmation (L474-521)
- **Düzeltme:** Dialog'ları `Colors.white` arka plan + siyah border Neo-Brutalism stiline çevir.

### BUG-003: Chats Screen Dialog Renkleri Uyumsuz
- **Dosya:** `lib/features/chats/chats_screen.dart`
- **Sorun:** Sohbet silme dialog'unda `AppColors.surface` (beyaz) arka plan kullanılıyor ama metin `Colors.white` (L55) ve `Colors.white70` (L58) — beyaz arka planda beyaz yazı görünmez.
- **Düzeltme:** Dialog metin renklerini `Colors.black` / `AppColors.textSecondary` yap.

### BUG-004: APK Build Crash (Beyaz Ekran)
- **Dosya:** `android/app/build.gradle.kts`
- **Sorun:** R8 minification agresif ProGuard kuralları (`proguard-android-optimize.txt`) ile uygulama runtime'da crash ediyor.
- **Durum:** Düzeltme push'landı ama henüz test edilmedi (optimize.txt kaldırıldı).
- **Düzeltme:** ✅ Yapıldı — sadece custom `proguard-rules.pro` kullanılıyor.

### BUG-005: PWA Manifest Geçersiz Renk Kodları
- **Dosya:** `web/manifest.json`
- **Sorun:** `background_color` ve `theme_color` değerleri `"#hex_code"` placeholder olarak bırakılmış (L6, L7). Bu, PWA kurulumunu ve web tarayıcı tema entegrasyonunu bozuyor.
- **Düzeltme:** `"#F4F4F0"` (scaffold) ve `"#FFD500"` (primary) olarak güncelle.

---

## 🟡 ORTA SEVİYE HATALAR (UX'i Olumsuz Etkiliyor)

### BUG-006: Web Wrapper Mavi Glow Efekti Tema ile Uyumsuz
- **Dosya:** `lib/core/widgets/responsive_center_wrapper.dart`
- **Sorun:** Web wrapper arka planı `Color(0xFF0F1115)` (koyu lacivert) (L16) ve `BoxShadow` `Colors.black.withOpacity(0.5)` kullanıyor. Neo-Brutalism teması siyah-beyaz-sarı ağırlıklı olmasına rağmen dış çerçeve eski koyu tema mantığında kalmış. Mavi parıltı efekti oluşuyor.
- **Düzeltme:** Arka plan rengini `Color(0xFF1A1A1A)` (saf siyah) veya `AppColors.scaffold` ile değiştir. Shadow'u Neo-Brutalism hard shadow (siyah, blurRadius: 0) ile değiştir.

### BUG-007: Passport/City Dialog Dark Theme Kalıntısı
- **Dosya:** `lib/features/profile/settings_screen.dart`
- **Sorun:** `_showPassportDialog()` (L558-605) ve `_buildCityItem()` (L607-628) dark theme renkleri kullanıyor:
  - Handle bar → `Colors.white24` (L572)
  - Başlık → `Colors.white` (L576)
  - Alt başlık → `Colors.white54` (L581)
  - Şehir item'ları → `Colors.white` text, `Colors.white10` border (L613, L617)
- **Düzeltme:** Tüm renkleri Neo-Brutalism paletine çevir.

### BUG-008: CORS Profil Resim Hataları
- **Sorun:** `ui-avatars.com` servisi birden fazla `Access-Control-Allow-Origin` header'ı döndürüyor, bu da CORS hatasına neden oluyor. Profil resimleri web'de yüklenemiyor.
- **Düzeltme:** DiceBear API veya doğrudan Firebase Storage kullanarak avatar'ları yönet. Alternatif olarak CORS proxy kullan.

### BUG-009: İki Ayrı Settings Sayfası Çakışması
- **Dosyalar:**
  - `lib/features/profile/settings_screen.dart` (630 satır, StatefulWidget)
  - `lib/features/settings/settings_screen.dart` (437 satır, StatelessWidget)
- **Sorun:** İki farklı Settings ekranı mevcut. Hangisinin kullanıldığı navigasyon akışına bağlı — bu tekrarlı kod ve karışıklık yaratıyor.
- **Düzeltme:** Birini kaldır ve tek bir Settings ekranı kullan.

### BUG-010: Bottom Navigation ile AppBar Tutarsızlığı
- **Sorun:** Keşfet ve Beğeniler sayfalarında AppBar beyaz arka planlı (Neo-Brutalism), Mesajlar sayfasında sarı header kullanılmış, Profil sayfasında ise farklı yapı var. Header standardı yok.
- **Düzeltme:** Tüm sayfalar için tutarlı AppBar bileşeni oluştur.

---

## 🟢 DÜŞÜK SEVİYE HATALAR (Kozmetik/İyileştirme)

### BUG-011: Profil Badge Padding Sorunu
- **Sorun:** Profil sayfasında doğrulama simgesi (mavi tik) ve "PLATINUM" rozeti kullanıcı adıyla iç içe girmiş. Yeterli padding/margin yok.
- **Düzeltme:** Badge widget'larına uygun spacing ekle.

### BUG-012: Sohbet Zaman Damgaları Düşük Kontrast
- **Sorun:** Mesaj listesindeki saat bilgileri çok küçük ve düşük kontrastlı gri ile yazılmış. Okunması zor.
- **Düzeltme:** Font size ve kontrast artır.

### BUG-013: Google Fonts Yükleme Uyarısı
- **Sorun:** Web'de "Noto fonts" eksikliği console uyarısı alınıyor. Bazı özel Türkçe karakterler düzgün render olmayabilir.
- **Düzeltme:** `GoogleFonts.config.allowRuntimeFetching` ayarını kontrol et veya fallback font ekle.

### BUG-014: Neo-Brutalism Border Tutarsızlığı
- **Sorun:** Bazı bileşenler 2px, bazıları 3px, bazıları 4px siyah border kullanıyor. Neo-Brutalism'de tutarlılık önemli.
- **Düzeltme:** Standart border width'i `AppColors` veya `AppTheme` içinde sabit olarak tanımla (örn. 3px).

---

## 📋 ÖNCELİKLİ DÜZELTME PLANI

### Faz 1: Kritik (Hemen) — ~2 saat
1. **BUG-001** → `profile/settings_screen.dart` renk migrasyonu
2. **BUG-002** → Dialog renklerini güncelle
3. **BUG-003** → Chat dialog renklerini güncelle
4. **BUG-005** → `manifest.json` placeholder fix

### Faz 2: Önemli (Kısa Vadede) — ~3 saat
5. **BUG-006** → Web wrapper arka plan/shadow güncelle
6. **BUG-007** → Passport dialog renklerini güncelle
7. **BUG-009** → Duplicate settings screen birleştir
8. **BUG-010** → Header standardizasyonu

### Faz 3: İyileştirme (Orta Vadede) — ~2 saat
9. **BUG-008** → CORS avatar çözümü
10. **BUG-011-014** → Kozmetik iyileştirmeler

### Genel Strateji:
Tüm ekranlarda Dark-Theme kalıntılarını tespit etmek için `grep -r "Colors.white" lib/features/` çalıştırılmalı ve her dosya tek tek Neo-Brutalism paletine migrate edilmeli.
