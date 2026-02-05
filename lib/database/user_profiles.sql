create table public.user_profiles (
  id uuid not null,
  full_name text not null,
  avatar_url text null,
  bio text null,
  phone text null,
  location text null,
  created_at timestamp with time zone null default now(),
  updated_at timestamp with time zone null default now(),
  email text null,
  role text null default 'User'::text,
  username text null,
  is_dark_mode boolean null default false,
  language text null default 'English'::text,
  constraint user_profiles_pkey primary key (id),
  constraint user_profiles_id_fkey foreign KEY (id) references auth.users (id) on delete CASCADE
) TABLESPACE pg_default;

create index IF not exists user_profiles_full_name_idx on public.user_profiles using btree (full_name) TABLESPACE pg_default;