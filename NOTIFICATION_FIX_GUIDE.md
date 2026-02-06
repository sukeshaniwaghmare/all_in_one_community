# Notification Setup Guide

## Problem: Notifications नाहीत येत

## Solution Steps:

### 1. FCM Server Key Setup (CRITICAL)
Supabase Dashboard मध्ये जा:
- Project Settings → Edge Functions → Secrets
- Add new secret:
  - Name: `FCM_SERVER_KEY`
  - Value: तुमची Firebase Server Key (Firebase Console → Project Settings → Cloud Messaging → Server Key)

### 2. Enable pg_net Extension
Supabase SQL Editor मध्ये run करा:
```sql
CREATE EXTENSION IF NOT EXISTS pg_net WITH SCHEMA extensions;
```

### 3. Create Trigger
`send_notification_trigger.sql` file चा content Supabase SQL Editor मध्ये run करा

### 4. Verify Setup
`debug_notifications.sql` file चा content run करून check करा:
- pg_net enabled आहे का?
- Trigger exists आहे का?
- FCM tokens saved आहेत का?

### 5. Redeploy Edge Function
Terminal मध्ये:
```bash
supabase functions deploy send-notification
```

### 6. Test
- App restart करा
- Message send करा
- Notification येईल

## Firebase Server Key कुठे मिळेल?
1. Firebase Console → https://console.firebase.google.com
2. तुमचा project select करा
3. Settings (⚙️) → Project Settings
4. Cloud Messaging tab
5. Server Key copy करा
