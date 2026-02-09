# 💛 DENGİM - Türkiye'nin Premium Flört Uygulaması

![Flutter](https://img.shields.io/badge/Flutter-3.24.5-blue?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.0+-blue?logo=dart)
![Firebase](https://img.shields.io/badge/Firebase-Enabled-orange?logo=firebase)
![License](https://img.shields.io/badge/License-Proprietary-red)

Modern, kullanıcı dostu ve özellik bakımından zengin bir flört uygulaması. Gerçek zamanlı mesajlaşma, gelişmiş filtreleme, sesli mesajlar ve daha fazlası!

---

## ✨ Özellikler

### 🔥 Core Features
- ✅ **Authentication** - Email, Google Sign-In, Apple Sign-In
- ✅ **Profile Management** - Multi-photo, Bio, Interests, Verification badges
- ✅ **Discovery System** - Tinder-style swipe, Advanced filters, Search
- ✅ **Real-time Chat** - Text, Images, Voice messages, Reactions
- ✅ **Matches & Likes** - Real-time notifications
- ✅ **Stories** - 24-hour ephemeral content, Premium highlights

### 💬 Communication
- ✅ **Online Status Indicators** - Real-time presence
- ✅ **Typing Indicators** - Auto-detect with 5s timeout
- ✅ **Voice Messages** - Player with waveform visualization
- ✅ **Read Receipts** - ✓ Sent / ✓✓ Delivered / ✓✓ Read
- ✅ **Video Calls** - Agora WebRTC integration

### 🌍 Social & Discovery
- ✅ **Advanced Filters** - Age, Distance, Interests, Relationship goals
- ✅ **Map View** - Location-based nearby users with clustering
- ✅ **Spaces** - Voice chat rooms with moderation

### 🔒 Safety & Analytics
- ✅ **Report & Block System** - 8 report categories, safety analytics
- ✅ **User Activity Tracking** - Online status, engagement metrics

---

## 🛠️ Tech Stack

### Frontend
- **Flutter** 3.24.5
- **State Management:** Provider
- **UI Components:** Custom widgets, animations
- **Fonts:** Google Fonts (Plus Jakarta Sans, Poppins)
- **Images:** Cached Network Image
- **Audio:** just_audio

### Backend & Services
- **Authentication:** Firebase Auth
- **Database:** Cloud Firestore (real-time)
- **Storage:** Firebase Storage + Cloudinary
- **Notifications:** Firebase Cloud Messaging
- **Analytics:** Firebase Analytics
- **Crashlytics:** Firebase Crashlytics

### 3rd Party
- **Video Calls:** Agora SDK
- **Media Upload:** Cloudinary API
- **Maps:** Google Maps Flutter
- **Payments:** In-App Purchases (iOS/Android)

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.24.5 or higher
- Dart 3.0+
- Android Studio / Xcode
- Firebase account

### Installation

1. **Clone the repository:**
```bash
git clone https://github.com/BedirXaaN04/dengim.git
cd dengim
```

2. **Install dependencies:**
```bash
flutter pub get
```

3. **Setup Firebase:**
- Create a Firebase project
- Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
- Place them in respective directories
- Enable Authentication, Firestore, Storage, FCM

4. **Run the app:**
```bash
flutter run
```

---

## 📦 Build

### Debug Build
```bash
flutter build apk --debug
```

### Release Build
```bash
flutter build apk --release
flutter build ios --release
```

---

## 🏗️ Project Structure

```
lib/
├── core/                   # Core functionality
│   ├── providers/         # State management
│   ├── services/          # Business logic
│   ├── theme/             # App theme & colors
│   ├── utils/             # Helper functions
│   └── widgets/           # Reusable widgets
├── features/              # Feature modules
│   ├── auth/              # Authentication
│   ├── chats/             # Messaging
│   ├── discover/          # Discovery & matching
│   ├── likes/             # Likes & matches
│   ├── map/               # Location-based discovery
│   ├── profile/           # User profiles
│   ├── settings/          # App settings
│   ├── spaces/            # Voice chat rooms
│   └── stories/           # Story feature
└── main.dart              # App entry point
```

---

## 🎨 UI/UX

### Design System
- **Theme:** Modern dark mode (#0F172A base)
- **Primary Color:** Premium gold (#FFD700 → #FFA500)
- **Effects:** Glassmorphism, smooth animations
- **Typography:** Plus Jakarta Sans, Poppins
- **Components:** Custom buttons, cards, modals

### Accessibility
- Semantic labels
- High contrast colors
- Touch target sizes (min 44x44)
- Screen reader support

---

## 📊 Code Quality

### Analysis Results
- **Total Issues:** 82 (all minor)
- **Critical Errors:** 0
- **Warnings:** 15 (unused imports, cosmetic)
- **Info:** 67 (style suggestions)

### Best Practices
- ✅ Clean Architecture
- ✅ SOLID Principles
- ✅ Null Safety
- ✅ Memory Management
- ✅ Error Handling

---

## 🔐 Security

- End-to-end encryption (Firebase)
- Secure authentication
- Privacy settings
- GDPR/KVKK compliant
- Data encryption at rest
- Safe data handling

---

## 📝 Documentation

Detailed documentation available in:
- `MAJOR_GELISTIRMELER_RAPORU.md` - Feature specifications
- `FINAL_ENTEGRASYON_RAPORU_v3.md` - Integration details
- `GENEL_DURUM_RAPORU.md` - Project overview
- `DEPLOYMENT_RAPORU.md` - Deployment guide

---

## 🤝 Contributing

This is a proprietary project. For collaboration inquiries, please contact the repository owner.

---

## 📄 License

Copyright © 2026 DENGİM. All rights reserved.

---

## 👨‍💻 Developer

**Repository Owner:** [BedirXaaN04](https://github.com/BedirXaaN04)

---

## 📞 Support

For issues and questions:
- Open an issue on GitHub
- Contact: [support email]

---

## 🎉 Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend services
- Open source community for packages

---

**Made with 💛 in Turkey**

**DENGİM v3.0** - *Where connections happen!*
