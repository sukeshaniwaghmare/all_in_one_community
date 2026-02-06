-- Step 1: Enable pg_net extension
CREATE EXTENSION IF NOT EXISTS pg_net WITH SCHEMA extensions;

-- Step 2: Check if trigger exists
SELECT * FROM pg_trigger WHERE tgname = 'on_message_send_notification';

-- Step 3: Check if function exists
SELECT proname FROM pg_proc WHERE proname = 'send_fcm_notification';

-- If trigger doesn't exist, run send_notification_trigger.sql again
