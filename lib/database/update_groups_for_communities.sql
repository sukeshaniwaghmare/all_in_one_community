-- Add community_id and description columns to groups table
ALTER TABLE public.groups 
ADD COLUMN IF NOT EXISTS community_id UUID REFERENCES public.communities(id) ON DELETE SET NULL,
ADD COLUMN IF NOT EXISTS description TEXT;

-- Create index for faster queries
CREATE INDEX IF NOT EXISTS groups_community_id_idx ON public.groups(community_id);

-- Create community_members table if not exists
CREATE TABLE IF NOT EXISTS public.community_members (
  id UUID NOT NULL DEFAULT gen_random_uuid(),
  community_id UUID NOT NULL,
  user_id UUID NOT NULL,
  role TEXT DEFAULT 'member',
  joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  CONSTRAINT community_members_pkey PRIMARY KEY (id),
  CONSTRAINT community_members_community_id_fkey FOREIGN KEY (community_id) REFERENCES public.communities(id) ON DELETE CASCADE,
  CONSTRAINT community_members_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE,
  CONSTRAINT unique_community_member UNIQUE (community_id, user_id)
) TABLESPACE pg_default;

-- Create indexes
CREATE INDEX IF NOT EXISTS community_members_community_id_idx ON public.community_members(community_id);
CREATE INDEX IF NOT EXISTS community_members_user_id_idx ON public.community_members(user_id);

-- Enable RLS
ALTER TABLE public.community_members ENABLE ROW LEVEL SECURITY;

-- RLS Policies for community_members
CREATE POLICY "Users can view community members" ON public.community_members
  FOR SELECT USING (auth.uid() IS NOT NULL);

CREATE POLICY "Users can join communities" ON public.community_members
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can leave communities" ON public.community_members
  FOR DELETE USING (auth.uid() = user_id);
