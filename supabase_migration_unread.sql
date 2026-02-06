-- Add columns to existing messages table
ALTER TABLE messages ADD COLUMN IF NOT EXISTS is_read BOOLEAN DEFAULT FALSE;

-- Create unread counts table
CREATE TABLE IF NOT EXISTS unread_counts (
  user_id UUID NOT NULL REFERENCES auth.users(id),
  sender_id UUID NOT NULL REFERENCES auth.users(id),
  unread_count INTEGER DEFAULT 0,
  last_message_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  PRIMARY KEY (user_id, sender_id)
);

-- Function to increment unread count
CREATE OR REPLACE FUNCTION increment_unread_count()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO unread_counts (user_id, sender_id, unread_count, last_message_at)
  VALUES (NEW.receiver_id, NEW.sender_id, 1, NEW.created_at)
  ON CONFLICT (user_id, sender_id)
  DO UPDATE SET 
    unread_count = unread_counts.unread_count + 1,
    last_message_at = NEW.created_at;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Drop trigger if exists and recreate
DROP TRIGGER IF EXISTS on_message_created ON messages;
CREATE TRIGGER on_message_created
AFTER INSERT ON messages
FOR EACH ROW
EXECUTE FUNCTION increment_unread_count();

-- Enable RLS on unread_counts
ALTER TABLE unread_counts ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Users can view their unread counts" ON unread_counts;
DROP POLICY IF EXISTS "Users can update their unread counts" ON unread_counts;

-- Create RLS policies
CREATE POLICY "Users can view their unread counts" ON unread_counts
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can update their unread counts" ON unread_counts
  FOR UPDATE USING (auth.uid() = user_id);
