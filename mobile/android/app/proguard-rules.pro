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
