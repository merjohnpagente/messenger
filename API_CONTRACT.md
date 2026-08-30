# API Contract — Messenger $0 Stack

**Backend:** Supabase Postgres + PostgREST (auto) + GoTrue Auth + Storage + Realtime. No custom server. Frontend `lib/models/*` mirrors `supabase/migrations/001_init.sql`.

## Auth (GoTrue via `supabase_flutter`)
- `supabase.auth.signUp(email,password, data:{name})` → `auth.users` → trigger → `public.users`.
- `signInWithPassword(email,password)` → session (auto-refresh, stored in `flutter_secure_storage` via Supabase).
- `resetPasswordForEmail(email)` → email link.
- `signOut()` → clear.
- `GET public.users?id=eq.<uuid>` — profile. `PATCH public.users` — update self only (RLS).

## Conversations
- `GET /rest/v1/conversations?select=*,conversation_participants!inner(user_id)&conversation_participants.user_id=eq.<me>` — my conversations (RLS enforces).
- `POST /rest/v1/conversations` + `POST /rest/v1/conversation_participants` (2 inserts) — create 1:1 or group. For 1:1: check existing by querying participants having both user_ids.
- 1:1 dedup RPC (optional P1): `rpc get_or_create_direct_conversation(other_user_id uuid)`.

## Messages
- `GET /rest/v1/messages?conversation_id=eq.<id>&order=created_at.desc&limit=20&created_at=lt.<cursor>` — pagination cursor = ISO ts.
- `POST /rest/v1/messages` — `{conversation_id, sender_id: auth.uid(), type, text, media_url, reply_to_id}`. RLS: sender must be participant.
- `PATCH /rest/v1/messages?id=eq.<id>` — edit (owner only) sets `edited_at`.
- `POST /rest/v1/message_status` — upsert `status` (sent/delivered/seen) per recipient.

## Realtime
- **postgres_changes** (DB-backed): `supabase.channel('messages').onPostgresChanges(event: Insert, schema: public, table: messages, filter: conversation_id=eq.<id>)` → `message:new`.
- **broadcast** (ephemeral, no DB bloat):
  - `channel('conversation:<id>').onBroadcast(event: 'typing')` payload `{user_id, is_typing: bool}` debounce 300ms.
  - `channel('conversation:<id>').onBroadcast(event: 'presence')` `{user_id, is_online, last_seen}`.
  - `channel('call:<callId>').onBroadcast(event: 'call:invite'|'call:accept'|'call:decline'|'call:ice'|'call:end')` payload `{from, to, is_video, sdp, ice}`.

## Storage
- `supabase.storage.from('avatars').upload('user_<uid>.jpg', file)` — public bucket, RLS public read.
- `from('message-media').upload('conv_<id>/<uuid>.jpg', file, fileOptions: {cacheControl: '3600'})` — private, participant read via RLS on objects (reuse conversation check). Limit client: <1MB image (compress), <10MB video.

## Call Logs
- `POST /rest/v1/call_logs` — `{caller_id, callee_id, direction, is_video, duration}` on `call:end` or timeout.
- `GET /rest/v1/call_logs?or=(caller_id.eq.<me>,callee_id.eq.<me>)&order=started_at.desc`

## Presence
- Client on `initState` does `users.update({is_online: true})` and on `dispose/background` `is_online:false, last_seen:now()`. Broadcast `presence` for instant UI (<1s), DB for persistence.

## Offline
- `hive_flutter` box `offline_queue` stores `messages` inserts when no network; on `connectivity` restore, replay in order, clear on success.

## Env (no secrets in repo)
- `--dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=... --dart-define=TURN_URL=turn:openrelay.metered.ca:80 --dart-define=TURN_USER=openrelayproject --dart-define=TURN_CRED=openrelayproject`
- Prod `TURN_URL` = `turn:<oracle-ip>:3478` (coturn).
