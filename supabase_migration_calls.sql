-- Create call_notifications table for managing call signaling
CREATE TABLE IF NOT EXISTS call_notifications (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  channel_id TEXT NOT NULL UNIQUE,
  caller_id UUID NOT NULL REFERENCES auth.users(id),
  receiver_id UUID NOT NULL REFERENCES auth.users(id),
  receiver_name TEXT NOT NULL,
  is_video BOOLEAN DEFAULT false,
  status TEXT DEFAULT 'ringing', -- ringing, accepted, rejected, ended, missed
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  ended_at TIMESTAMP WITH TIME ZONE
);

-- Update calls table to use TEXT for color instead of INTEGER
ALTER TABLE calls ALTER COLUMN color TYPE TEXT;

-- Create index for faster queries
CREATE INDEX IF NOT EXISTS idx_call_notifications_receiver ON call_notifications(receiver_id);
CREATE INDEX IF NOT EXISTS idx_call_notifications_caller ON call_notifications(caller_id);
CREATE INDEX IF NOT EXISTS idx_call_notifications_status ON call_notifications(status);

-- Enable Row Level Security
ALTER TABLE call_notifications ENABLE ROW LEVEL SECURITY;

-- Policy: Users can insert their own calls
CREATE POLICY "Users can create calls" ON call_notifications
  FOR INSERT
  WITH CHECK (auth.uid() = caller_id);

-- Policy: Users can view calls they're involved in
CREATE POLICY "Users can view their calls" ON call_notifications
  FOR SELECT
  USING (auth.uid() = caller_id OR auth.uid() = receiver_id);

-- Policy: Users can update calls they're involved in
CREATE POLICY "Users can update their calls" ON call_notifications
  FOR UPDATE
  USING (auth.uid() = caller_id OR auth.uid() = receiver_id);

-- Enable Realtime for call notifications
ALTER PUBLICATION supabase_realtime ADD TABLE call_notifications;
