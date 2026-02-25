# Flutter-specific ProGuard rules

# Keep Flutter wrapper classes
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# ============================================================
# ENUM KORUMASI (KRİTİK — Firestore crash'ini önler)
# R8, enum sınıflarının values() ve valueOf() metodlarını
# "kullanılmıyor" sanıp siliyor. Bu kural bunu engeller.
# ============================================================
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Tüm enum sınıflarını koru
-keepclassmembers class * extends java.lang.Enum {
    <fields>;
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# ============================================================
# FIREBASE / FIRESTORE KORUMASI
# ============================================================
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Firestore internal sınıfları
-keep class com.google.firebase.firestore.** { *; }
-keep class com.google.cloud.firestore.** { *; }

# Firebase Auth
-keep class com.google.firebase.auth.** { *; }

# Firebase Messaging (FCM)
-keep class com.google.firebase.messaging.** { *; }

# Firebase Remote Config
-keep class com.google.firebase.remoteconfig.** { *; }

# Firebase Analytics
-keep class com.google.firebase.analytics.** { *; }

# Firebase Storage
-keep class com.google.firebase.storage.** { *; }

# ============================================================
# PROTOBUF & gRPC (Firestore arka planda bunları kullanır)
# ============================================================
-keep class com.google.protobuf.** { *; }
-dontwarn com.google.protobuf.**

-keep class io.grpc.** { *; }
-dontwarn io.grpc.**

# ============================================================
# GOOGLE PLAY SERVICES
# ============================================================
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# ============================================================
# ANDROIDx
# ============================================================
# AndroidX Window extensions (provided by OEM, not bundled in app)
-dontwarn androidx.window.extensions.**
-dontwarn androidx.window.sidecar.**

# ============================================================
# DİĞERLERİ
# ============================================================
# Google Play Core (deferred components, splitinstall - provided by Play Store at runtime)
-dontwarn com.google.android.play.core.**

# Amazon Appstore SDK
-dontwarn com.amazon.**

# Agora RTC Engine
-keep class io.agora.** { *; }
-dontwarn io.agora.**

# Google Sign-In
-keep class com.google.android.gms.auth.** { *; }

# Prevent stripping of Serializable classes
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}
