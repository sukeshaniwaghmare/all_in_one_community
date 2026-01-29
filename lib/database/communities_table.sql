-- Create communities table
CREATE TABLE IF NOT EXISTS communities (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    type TEXT NOT NULL CHECK (type IN ('society', 'village', 'college', 'office', 'openGroup')),
    icon TEXT,
    created_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    member_count INTEGER DEFAULT 0,
    is_public BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE communities ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Anyone can view public communities" ON communities
    FOR SELECT USING (is_public = TRUE);

CREATE POLICY "Members can view private communities" ON communities
    FOR SELECT USING (
        is_public = FALSE AND 
        EXISTS (
            SELECT 1 FROM community_members 
            WHERE community_id = communities.id AND user_id = auth.uid()
        )
    );

CREATE POLICY "Authenticated users can create communities" ON communities
    FOR INSERT WITH CHECK (auth.uid() = created_by);

CREATE POLICY "Community creators can update their communities" ON communities
    FOR UPDATE USING (auth.uid() = created_by);

-- Create trigger for updated_at
CREATE TRIGGER communities_updated_at
    BEFORE UPDATE ON communities
    FOR EACH ROW
    EXECUTE FUNCTION handle_updated_at();

-- Create indexes
CREATE INDEX IF NOT EXISTS communities_type_idx ON communities(type);
CREATE INDEX IF NOT EXISTS communities_created_by_idx ON communities(created_by);
CREATE INDEX IF NOT EXISTS communities_public_idx ON communities(is_public);