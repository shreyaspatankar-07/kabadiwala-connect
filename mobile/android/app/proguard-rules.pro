# Flutter R8 ProGuard rules for Kabadiwala Connect
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# SQLite & Drift reflection / JNI rules
-keep class org.sqlite.** { *; }
-keepclassmembers class * extends com.google.protobuf.GeneratedMessageLite { <fields>; }

# Keep data models and serialization
-keepattributes *Annotation*, EnclosingMethod, Signature
-dontwarn javax.annotation.**

# -----------------------------------------------------------------------
# Google Play Core (split-install / deferred components)
# Flutter's engine references these classes for Play Store deferred
# component delivery, but they are NOT present in direct APK / sideload
# builds. Suppress all R8 missing-class errors for them.
# -----------------------------------------------------------------------
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**
-keep class com.google.android.play.core.splitcompat.** { *; }
-keep class com.google.android.play.core.splitinstall.** { *; }
-keep class com.google.android.play.core.tasks.** { *; }
