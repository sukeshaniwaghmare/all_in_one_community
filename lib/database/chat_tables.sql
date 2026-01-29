-- Chat rooms table
CREATE TABLE IF NOT EXISTS chat_rooms (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  is_group BOOLEAN DEFAULT false,
  created_by UUID REFERENCES auth.users(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Chat room members table
CREATE TABLE IF NOT EXISTS chat_room_members (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  room_id UUID REFERENCES chat_rooms(id) ON DELETE CASCADE,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  is_admin BOOLEAN DEFAULT false,
  UNIQUE(room_id, user_id)
);

-- Messages table
CREATE TABLE IF NOT EXISTS messages (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  room_id UUID REFERENCES chat_rooms(id) ON DELETE CASCADE,
  sender_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  message_type TEXT DEFAULT 'text', -- text, image, file, etc.
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  is_deleted BOOLEAN DEFAULT false
);

-- Enable RLS
ALTER TABLE chat_rooms ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_room_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;

-- RLS Policies for chat_rooms
CREATE POLICY "Users can view rooms they are members of" ON chat_rooms
  FOR SELECT USING (
    id IN (
      SELECT room_id FROM chat_room_members 
      WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Users can create rooms" ON chat_rooms
  FOR INSERT WITH CHECK (auth.uid() = created_by);

-- RLS Policies for chat_room_members
CREATE POLICY "Users can view room members for rooms they belong to" ON chat_room_members
  FOR SELECT USING (
    room_id IN (
      SELECT room_id FROM chat_room_members 
      WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Room admins can add members" ON chat_room_members
  FOR INSERT WITH CHECK (
    room_id IN (
      SELECT room_id FROM chat_room_members 
      WHERE user_id = auth.uid() AND is_admin = true
    )
  );

-- RLS Policies for messages
CREATE POLICY "Users can view messages in rooms they belong to" ON messages
  FOR SELECT USING (
    room_id IN (
      SELECT room_id FROM chat_room_members 
      WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Users can send messages to rooms they belong to" ON messages
  FOR INSERT WITH CHECK (
    auth.uid() = sender_id AND
    room_id IN (
      SELECT room_id FROM chat_room_members 
      WHERE user_id = auth.uid()
    )
  );

-- Enable realtime
ALTER PUBLICATION supabase_realtime ADD TABLE messages;
ALTER PUBLICATION supabase_realtime ADD TABLE chat_rooms;
ALTER PUBLICATION supabase_realtime ADD TABLE chat_room_members;