# Flutter-specific ProGuard rules

# Keep Flutter wrapper classes
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# AndroidX Window extensions (provided by OEM, not bundled in app)
-dontwarn androidx.window.extensions.**
-dontwarn androidx.window.sidecar.**

# Google Play Core (deferred components, splitinstall - provided by Play Store at runtime)
-dontwarn com.google.android.play.core.**

# Firebase
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Google Play Services
-dontwarn com.google.android.gms.**

# Amazon Appstore SDK
-dontwarn com.amazon.**
