# FCM Push Notifications Setup

## 1. Add Dependencies to pubspec.yaml

```yaml
dependencies:
  firebase_core: ^2.24.2
  firebase_messaging: ^14.7.9
  flutter_local_notifications: ^16.3.0
  supabase_flutter: ^2.0.0
```

## 2. Firebase Setup

### Android (android/app/build.gradle)
```gradle
dependencies {
    implementation platform('com.google.firebase:firebase-bom:32.7.0')
    implementation 'com.google.firebase:firebase-messaging'
}
```

### Add google-services.json
- Download from Firebase Console
- Place in `android/app/google-services.json`

### iOS (ios/Runner/AppDelegate.swift)
```swift
import Firebase
import FirebaseMessaging

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

### Add GoogleService-Info.plist
- Download from Firebase Console
- Place in `ios/Runner/GoogleService-Info.plist`

## 3. Update main.dart

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_messaging_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  
  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL',
    anonKey: 'YOUR_SUPABASE_ANON_KEY',
  );
  
  await NotificationService.initialize();
  
  runApp(MyApp());
}
```

## 4. Supabase Setup

### Run SQL Migration
```bash
psql -h your-db-host -U postgres -d postgres -f supabase/migrations/add_fcm_token.sql
```

### Deploy Edge Function
```bash
supabase functions deploy send-notification
```

### Set Environment Variables
```bash
supabase secrets set FCM_SERVER_KEY=your_fcm_server_key
```

Get FCM Server Key from Firebase Console > Project Settings > Cloud Messaging > Server Key

## 5. Handle Navigation in Chat List Screen

Update `chat_list_screen.dart`:

```dart
@override
void initState() {
  super.initState();
  
  // Set notification tap handler
  NotificationService.onChatTap = (chatId) {
    // Navigate to chat screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(chatId: chatId),
      ),
    );
  };
  
  // Existing code...
}
```

## 6. Test Notifications

1. Login on two devices
2. Send message from Device A
3. Device B should receive push notification
4. Tap notification to open chat

## Troubleshooting

- Ensure FCM token is saved in Supabase users table
- Check Edge Function logs: `supabase functions logs send-notification`
- Verify FCM Server Key is correct
- Test foreground, background, and terminated states