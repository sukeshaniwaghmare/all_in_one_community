-- Function to call Edge Function for sending FCM notification
CREATE OR REPLACE FUNCTION send_fcm_notification()
RETURNS TRIGGER AS $$
DECLARE
  sender_name TEXT;
BEGIN
  -- Get sender name
  SELECT full_name INTO sender_name
  FROM user_profiles
  WHERE id = NEW.sender_id;

  -- Call Edge Function
  PERFORM
    net.http_post(
      url := 'https://vwzeusxxaajrbjnpjypb.supabase.co/functions/v1/send-notification',
      headers := jsonb_build_object(
        'Content-Type', 'application/json',
        'Authorization', 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZ3emV1c3h4YWFqcmJqbnBqeXBiIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2ODU0MjU2NCwiZXhwIjoyMDg0MTE4NTY0fQ.DvFXJ0ygRt9nZ9oKpe2GE1VEvMSFXEVeowl3aT45sC8'
      ),
      body := jsonb_build_object(
        'sender_id', NEW.sender_id,
        'receiver_id', NEW.receiver_id,
        'sender_name', sender_name,
        'message', NEW.message
      )
    );

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger
DROP TRIGGER IF EXISTS on_message_send_notification ON messages;
CREATE TRIGGER on_message_send_notification
AFTER INSERT ON messages
FOR EACH ROW
EXECUTE FUNCTION send_fcm_notification();
