-- RLS Policies for Messages Table

-- Enable RLS
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;

-- Policy: Users can view their own messages (sent or received)
CREATE POLICY "Users can view their messages" ON messages
    FOR SELECT USING (
        auth.uid() = sender_id OR auth.uid() = receiver_id
    );

-- Policy: Users can insert their own messages
CREATE POLICY "Users can send messages" ON messages
    FOR INSERT WITH CHECK (
        auth.uid() = sender_id
    );

-- Policy: Users can update their own messages
CREATE POLICY "Users can update their messages" ON messages
    FOR UPDATE USING (
        auth.uid() = sender_id
    );

-- Policy: Users can delete their own messages (sender only)
CREATE POLICY "Users can delete their own messages" ON messages
    FOR DELETE USING (
        auth.uid() = sender_id
    );
