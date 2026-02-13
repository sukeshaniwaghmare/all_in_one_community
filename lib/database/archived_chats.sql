create table public.archived_chats (
  id uuid not null default extensions.uuid_generate_v4 (),
  chat_id text not null,
  user_id uuid not null,
  archived_at timestamp without time zone null default now(),
  constraint archived_chats_pkey primary key (id)
) TABLESPACE pg_default;

create index IF not exists idx_archived_chats_user_id on public.archived_chats using btree (user_id) TABLESPACE pg_default;

create index IF not exists idx_archived_chats_chat_id on public.archived_chats using btree (chat_id) TABLESPACE pg_default;



-------------------------
-- Create archived_chats table if not exists
CREATE TABLE IF NOT EXISTS archived_chats (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  chat_id TEXT NOT NULL,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  archived_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(chat_id, user_id)
);

-- Enable RLS
ALTER TABLE archived_chats ENABLE ROW LEVEL SECURITY;

-- Policy: Users can view their own archived chats
CREATE POLICY "Users can view own archived chats"
ON archived_chats FOR SELECT
USING (auth.uid() = user_id);

-- Policy: Users can insert their own archived chats
CREATE POLICY "Users can insert own archived chats"
ON archived_chats FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- Policy: Users can delete their own archived chats
CREATE POLICY "Users can delete own archived chats"
ON archived_chats FOR DELETE
USING (auth.uid() = user_id);

-- Create index for better performance
CREATE INDEX IF NOT EXISTS idx_archived_chats_user_id ON archived_chats(user_id);
CREATE INDEX IF NOT EXISTS idx_archived_chats_chat_id ON archived_chats(chat_id);
