-- Debug: Check complete notification setup

-- 1. Check pg_net extension
SELECT * FROM pg_extension WHERE extname = 'pg_net';

-- 2. Check if trigger exists and is enabled
SELECT 
    t.tgname AS trigger_name,
    t.tgenabled AS enabled,
    p.proname AS function_name
FROM pg_trigger t
JOIN pg_proc p ON t.tgfoid = p.oid
WHERE t.tgname = 'on_message_send_notification';

-- 3. Check FCM tokens
SELECT id, full_name, 
       CASE WHEN fcm_token IS NULL THEN 'NO TOKEN' ELSE 'HAS TOKEN' END as token_status
FROM user_profiles;

-- 4. Check recent messages
SELECT id, sender_id, receiver_id, message, created_at 
FROM messages 
ORDER BY created_at DESC 
LIMIT 5;

-- 5. Test trigger manually (replace with actual IDs)
-- SELECT send_fcm_notification() FROM messages WHERE id = 'YOUR_MESSAGE_ID';
