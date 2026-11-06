-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.**  { *; }
-keep class id.raion.ubantu.MainActivity { *; }
-dontwarn com.google.android.play.core.**
-dontwarn io.flutter.plugins.**
-dontwarn okhttp3.**
-dontwarn okio.**
-dontwarn javax.annotation.**
-repackageclasses
-allowaccessmodification
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
}
