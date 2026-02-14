-- Add community_id column to groups table to link groups with communities
ALTER TABLE public.groups 
ADD COLUMN IF NOT EXISTS community_id UUID REFERENCES public.communities(id) ON DELETE SET NULL;

-- Add description column to groups table
ALTER TABLE public.groups 
ADD COLUMN IF NOT EXISTS description TEXT;

-- Create index for faster queries
CREATE INDEX IF NOT EXISTS groups_community_id_idx ON public.groups(community_id);
