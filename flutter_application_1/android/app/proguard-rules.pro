# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# Keep all native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep authentication classes
-keep class com.google.firebase.auth.** { *; }
-keep class com.google.android.gms.auth.** { *; }

# Keep Google Sign-In
-keep class com.google.android.gms.auth.api.signin.** { *; }
-keep class com.google.android.gms.common.** { *; }

# Keep Firestore
-keep class com.google.firebase.firestore.** { *; }
-keep class com.google.protobuf.** { *; }

# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.plugins.** { *; }

# Prevent obfuscation of Flutter channels
-keep class io.flutter.embedding.** { *; }
-keep @interface io.flutter.embedding.engine.plugins.FlutterPlugin { *; }

# Keep model classes (adjust package name if different)
-keep class com.example.flutter_application_1.** { *; }
