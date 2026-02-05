-- Add FCM token column to user_profiles table
ALTER TABLE user_profiles ADD COLUMN fcm_token TEXT;

-- Create function to send notification on new message
CREATE OR REPLACE FUNCTION notify_new_message()
RETURNS TRIGGER AS $$
BEGIN
  -- Call Edge Function to send FCM notification
  PERFORM
    net.http_post(
      url := 'https://your-project-ref.supabase.co/functions/v1/send-notification',
      headers := '{"Content-Type": "application/json", "Authorization": "Bearer ' || current_setting('app.jwt_token') || '"}'::jsonb,
      body := json_build_object(
        'message_id', NEW.id,
        'receiver_id', NEW.receiver_id,
        'sender_id', NEW.sender_id,
        'message', NEW.message
      )::jsonb
    );
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for new messages
CREATE TRIGGER on_message_created
  AFTER INSERT ON messages
  FOR EACH ROW
  EXECUTE FUNCTION notify_new_message();