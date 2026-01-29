-- All-in-One Community Database Setup
-- Run this script in your Supabase SQL editor

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create function to handle updated_at (used by multiple tables)
CREATE OR REPLACE FUNCTION handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- PROFILES TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS profiles (
    id UUID REFERENCES auth.users(id) PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    avatar_url TEXT,
    phone TEXT,
    bio TEXT,
    username TEXT UNIQUE,
    is_dark_mode BOOLEAN DEFAULT FALSE,
    language TEXT DEFAULT 'English',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own profile" ON profiles
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON profiles
    FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile" ON profiles
    FOR INSERT WITH CHECK (auth.uid() = id);

CREATE TRIGGER profiles_updated_at
    BEFORE UPDATE ON profiles
    FOR EACH ROW
    EXECUTE FUNCTION handle_updated_at();

-- ============================================
-- COMMUNITIES TABLE
-- ============================================
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

ALTER TABLE communities ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view public communities" ON communities
    FOR SELECT USING (is_public = TRUE);

CREATE POLICY "Authenticated users can create communities" ON communities
    FOR INSERT WITH CHECK (auth.uid() = created_by);

CREATE POLICY "Community creators can update their communities" ON communities
    FOR UPDATE USING (auth.uid() = created_by);

CREATE TRIGGER communities_updated_at
    BEFORE UPDATE ON communities
    FOR EACH ROW
    EXECUTE FUNCTION handle_updated_at();

-- ============================================
-- COMMUNITY MEMBERS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS community_members (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    community_id UUID REFERENCES communities(id) ON DELETE CASCADE NOT NULL,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    role TEXT DEFAULT 'member' CHECK (role IN ('admin', 'moderator', 'member')),
    joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(community_id, user_id)
);

ALTER TABLE community_members ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can join communities" ON community_members
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Function to update community member count
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

CREATE TRIGGER community_member_count_insert
    AFTER INSERT ON community_members
    FOR EACH ROW
    EXECUTE FUNCTION update_community_member_count();

CREATE TRIGGER community_member_count_delete
    AFTER DELETE ON community_members
    FOR EACH ROW
    EXECUTE FUNCTION update_community_member_count();

-- ============================================
-- CART ITEMS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS cart_items (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    product_id TEXT NOT NULL,
    product_name TEXT NOT NULL,
    price DECIMAL(10,2) NOT NULL CHECK (price >= 0),
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    image_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE cart_items ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own cart items" ON cart_items
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own cart items" ON cart_items
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own cart items" ON cart_items
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own cart items" ON cart_items
    FOR DELETE USING (auth.uid() = user_id);

CREATE TRIGGER cart_items_updated_at
    BEFORE UPDATE ON cart_items
    FOR EACH ROW
    EXECUTE FUNCTION handle_updated_at();

-- ============================================
-- INDEXES FOR PERFORMANCE
-- ============================================
CREATE INDEX IF NOT EXISTS communities_type_idx ON communities(type);
CREATE INDEX IF NOT EXISTS communities_created_by_idx ON communities(created_by);
CREATE INDEX IF NOT EXISTS communities_public_idx ON communities(is_public);
CREATE INDEX IF NOT EXISTS community_members_community_id_idx ON community_members(community_id);
CREATE INDEX IF NOT EXISTS community_members_user_id_idx ON community_members(user_id);
CREATE INDEX IF NOT EXISTS community_members_role_idx ON community_members(role);
CREATE INDEX IF NOT EXISTS cart_items_user_id_idx ON cart_items(user_id);
CREATE INDEX IF NOT EXISTS cart_items_product_id_idx ON cart_items(product_id);