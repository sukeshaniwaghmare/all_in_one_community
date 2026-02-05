create table public.messages (
  id uuid not null default gen_random_uuid (),
  sender_id uuid not null,
  receiver_id uuid not null,
  message text not null,
  message_type text null default 'text'::text,
  is_read boolean null default false,
  created_at timestamp with time zone null default now(),
  updated_at timestamp with time zone null default now(),
  status character varying(20) null default 'sent'::character varying,
  media_url text null,
  thumbnail_url text null,
  is_deleted boolean null default false,
  deleted_for text null,
  constraint messages_pkey primary key (id),
  constraint messages_receiver_id_fkey foreign KEY (receiver_id) references auth.users (id) on delete CASCADE,
  constraint messages_sender_id_fkey foreign KEY (sender_id) references auth.users (id) on delete CASCADE,
  constraint messages_deleted_for_check check (
    (
      deleted_for = any (array['me'::text, 'everyone'::text])
    )
  ),
  constraint messages_message_type_check check (
    (
      message_type = any (
        array[
          'text'::text,
          'image'::text,
          'video'::text,
          'audio'::text,
          'file'::text
        ]
      )
    )
  )
) TABLESPACE pg_default;

create index IF not exists messages_sender_id_idx on public.messages using btree (sender_id) TABLESPACE pg_default;

create index IF not exists messages_receiver_id_idx on public.messages using btree (receiver_id) TABLESPACE pg_default;

create index IF not exists messages_created_at_idx on public.messages using btree (created_at desc) TABLESPACE pg_default;

create index IF not exists messages_conversation_idx on public.messages using btree (sender_id, receiver_id, created_at desc) TABLESPACE pg_default;

create trigger messages_updated_at BEFORE
update on messages for EACH row
execute FUNCTION handle_updated_at ();