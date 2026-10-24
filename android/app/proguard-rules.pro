# Flutter rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.**  { *; }

# App entry point
-keep class id.raion.ubantu.MainActivity { *; }

# Flutter Play Core / Deferred Components
-dontwarn com.google.android.play.core.**
-dontwarn io.flutter.plugins.**
