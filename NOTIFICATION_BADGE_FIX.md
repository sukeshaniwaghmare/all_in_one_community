# Notification Badge Fix Guide

## समस्या (Problem)
App च्या icon वर message notification badge दिसत नाही.

## Solution Applied

### 1. Android Changes
✅ Added `showBadge: true` in notification settings
✅ Created notification channel with badge support
✅ Added `number` parameter for unread count

### 2. iOS Changes
✅ Added badge permissions in initialization
✅ Added `UIBackgroundModes` in Info.plist
✅ Added `presentBadge: true` in iOS notification settings

### 3. Code Updates
- `background_message_handler.dart` - Updated with badge support
- `notification_channel_config.dart` - New file for channel configuration
- `Info.plist` - Added background modes

## Testing Steps

### Android:
1. Uninstall the app completely
2. Reinstall and run: `flutter run`
3. Send a message from another user
4. Check app icon - badge should appear with count

### iOS:
1. Clean build: `flutter clean`
2. Run: `flutter run`
3. When prompted, allow notifications
4. Send a message
5. Badge should appear on app icon

## Important Notes

### For Android 8.0+:
- Notification channels are required
- Badge must be enabled in channel settings
- User can disable badges in system settings

### For iOS:
- Badge permission must be granted
- Background modes must be enabled
- Badge updates work even when app is closed

## Troubleshooting

### Badge not showing on Android?
1. Check notification channel settings:
   - Long press notification → Settings
   - Ensure "Show badge" is enabled

2. Check app settings:
   - Settings → Apps → Your App → Notifications
   - Enable "Allow notification dot"

3. Launcher support:
   - Some launchers don't support badges
   - Try on stock Android launcher

### Badge not showing on iOS?
1. Check permissions:
   - Settings → Your App → Notifications
   - Enable "Badges"

2. Reset badge manually:
   ```dart
   FlutterLocalNotificationsPlugin().resolvePlatformSpecificImplementation<
       IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(badge: true);
   ```

## Manual Badge Update

If you want to update badge without notification:

```dart
// Android
await FlutterLocalNotificationsPlugin().show(
  0,
  null,
  null,
  NotificationDetails(
    android: AndroidNotificationDetails(
      'chat_channel',
      'Chat Messages',
      number: unreadCount,
      onlyAlertOnce: true,
    ),
  ),
);

// iOS
await FlutterLocalNotificationsPlugin()
    .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
    ?.requestPermissions(badge: true);
```

## Files Modified
1. `lib/features/chat/data/services/background_message_handler.dart`
2. `lib/core/notification_channel_config.dart` (new)
3. `ios/Runner/Info.plist`

## Next Steps
1. Uninstall app
2. Run `flutter clean`
3. Run `flutter run`
4. Test notifications

Badge should now appear! 🎉
