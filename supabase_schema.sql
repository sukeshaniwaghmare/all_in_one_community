-- Messages table
CREATE TABLE messages (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  sender_id UUID NOT NULL REFERENCES auth.users(id),
  receiver_id UUID NOT NULL REFERENCES auth.users(id),
  content TEXT NOT NULL,
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Unread counts table (for efficient querying)
CREATE TABLE unread_counts (
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

-- Trigger to auto-increment unread count
CREATE TRIGGER on_message_created
AFTER INSERT ON messages
FOR EACH ROW
EXECUTE FUNCTION increment_unread_count();

-- Enable Row Level Security
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE unread_counts ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Users can view their messages" ON messages
  FOR SELECT USING (auth.uid() = sender_id OR auth.uid() = receiver_id);

CREATE POLICY "Users can insert messages" ON messages
  FOR INSERT WITH CHECK (auth.uid() = sender_id);

CREATE POLICY "Users can view their unread counts" ON unread_counts
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can update their unread counts" ON unread_counts
  FOR UPDATE USING (auth.uid() = user_id);
