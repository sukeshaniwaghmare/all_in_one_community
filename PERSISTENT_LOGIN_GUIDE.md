# Supabase Persistent Login Implementation

## Overview
This implementation provides WhatsApp/Instagram-like persistent login behavior where users remain logged in even after closing and reopening the app.

## Key Components

### 1. Supabase Configuration (`lib/core/supabase_service.dart`)
```dart
authOptions: const FlutterAuthClientOptions(
  authFlowType: AuthFlowType.pkce,      // Secure auth flow
  autoRefreshToken: true,                // Auto-refresh expired tokens
  persistSession: true,                  // Persist session locally
)
```

**What this does:**
- `persistSession: true` - Saves session to device storage (shared_preferences)
- `autoRefreshToken: true` - Automatically refreshes access tokens before expiry
- `authFlowType: AuthFlowType.pkce` - Uses secure PKCE flow for authentication

### 2. Auth Wrapper (`lib/core/auth_wrapper.dart`)
Listens to auth state changes and automatically navigates users:
- **Logged in** → CommunitySelectionScreen
- **Logged out** → LoginScreen

Uses `StreamBuilder` with `onAuthStateChange` to react to:
- App startup (checks existing session)
- Login events
- Logout events
- Token refresh events

### 3. Updated Main App (`lib/main.dart`)
- Changed `home: const LoginScreen()` to `home: const AuthWrapper()`
- AuthWrapper now controls initial navigation based on session state

### 4. Updated Login Screen (`lib/features/auth/presentation/login_screen.dart`)
- Removed manual navigation after login
- AuthWrapper automatically handles navigation when auth state changes

## How It Works

### On App Startup:
1. Supabase initializes and checks for saved session in local storage
2. If valid session exists → User auto-logged in
3. AuthWrapper detects session → Navigates to CommunitySelectionScreen
4. If no session → Shows LoginScreen

### On Login:
1. User enters credentials
2. Supabase authenticates and saves session locally
3. AuthWrapper detects auth state change → Navigates to home

### On Logout:
1. Call `authProvider.logout()`
2. Supabase clears local session
3. AuthWrapper detects state change → Navigates to LoginScreen

### Token Refresh:
- Happens automatically in background
- No user interaction needed
- Session remains valid without re-login

## Common Mistakes to Avoid

### ❌ Mistake 1: Missing persistSession
```dart
// WRONG - Session won't persist
await Supabase.initialize(
  url: url,
  anonKey: key,
);
```

### ✅ Correct:
```dart
await Supabase.initialize(
  url: url,
  anonKey: key,
  authOptions: const FlutterAuthClientOptions(
    persistSession: true,
  ),
);
```

### ❌ Mistake 2: Manual Navigation After Login
```dart
// WRONG - Conflicts with AuthWrapper
if (authProvider.isLoggedIn) {
  Navigator.pushReplacement(context, ...);
}
```

### ✅ Correct:
Let AuthWrapper handle navigation automatically via auth state stream.

### ❌ Mistake 3: Not Using Auth State Stream
```dart
// WRONG - Only checks once at startup
final session = Supabase.instance.client.auth.currentSession;
```

### ✅ Correct:
```dart
// Listens to all auth changes
StreamBuilder<AuthState>(
  stream: Supabase.instance.client.auth.onAuthStateChange,
  ...
)
```

### ❌ Mistake 4: Clearing Session on App Close
Don't call `signOut()` in app lifecycle methods unless user explicitly logs out.

## Testing Checklist

- [ ] Login → Close app → Reopen → Should stay logged in
- [ ] Login → Wait 1 hour → App should still work (token refresh)
- [ ] Logout → Close app → Reopen → Should show login screen
- [ ] Login on Device A → Should NOT affect Device B (separate sessions)
- [ ] Clear app data → Should require login again

## Security Notes

- Sessions are stored securely using platform-specific secure storage
- Tokens are encrypted at rest
- PKCE flow prevents token interception
- Auto-refresh prevents expired token issues

## Logout Implementation

To properly logout from anywhere in your app:

```dart
// In any screen with access to AuthProvider
await context.read<AuthProvider>().logout();
// AuthWrapper will automatically navigate to LoginScreen
```

## Git Commit Message

```
feat: implement persistent login with Supabase

- Configure Supabase with session persistence and auto token refresh
- Add AuthWrapper to handle auth state changes and navigation
- Update main.dart to use AuthWrapper as initial route
- Remove manual navigation from login screen
- Enable PKCE auth flow for enhanced security

Users now remain logged in after app restart, similar to WhatsApp/Instagram.
Session automatically refreshes tokens in background.
```

## Additional Resources

- [Supabase Auth Documentation](https://supabase.com/docs/guides/auth)
- [Flutter Supabase Package](https://pub.dev/packages/supabase_flutter)
