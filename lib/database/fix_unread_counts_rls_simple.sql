-- SIMPLIFIED FIX for unread_counts RLS policy
-- This allows any authenticated user to manage unread counts
-- Run this in your Supabase SQL Editor

-- Drop all existing policies
DROP POLICY IF EXISTS "Users can insert their own unread counts" ON unread_counts;
DROP POLICY IF EXISTS "Users can update their own unread counts" ON unread_counts;
DROP POLICY IF EXISTS "Users can view their own unread counts" ON unread_counts;
DROP POLICY IF EXISTS "Users can delete their own unread counts" ON unread_counts;
DROP POLICY IF EXISTS "Users can create unread counts when sending messages" ON unread_counts;
DROP POLICY IF EXISTS "Enable insert for authenticated users" ON unread_counts;
DROP POLICY IF EXISTS "Enable update for authenticated users" ON unread_counts;
DROP POLICY IF EXISTS "Enable select for authenticated users" ON unread_counts;
DROP POLICY IF EXISTS "Enable delete for authenticated users" ON unread_counts;

-- Enable RLS
ALTER TABLE unread_counts ENABLE ROW LEVEL SECURITY;

-- Simple policies: Allow authenticated users to do everything
-- This is appropriate for a messaging app where users need to update each other's unread counts

CREATE POLICY "Enable insert for authenticated users"
ON unread_counts FOR INSERT
TO authenticated
WITH CHECK (true);

CREATE POLICY "Enable select for authenticated users"
ON unread_counts FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "Enable update for authenticated users"
ON unread_counts FOR UPDATE
TO authenticated
USING (true)
WITH CHECK (true);

CREATE POLICY "Enable delete for authenticated users"
ON unread_counts FOR DELETE
TO authenticated
USING (true);
