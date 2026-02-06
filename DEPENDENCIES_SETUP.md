# Add these dependencies to your pubspec.yaml

dependencies:
  flutter:
    sdk: flutter
  supabase_flutter: ^2.0.0
  provider: ^6.1.1
  flutter_app_badger: ^1.5.0
  flutter_local_notifications: ^16.3.0

# Android Configuration (android/app/src/main/AndroidManifest.xml)
# Add inside <manifest> tag:
# <uses-permission android:name="com.android.launcher.permission.INSTALL_SHORTCUT" />
# <uses-permission android:name="com.android.launcher.permission.UNINSTALL_SHORTCUT" />

# iOS Configuration (ios/Runner/Info.plist)
# Badge support is enabled by default on iOS

# For Android 13+ notification permissions, add in AndroidManifest.xml:
# <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
