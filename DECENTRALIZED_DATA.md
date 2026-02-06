# DENGİM - Decentralized Veri Paylaşımı Planı

## 🎯 Mevcut Durum
Firebase Firestore kullanılıyor ancak:
- Kullanıcı kayıtları Firebase'de olması gerekiyor
- Görsel depolama için Cloudinary kullanılıyor
- Discovery ekranı Firestore'dan kullanıcı çekiyor

## 🚀 Alternatif: GitHub Tabanlı Demo Profiller

### Avantajlar
- Firebase hesabı olmadan demo profiller gösterilebilir
- Git push ile anında güncelleniyor
- Haritadaki "0 AKTİF" sorunu çözülür
- Yeni kullanıcılar için içerik dolu görünür

### Dezavantajlar
- Gerçek zamanlı etkileşim yok
- Matching/swiping takibi yapılamaz
- Sadece demo amaçlı kullanılabilir

---

## 📁 Önerilen Yapı

```
assets/
  demo_profiles/
    profiles.json       # Tüm demo profiller
    avatars/           # Profil fotoğrafları
      user1.jpg
      user2.jpg
      ...
```

### profiles.json Örneği
```json
{
  "version": "1.0",
  "profiles": [
    {
      "uid": "demo_001",
      "name": "Ayşe",
      "age": 24,
      "gender": "Kadın",
      "country": "İstanbul",
      "bio": "Sanat ve müzik tutkunu 🎨",
      "job": "Grafik Tasarımcı",
      "interests": ["Sanat", "Müzik", "Yoga"],
      "photoUrl": "assets/demo_profiles/avatars/user1.jpg",
      "isOnline": true,
      "latitude": 41.0082,
      "longitude": 28.9784
    },
    {
      "uid": "demo_002", 
      "name": "Mehmet",
      "age": 28,
      "gender": "Erkek",
      "country": "Ankara",
      "bio": "Tech lead by day, gamer by night 🎮",
      "job": "Yazılım Mühendisi",
      "interests": ["Teknoloji", "Gaming", "Fitness"],
      "photoUrl": "assets/demo_profiles/avatars/user2.jpg",
      "isOnline": false,
      "latitude": 39.9334,
      "longitude": 32.8597
    }
  ]
}
```

---

## 🔧 Implementasyon

### 1. Demo Profile Service Oluştur
```dart
class DemoProfileService {
  Future<List<UserProfile>> getDemoProfiles() async {
    final jsonString = await rootBundle.loadString('assets/demo_profiles/profiles.json');
    final Map<String, dynamic> data = json.decode(jsonString);
    
    return (data['profiles'] as List)
        .map((p) => UserProfile.fromDemoJson(p))
        .toList();
  }
}
```

### 2. Discovery Provider'ı Güncelle
```dart
Future<void> loadDiscoveryUsers() async {
  // 1. Önce gerçek kullanıcıları çek
  final realUsers = await _discoveryService.getUsersToMatch();
  
  // 2. Eğer az kullanıcı varsa, demo profilleri ekle
  if (realUsers.length < 5) {
    final demoUsers = await _demoService.getDemoProfiles();
    _users = [...realUsers, ...demoUsers];
  } else {
    _users = realUsers;
  }
  
  notifyListeners();
}
```

---

## ⚡ Hızlı Çözüm: JSON + Unsplash

Demo profiller için hazır görsel URL'leri kullanarak Firebase olmadan içerik gösterebiliriz:

```dart
final List<Map<String, dynamic>> demoProfiles = [
  {
    "name": "Zeynep",
    "age": 25,
    "photoUrl": "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=500",
    "isOnline": true,
  },
  // ... daha fazla
];
```

---

## 🎬 Uygulama Adımları

1. ✅ `assets/demo_profiles/` klasörü oluştur
2. ✅ `profiles.json` dosyası ekle
3. ✅ `DemoProfileService` servisini kodla
4. ✅ Discovery ve Map provider'larını güncelle
5. ✅ pubspec.yaml'a asset path ekle

---

## 💡 Sonuç

Bu yaklaşımla:
- Yeni kullanıcılar hemen içerik görür
- Firebase boş olsa bile uygulama dolu görünür
- Git push ile profiller güncellenebilir
- Production'da gerçek + demo karışımı gösterilebilir
