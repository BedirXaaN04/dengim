# 🚀 Dengim - Google Play Store Lansman Yol Haritası

Bu yol haritası, uygulamanın Google Play Store'da yayınlanması ve ilk kullanıcılar için vaatlerin sorunsuz yerine getirilmesi amacıyla hazırlanmıştır. Gereksiz özellikler elenmiş, Claude Opus/Sonnet kotalarını verimli kullanmak için kritik adımlara odaklanılmıştır.

## 🎯 Öncelikli Hedef: Sorunsuz Bir MVP (Minimum Viable Product)
Uygulamanın mağazada onaylanması ve ilk izlenimin "Premium" olması için yapılması gerekenler.

### ✅ Tamamlanan Kritik İşler
- [x] **Git Entegrasyonu:** Kod tabanı güncellendi.
- [x] **Feature Flags:** Admin panelinden özellik açıp kapatma (VIP, Reklam, Kredi, **Harita**) altyapısı kuruldu.
- [x] **Harita Gizliliği:** Harita özelliği varsayılan olarak kapatıldı, Keşfet ekranına kullanıcılar arası **KM uzaklığı** eklendi.

---

### 🛠️ Kalan Kritik İşler (Sırasıyla)

#### 1. 🛡️ Güvenlik ve Mağaza Gereksinimleri (Play Store Onayı İçin Zorunlu)
*   **Hesap Silme (Delete Account):** Kullanıcının hesabını ve tüm verilerini kalıcı olarak silme butonu çalışıyor olmalı. (Apple ve Google zorunlu kılıyor).
*   **Şikayet ve Engelleme:** Bir kullanıcıyı şikayet etme ve engelleme mekanizmasının %100 çalıştığından emin olunmalı.
*   **Gizlilik Politikası ve EULA:** Uygulama içinde ve mağaza girişinde Gizlilik Politikası ve Kullanıcı Sözleşmesi linkleri erişilebilir olmalı.

#### 2. 💎 Gelir Modeli ve Satın Alma (Monetization)
*   **Premium Üyelik Akışı:** Kullanıcı paket satın almaya çalıştığında (RevenueCat veya IAP) akışın sorunsuz çalıştığını test etmeliyiz.
*   **Kredi Sistemi:** Kredi düşme ve yükleme işlemlerinin veritabanına doğru yansıdığını kontrol etmeliyiz.
*   **Reklamlar:** AdMob entegrasyonunun prodüksiyon ID'leri ile çalıştığını doğrulamalıyız. `ConfigService` üzerinden reklamların kapatılabilmesi harika bir özellik, bunu test edelim.

#### 3. 🚀 Performans ve UX (Premium His)
*   **Açılış Hızı (Cold Start):** Uygulamanın açılış süresini optimize etmeliyiz.
*   **Resim Ön Bellekleme:** `CachedNetworkImage` zaten kullanılıyor, ancak bellek yönetimini (cache size) kontrol etmeliyiz.
*   **Offline Mod:** İnternet koptuğunda uygulamanın çökmediğinden, zarif bir "Bağlantı Yok" uyarısı verdiğinden emin olmalıyız (Şu an bir Banner var, yeterli mi bakalım).

#### 4. 🔔 Bildirimler (Engagement)
*   **Push Bildirimleri:** Eşleşme olduğunda veya mesaj geldiğinde bildirimlerin düştüğünü test etmeliyiz. (FCM Token yönetimi).
*   **Bildirim İzinleri:** Android 13+ için bildirim izni isteme akışının doğru zamanda tetiklendiğinden emin olmalıyız.

---

### 📅 Sonraki Adımlar (Lansman Sonrası / V1.1)
*   **Harita Özelliği:** Kullanıcı tabanı oturduğunda admin panelinden açılacak.
*   **Detaylı Analitik:** Hangi kullanıcı ne kadar süre duruyor, nerede takılıyor analizi.
*   **Görüntülü/Sesli Arama:** Sunucu maliyetleri ve teknik karmaşıklık nedeniyle lansman sonrasına bırakılabilir veya sadece Platinum üyelere özel beta olarak sunulabilir.

## 💡 Claude Kapsamlı Kullanım Stratejisi
Kotayı verimli kullanmak için:
1.  **Tek Seferde Tam Çözüm:** "Şunu düzelt, şimdi bunu düzelt" yerine "Bu modülü baştan sona analiz et ve tüm eksikleri tek seferde gider" komutları vereceğiz.
2.  **Dosya Okuma Odaklı:** Kod yazdırmadan önce dosyaları okutup bağlamı tam yükleyeceğiz, böylece hatalı kod üretimi azalacak.
3.  **Küçük Adımlar:** Devasa dosyaları tek seferde değiştirmek yerine, fonksiyon fonksiyon ilerleyeceğiz.

Sıradaki komutun için hazırım kral! İstersen **1. Madde (Güvenlik ve Hesap Silme)** ile başlayalım.
