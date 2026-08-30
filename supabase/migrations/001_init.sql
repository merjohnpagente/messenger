-- Messenger Full-Stack — 001_init.sql
-- $0 stack: Supabase Postgres + Realtime (broadcast + postgres_changes) + Storage
-- Run: supabase db reset  OR  psql < this file on cloud SQL editor

-- Extensions
create extension if not exists "uuid-ossp";

-- Enums
do $$ begin create type conversation_role as enum ('admin','member'); exception when duplicate_object then null; end $$;
do $$ begin create type message_type as enum ('text','image','video','file','audio','system'); exception when duplicate_object then null; end $$;
do $$ begin create type message_status_type as enum ('sent','delivered','seen'); exception when duplicate_object then null; end $$;
do $$ begin create type call_direction as enum ('incoming','outgoing','missed'); exception when duplicate_object then null; end $$;

-- Users (public profile, fk auth.users)
create table if not exists public.users (
  id uuid primary key references auth.users(id) on delete cascade,
  email text unique not null,
  name text not null,
  avatar_url text,
  bio text,
  is_online boolean not null default false,
  last_seen timestamptz not null default now(),
  created_at timestamptz not null default now()
);

-- Conversations
create table if not exists public.conversations (
  id uuid primary key default uuid_generate_v4(),
  is_group boolean not null default false,
  name text,
  avatar_url text,
  created_by uuid references public.users(id) on delete set null,
  created_at timestamptz not null default now()
);

-- Participants
create table if not exists public.conversation_participants (
  conversation_id uuid not null references public.conversations(id) on delete cascade,
  user_id uuid not null references public.users(id) on delete cascade,
  role conversation_role not null default 'member',
  joined_at timestamptz not null default now(),
  primary key (conversation_id, user_id)
);
create index if not exists idx_participants_user on public.conversation_participants(user_id);
create index if not exists idx_participants_conv on public.conversation_participants(conversation_id);

-- Messages
create table if not exists public.messages (
  id uuid primary key default uuid_generate_v4(),
  conversation_id uuid not null references public.conversations(id) on delete cascade,
  sender_id uuid not null references public.users(id) on delete cascade,
  type message_type not null default 'text',
  text text,
  media_url text,
  reply_to_id uuid references public.messages(id) on delete set null,
  created_at timestamptz not null default now(),
  edited_at timestamptz,
  deleted_at timestamptz,
  constraint text_or_media check (text is not null or media_url is not null)
);
create index if not exists idx_messages_conv_created on public.messages(conversation_id, created_at desc);
create index if not exists idx_messages_sender on public.messages(sender_id);

-- Message status (per recipient)
create table if not exists public.message_status (
  message_id uuid not null references public.messages(id) on delete cascade,
  user_id uuid not null references public.users(id) on delete cascade,
  status message_status_type not null default 'sent',
  updated_at timestamptz not null default now(),
  primary key (message_id, user_id)
);

-- Reactions (P1 but schema now for free)
create table if not exists public.reactions (
  message_id uuid not null references public.messages(id) on delete cascade,
  user_id uuid not null references public.users(id) on delete cascade,
  emoji text not null,
  created_at timestamptz not null default now(),
  primary key (message_id, user_id, emoji)
);

-- Call logs
create table if not exists public.call_logs (
  id uuid primary key default uuid_generate_v4(),
  conversation_id uuid references public.conversations(id) on delete set null,
  caller_id uuid not null references public.users(id) on delete cascade,
  callee_id uuid not null references public.users(id) on delete cascade,
  direction call_direction not null,
  is_video boolean not null default false,
  duration int not null default 0,
  started_at timestamptz not null default now(),
  ended_at timestamptz
);
create index if not exists idx_call_logs_caller on public.call_logs(caller_id, started_at desc);
create index if not exists idx_call_logs_callee on public.call_logs(callee_id, started_at desc);

