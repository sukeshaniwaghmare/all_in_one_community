-- Run this script AFTER creating all tables
-- This adds the policies that have cross-table dependencies

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Members can view private communities" ON communities;
DROP POLICY IF EXISTS "Members can view community membership" ON community_members;
DROP POLICY IF EXISTS "Admins can manage members" ON community_members;

-- Create policies for communities
CREATE POLICY "Members can view private communities" ON communities
    FOR SELECT USING (
        is_public = FALSE AND 
        EXISTS (
            SELECT 1 FROM community_members 
            WHERE community_id = communities.id AND user_id = auth.uid()
        )
    );

-- Create policies for community_members
CREATE POLICY "Members can view community membership" ON community_members
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM community_members cm 
            WHERE cm.community_id = community_members.community_id 
            AND cm.user_id = auth.uid()
        )
    );

CREATE POLICY "Admins can manage members" ON community_members
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM community_members cm 
            WHERE cm.community_id = community_members.community_id 
            AND cm.user_id = auth.uid() 
            AND cm.role = 'admin'
        )
    );