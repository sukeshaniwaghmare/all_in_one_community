-- Enable pg_net extension first (run this in Supabase SQL Editor)
-- CREATE EXTENSION IF NOT EXISTS pg_net;

-- OR use this simpler approach without pg_net:
-- Just insert into a notifications queue table and let Edge Function poll it

CREATE TABLE IF NOT EXISTS notification_queue (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  sender_id uuid NOT NULL,
  receiver_id uuid NOT NULL,
  sender_name text,
  message text NOT NULL,
  created_at timestamptz DEFAULT now(),
  processed boolean DEFAULT false
);

-- Function to queue notification
CREATE OR REPLACE FUNCTION queue_notification()
RETURNS TRIGGER AS $$
DECLARE
  sender_name TEXT;
BEGIN
  SELECT full_name INTO sender_name
  FROM user_profiles
  WHERE id = NEW.sender_id;

  INSERT INTO notification_queue (sender_id, receiver_id, sender_name, message)
  VALUES (NEW.sender_id, NEW.receiver_id, sender_name, NEW.message);

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger
DROP TRIGGER IF EXISTS on_message_queue_notification ON messages;
CREATE TRIGGER on_message_queue_notification
AFTER INSERT ON messages
FOR EACH ROW
EXECUTE FUNCTION queue_notification();
