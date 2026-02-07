-- Groups table
create table if not exists public.groups (
  id uuid not null default gen_random_uuid(),
  name text not null,
  avatar_url text null,
  created_by uuid not null,
  created_at timestamp with time zone null default now(),
  updated_at timestamp with time zone null default now(),
  constraint groups_pkey primary key (id),
  constraint groups_created_by_fkey foreign key (created_by) references auth.users (id) on delete cascade
) tablespace pg_default;

-- Group members table
create table if not exists public.group_members (
  id uuid not null default gen_random_uuid(),
  group_id uuid not null,
  user_id uuid not null,
  joined_at timestamp with time zone null default now(),
  constraint group_members_pkey primary key (id),
  constraint group_members_group_id_fkey foreign key (group_id) references public.groups (id) on delete cascade,
  constraint group_members_user_id_fkey foreign key (user_id) references auth.users (id) on delete cascade,
  constraint unique_group_member unique (group_id, user_id)
) tablespace pg_default;

-- Group messages table
create table if not exists public.group_messages (
  id uuid not null default gen_random_uuid(),
  group_id uuid not null,
  sender_id uuid not null,
  message text not null,
  message_type text null default 'text',
  media_url text null,
  created_at timestamp with time zone null default now(),
  constraint group_messages_pkey primary key (id),
  constraint group_messages_group_id_fkey foreign key (group_id) references public.groups (id) on delete cascade,
  constraint group_messages_sender_id_fkey foreign key (sender_id) references auth.users (id) on delete cascade
) tablespace pg_default;

-- Indexes
create index if not exists groups_created_by_idx on public.groups using btree (created_by) tablespace pg_default;
create index if not exists group_members_group_id_idx on public.group_members using btree (group_id) tablespace pg_default;
create index if not exists group_members_user_id_idx on public.group_members using btree (user_id) tablespace pg_default;
create index if not exists group_messages_group_id_idx on public.group_messages using btree (group_id) tablespace pg_default;
create index if not exists group_messages_sender_id_idx on public.group_messages using btree (sender_id) tablespace pg_default;

-- Enable RLS
alter table public.groups enable row level security;
alter table public.group_members enable row level security;
alter table public.group_messages enable row level security;

-- Drop existing policies if they exist
drop policy if exists "Users can create groups" on public.groups;
drop policy if exists "Users can view groups they are members of" on public.groups;
drop policy if exists "Group creators can update their groups" on public.groups;
drop policy if exists "Group creators can delete their groups" on public.groups;
drop policy if exists "Users can add members to groups they created" on public.group_members;
drop policy if exists "Users can view group members" on public.group_members;
drop policy if exists "Group creators can remove members" on public.group_members;
drop policy if exists "Group members can send messages" on public.group_messages;
drop policy if exists "Group members can view messages" on public.group_messages;
drop policy if exists "Message senders can delete their messages" on public.group_messages;

-- RLS Policies for groups table
create policy "Users can create groups" on public.groups
  for insert with check (auth.uid() IS NOT NULL);

create policy "Users can view groups they are members of" on public.groups
  for select using (auth.uid() IS NOT NULL);

create policy "Group creators can update their groups" on public.groups
  for update using (auth.uid() = created_by);

create policy "Group creators can delete their groups" on public.groups
  for delete using (auth.uid() = created_by);

-- RLS Policies for group_members table
create policy "Users can add members to groups they created" on public.group_members
  for insert with check (auth.uid() IS NOT NULL);

create policy "Users can view group members" on public.group_members
  for select using (auth.uid() IS NOT NULL);

create policy "Group creators can remove members" on public.group_members
  for delete using (auth.uid() IS NOT NULL);

-- RLS Policies for group_messages table
create policy "Group members can send messages" on public.group_messages
  for insert with check (auth.uid() IS NOT NULL);

create policy "Group members can view messages" on public.group_messages
  for select using (auth.uid() IS NOT NULL);

create policy "Message senders can delete their messages" on public.group_messages
  for delete using (auth.uid() = sender_id);
