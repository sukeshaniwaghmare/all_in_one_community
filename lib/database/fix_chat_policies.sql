-- Fix infinite recursion in chat_room_members policies
DROP POLICY IF EXISTS "Users can view their own room memberships" ON chat_room_members;
DROP POLICY IF EXISTS "Users can insert their own room memberships" ON chat_room_members;
DROP POLICY IF EXISTS "Users can update their own room memberships" ON chat_room_members;
DROP POLICY IF EXISTS "Users can delete their own room memberships" ON chat_room_members;

-- Create simple, non-recursive policies for chat_room_members
CREATE POLICY "Enable read access for authenticated users" ON chat_room_members
    FOR SELECT USING (auth.uid() IS NOT NULL);

CREATE POLICY "Enable insert for authenticated users" ON chat_room_members
    FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "Enable update for authenticated users" ON chat_room_members
    FOR UPDATE USING (auth.uid() IS NOT NULL);

CREATE POLICY "Enable delete for authenticated users" ON chat_room_members
    FOR DELETE USING (auth.uid() IS NOT NULL);

-- Fix chat_rooms policies
DROP POLICY IF EXISTS "Users can view rooms they are members of" ON chat_rooms;
CREATE POLICY "Enable read access for authenticated users" ON chat_rooms
    FOR SELECT USING (auth.uid() IS NOT NULL);

CREATE POLICY "Enable insert for authenticated users" ON chat_rooms
    FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "Enable update for authenticated users" ON chat_rooms
    FOR UPDATE USING (auth.uid() IS NOT NULL);

-- Fix messages policies
DROP POLICY IF EXISTS "Users can view messages in their rooms" ON messages;
CREATE POLICY "Enable read access for authenticated users" ON messages
    FOR SELECT USING (auth.uid() IS NOT NULL);

CREATE POLICY "Enable insert for authenticated users" ON messages
    FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "Enable update for authenticated users" ON messages
    FOR UPDATE USING (auth.uid() IS NOT NULL);

-- Create profiles table if it doesn't exist
CREATE TABLE IF NOT EXISTS profiles (
    id UUID REFERENCES auth.users ON DELETE CASCADE PRIMARY KEY,
    name TEXT,
    avatar_url TEXT,
    phone_number TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS on profiles
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Create profiles policies
CREATE POLICY "Enable read access for authenticated users" ON profiles
    FOR SELECT USING (auth.uid() IS NOT NULL);

CREATE POLICY "Enable insert for authenticated users" ON profiles
    FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "Enable update for own profile" ON profiles
    FOR UPDATE USING (auth.uid() = id);

-- Add foreign key relationship between messages and profiles (only if not exists)
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.table_constraints 
        WHERE constraint_name = 'messages_sender_id_fkey'
    ) THEN
        ALTER TABLE messages 
        ADD CONSTRAINT messages_sender_id_fkey 
        FOREIGN KEY (sender_id) REFERENCES profiles(id);
    END IF;
END $$;

-- Fix calls table policies
CREATE POLICY "Enable read access for own calls" ON calls
    FOR SELECT USING (auth.uid()::text = user_id);

CREATE POLICY "Enable insert for authenticated users" ON calls
    FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "Enable delete for own calls" ON calls
    FOR DELETE USING (auth.uid()::text = user_id);