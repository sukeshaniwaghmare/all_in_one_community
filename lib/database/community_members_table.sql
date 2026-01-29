-- Create community_members table
CREATE TABLE IF NOT EXISTS community_members (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    community_id UUID REFERENCES communities(id) ON DELETE CASCADE NOT NULL,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    role TEXT DEFAULT 'member' CHECK (role IN ('admin', 'moderator', 'member')),
    joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(community_id, user_id)
);

-- Enable RLS
ALTER TABLE community_members ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Members can view community membership" ON community_members
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM community_members cm 
            WHERE cm.community_id = community_members.community_id 
            AND cm.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can join communities" ON community_members
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Admins can manage members" ON community_members
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM community_members cm 
            WHERE cm.community_id = community_members.community_id 
            AND cm.user_id = auth.uid() 
            AND cm.role = 'admin'
        )
    );

-- Create function to update community member count
CREATE OR REPLACE FUNCTION update_community_member_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE communities 
        SET member_count = member_count + 1 
        WHERE id = NEW.community_id;
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE communities 
        SET member_count = member_count - 1 
        WHERE id = OLD.community_id;
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Create triggers for member count
CREATE TRIGGER community_member_count_insert
    AFTER INSERT ON community_members
    FOR EACH ROW
    EXECUTE FUNCTION update_community_member_count();

CREATE TRIGGER community_member_count_delete
    AFTER DELETE ON community_members
    FOR EACH ROW
    EXECUTE FUNCTION update_community_member_count();

-- Create indexes
CREATE INDEX IF NOT EXISTS community_members_community_id_idx ON community_members(community_id);
CREATE INDEX IF NOT EXISTS community_members_user_id_idx ON community_members(user_id);
CREATE INDEX IF NOT EXISTS community_members_role_idx ON community_members(role);