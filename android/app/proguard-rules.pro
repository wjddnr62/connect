## Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-dontwarn io.flutter.**
-keep class io.flutter.plugins.**  { *; }

-dontwarn java.nio.file.Files
-dontwarn java.nio.file.Path
-dontwarn java.nio.file.OpenOption
-dontwarn org.codehaus.mojo.animal_sniffer.IgnoreJRERequirement

## Tokbox
-keep class com.tokbox.** { *; }
-keep class com.opentok.** { *; }
-keep class org.webrtc.** { *; }

-dontwarn com.opentok.**
-dontwarn com.tokbox.**

## IAP
-keep class com.android.vending.billing.**
## AppsFlyer
-dontwarn com.android.installreferrer
-keep class com.appsflyer.** { *; }