# WhatsApp-like Unread Message Count Implementation Guide

## Overview
Complete implementation of unread message count with app icon badge for Flutter + Supabase chat app.

## 1. Database Setup

Run `supabase_schema.sql` in your Supabase SQL Editor to create:
- `messages` table with sender/receiver tracking
- `unread_counts` table for efficient count queries
- Automatic trigger to increment unread count on new messages
- Row Level Security policies

## 2. Architecture

### Backend (Supabase)
- Messages stored with `is_read` flag
- Separate `unread_counts` table for performance
- PostgreSQL trigger auto-increments count on INSERT
- Real-time subscriptions for instant updates

### Frontend (Flutter)
- `ChatService`: Handles all Supabase operations
- `UnreadCountProvider`: State management with Provider
- `BackgroundMessageHandler`: Handles background/killed state
- Automatic badge updates via `flutter_app_badger`

## 3. Key Features

### Real-time Updates
- Supabase real-time subscription listens to `unread_counts` table
- Badge updates instantly when new message arrives
- Works even when app is in background

### Badge Management
- Shows total unread count across all conversations
- Displays "99+" for counts > 99
- Auto-removes badge when count reaches 0
- Persists across app restarts

### Mark as Read
- Automatically triggered when chat screen opens
- Also triggered when app returns to foreground (if chat is open)
- Updates both `messages.is_read` and resets `unread_counts`

## 4. Usage

### Initialize in main.dart
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL',
    anonKey: 'YOUR_SUPABASE_ANON_KEY',
  );

  await BackgroundMessageHandler.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UnreadCountProvider()..initialize()),
      ],
      child: const MyApp(),
    ),
  );
}
```

### Display Badge in UI
```dart
Consumer<UnreadCountProvider>(
  builder: (context, provider, child) {
    return Badge(
      label: Text('${provider.totalUnreadCount}'),
      isLabelVisible: provider.totalUnreadCount > 0,
      child: Icon(Icons.chat),
    );
  },
)
```

### Open Chat Screen
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => ChatScreenUnread(
      otherUserId: 'user_id',
      otherUserName: 'John Doe',
    ),
  ),
);
// Unread count automatically resets when screen opens
```

## 5. Edge Cases Handled

### App in Background
- `BackgroundMessageHandler` listens to new messages
- Updates badge count automatically
- Shows local notification

### App Killed
- Supabase real-time connection re-establishes on app restart
- `UnreadCountProvider.initialize()` loads current count
- Badge restored to correct value

### Multiple Devices
- Each device maintains its own badge via real-time sync
- Marking as read on one device updates all devices

### Network Issues
- Supabase handles reconnection automatically
- Count re-syncs when connection restored

## 6. Performance Optimizations

- Separate `unread_counts` table avoids counting messages on every query
- Database trigger handles increment (no client-side logic needed)
- Real-time subscription only for current user's counts
- Efficient queries with proper indexes

## 7. Testing Checklist

- [ ] Send message from User A to User B
- [ ] Verify badge appears on User B's app icon
- [ ] Open chat on User B's device
- [ ] Verify badge disappears
- [ ] Test with app in background
- [ ] Test with app killed
- [ ] Test with multiple conversations
- [ ] Test badge count > 99
- [ ] Test network disconnection/reconnection

## 8. Customization

### Change Badge Color (Android)
Modify in `BackgroundMessageHandler`:
```dart
AndroidNotificationDetails(
  'chat_channel',
  'Chat Messages',
  color: Colors.green, // Your color
)
```

### Per-Conversation Unread Count
```dart
final count = await ChatService().getUnreadCountForSender(senderId);
```

### Custom Badge Widget
See `main_chat_example.dart` for in-app badge implementation.
