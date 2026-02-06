-- Fix for RLS policy error on unread_counts table
-- Run this in your Supabase SQL Editor

-- Drop existing policies if any
DROP POLICY IF EXISTS "Users can insert their own unread counts" ON unread_counts;
DROP POLICY IF EXISTS "Users can update their own unread counts" ON unread_counts;
DROP POLICY IF EXISTS "Users can view their own unread counts" ON unread_counts;
DROP POLICY IF EXISTS "Users can delete their own unread counts" ON unread_counts;

-- Enable RLS
ALTER TABLE unread_counts ENABLE ROW LEVEL SECURITY;

-- Allow users to insert unread counts for themselves (as receiver)
CREATE POLICY "Users can insert unread counts for themselves"
ON unread_counts FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- Allow users to update their own unread counts
CREATE POLICY "Users can update their own unread counts"
ON unread_counts FOR UPDATE
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- Allow users to view their own unread counts
CREATE POLICY "Users can view their own unread counts"
ON unread_counts FOR SELECT
USING (auth.uid() = user_id);

-- Allow users to delete their own unread counts
CREATE POLICY "Users can delete their own unread counts"
ON unread_counts FOR DELETE
USING (auth.uid() = user_id);

-- IMPORTANT: Also allow sender to create unread count for receiver
-- This is needed when sending messages
CREATE POLICY "Users can create unread counts when sending messages"
ON unread_counts FOR INSERT
WITH CHECK (
  -- Allow if the sender is creating an unread count entry
  -- The user_id in unread_counts should be the receiver
  EXISTS (
    SELECT 1 FROM messages 
    WHERE messages.sender_id = auth.uid()
    AND messages.receiver_id = unread_counts.user_id
  )
);