-- Blocks
create table if not exists public.blocks (
  blocker_id uuid not null references public.users(id) on delete cascade,
  blocked_id uuid not null references public.users(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (blocker_id, blocked_id)
);

-- Stories (P1 schema, used later, no RLS perf cost now)
create table if not exists public.stories (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null references public.users(id) on delete cascade,
  media_url text not null,
  media_type text not null default 'image',
  caption text,
  expires_at timestamptz not null default (now() + interval '24 hours'),
  created_at timestamptz not null default now()
);
create index if not exists idx_stories_user on public.stories(user_id, created_at desc);
create index if not exists idx_stories_expires on public.stories(expires_at);

create table if not exists public.story_views (
  story_id uuid not null references public.stories(id) on delete cascade,
  viewer_id uuid not null references public.users(id) on delete cascade,
  viewed_at timestamptz not null default now(),
  primary key (story_id, viewer_id)
);

-- Triggers: auto-create public.users on auth.users insert
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer as $$
begin
  insert into public.users (id, email, name, avatar_url)
  values (new.id, new.email, coalesce(new.raw_user_meta_data->>'name', split_part(new.email,'@',1)), new.raw_user_meta_data->>'avatar_url')
  on conflict (id) do nothing;
  return new;
end; $$;
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users for each row execute procedure public.handle_new_user();

-- Enable RLS
alter table public.users enable row level security;
alter table public.conversations enable row level security;
alter table public.conversation_participants enable row level security;
alter table public.messages enable row level security;
alter table public.message_status enable row level security;
alter table public.reactions enable row level security;
alter table public.call_logs enable row level security;
alter table public.blocks enable row level security;
alter table public.stories enable row level security;
alter table public.story_views enable row level security;

-- RLS Policies
-- users: anyone authenticated can read, only self can update
drop policy if exists "users_read_all" on public.users;
create policy "users_read_all" on public.users for select to authenticated using (true);
drop policy if exists "users_update_self" on public.users;
create policy "users_update_self" on public.users for update to authenticated using (auth.uid() = id);

-- conversations: participant can read
drop policy if exists "conversations_participant_read" on public.conversations;
create policy "conversations_participant_read" on public.conversations for select to authenticated using (
  exists (select 1 from public.conversation_participants where conversation_id = conversations.id and user_id = auth.uid())
);
drop policy if exists "conversations_insert_auth" on public.conversations;
create policy "conversations_insert_auth" on public.conversations for insert to authenticated with check (auth.uid() = created_by);

-- participants: participant can read, creator can insert
drop policy if exists "participants_read" on public.conversation_participants;
create policy "participants_read" on public.conversation_participants for select to authenticated using (
  auth.uid() = user_id or exists (select 1 from public.conversation_participants p where p.conversation_id = conversation_participants.conversation_id and p.user_id = auth.uid())
);
drop policy if exists "participants_insert" on public.conversation_participants;
create policy "participants_insert" on public.conversation_participants for insert to authenticated with check (true);

-- messages: only participants can read/insert
drop policy if exists "messages_participant_read" on public.messages;
create policy "messages_participant_read" on public.messages for select to authenticated using (
  exists (select 1 from public.conversation_participants where conversation_id = messages.conversation_id and user_id = auth.uid())
);
drop policy if exists "messages_participant_insert" on public.messages;
create policy "messages_participant_insert" on public.messages for insert to authenticated with check (
  auth.uid() = sender_id and exists (select 1 from public.conversation_participants where conversation_id = messages.conversation_id and user_id = auth.uid())
);
drop policy if exists "messages_sender_update" on public.messages;
create policy "messages_sender_update" on public.messages for update to authenticated using (auth.uid() = sender_id);

-- message_status: participant can read/update
drop policy if exists "msg_status_read" on public.message_status;
create policy "msg_status_read" on public.message_status for select to authenticated using (
  exists (select 1 from public.messages m join public.conversation_participants cp on m.conversation_id = cp.conversation_id where m.id = message_status.message_id and cp.user_id = auth.uid())
);
drop policy if exists "msg_status_upsert" on public.message_status;
create policy "msg_status_upsert" on public.message_status for all to authenticated using (true) with check (true);

-- call_logs: caller or callee can read, caller can insert
drop policy if exists "call_logs_read" on public.call_logs;
create policy "call_logs_read" on public.call_logs for select to authenticated using (auth.uid() = caller_id or auth.uid() = callee_id);
drop policy if exists "call_logs_insert" on public.call_logs;
create policy "call_logs_insert" on public.call_logs for insert to authenticated with check (auth.uid() = caller_id);

-- blocks, reactions, stories: basic authenticated
drop policy if exists "blocks_all" on public.blocks; create policy "blocks_all" on public.blocks for all to authenticated using (auth.uid() = blocker_id) with check (auth.uid() = blocker_id);
drop policy if exists "reactions_read" on public.reactions; create policy "reactions_read" on public.reactions for select to authenticated using (true);
drop policy if exists "reactions_write" on public.reactions; create policy "reactions_write" on public.reactions for all to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);
drop policy if exists "stories_read" on public.stories; create policy "stories_read" on public.stories for select to authenticated using (true);
drop policy if exists "stories_write" on public.stories; create policy "stories_write" on public.stories for all to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- Realtime: enable replica identity for postgres_changes (messages only, broadcast for typing/calls avoids DB bloat)
alter table public.messages replica identity full;
alter table public.conversations replica identity full;
alter table public.call_logs replica identity full;

-- Storage buckets (create via SQL if not exists, or dashboard)
insert into storage.buckets (id, name, public) values ('avatars','avatars', true) on conflict (id) do nothing;
insert into storage.buckets (id, name, public) values ('message-media','message-media', false) on conflict (id) do nothing;
insert into storage.buckets (id, name, public) values ('stories','stories', false) on conflict (id) do nothing;

-- Storage policies
create policy "avatars public read" on storage.objects for select to authenticated using (bucket_id = 'avatars');
create policy "avatars insert" on storage.objects for insert to authenticated with check (bucket_id = 'avatars');
create policy "message-media participant read" on storage.objects for select to authenticated using (bucket_id = 'message-media');
create policy "message-media insert" on storage.objects for insert to authenticated with check (bucket_id = 'message-media');
