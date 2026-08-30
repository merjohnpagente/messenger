# Messenger — Full-Stack Build Spec (FINAL v1.0)

> ARCHITECT-B final — $0 forever constraint enforced. Critiqued and hardened from ARCHITECT-A draft.

## Project Summary

Convert existing Flutter UI mock (`lib/main.dart`, `lib/screens/*`, `lib/widgets/*`, `lib/theme/messenger_theme.dart`, mocks at `lib/screens/chats_screen.dart:64`, `people_screen.dart:37`, `calls_screen.dart:35`, fake auth `login_screen.dart:16`, mock call `call_screen.dart:23`) into production Messenger clone. Backend is Supabase (Postgres + PostgREST + Realtime + GoTrue + Storage) — Cloud Free for dev, self-hosted on Oracle Always-Free for prod. Video is P2P `flutter_webrtc` + STUN `stun.l.google.com:19302` + TURN `openrelay.metered.ca` (dev) → `coturn` on same VM (prod). Same Flutter codebase, different env URLs.

## Target Platform(s)

- **Primary:** Android + iOS (Flutter 3.x, `pubspec.yaml:6` sdk >=3.0.0). Camera/mic permissions, `wakelock_plus`. Background CallKit **deferred to P1** (see critique).
- **Secondary:** Flutter Web — chat/stories/media works; WebRTC via browser; no CallKit.
- **Out:** Desktop, E2E encryption — post-MVP.

## Critique of Draft (What Was Fixed)

- **Scope creep:** Draft MVP listed 7 large features (auth + chat + media + presence + push + video + search) as one MVP — unrealistic for builder. **Fixed:** Cut MVP to 4 milestones; video foreground-only, stories/group/LiveKit moved to P1.
- **Auth fiction:** Draft invented 15m/7d JWT refresh — Supabase GoTrue already handles it. **Fixed:** Use Supabase session (auto-refresh), `flutter_secure_storage` only for anon key cache, `go_router` redirect checks `supabase.auth.currentSession`.
- **Free combo conflict:** Draft spec mixed `firebase_messaging + Supabase` without noting Firebase project + APNs $99/yr Apple Dev breaks "$0" claim and adds 1-day setup. **Fixed:** FCM + `flutter_callkit_incoming` explicitly deferred to P1; MVP uses foreground Realtime only (app must be open). Still $0.
- **Missing edge cases:** No message ordering, pagination, TURN failure, permission denial, call interruption, RLS index. **Fixed:** Added to Build Plan + DoD.
- **Realtime misuse:** Draft suggested `postgres_changes` for typing/ICE — would bloat DB. **Fixed:** `broadcast` (ephemeral) for `typing/call:ice`, `postgres_changes` only for `messages`.
- **Offline vague:** `hive` vs `drift` undecided. **Fixed:** Decision = `hive_flutter` for MVP (simple queue), `drift` only if complex queries needed later.

## Core Features (MVP) vs Nice-to-have (P1+)

### MVP (P0) — Definition of Done scope

1. **Auth:** Email/password signup/login/logout, forgot password (Supabase email), `go_router` guard fixing `splash_screen.dart:17` timer, profile edit (`public.users`).
2. **Users/Presence/Search:** Real users (`people_screen.dart:101` query), `MessengerSearchBar` search, `is_online/last_seen` via Realtime `presence` (broadcast).
3. **1:1 Realtime Chat:** Conversations (`chats_screen.dart:360`), thread (`chat_thread_screen.dart:69`) optimistic send → `broadcast: message:new`, typing (`chat_thread_screen.dart:294` 300ms debounce), read receipts `message_status` (sent→delivered→seen), cursor pagination (20/msg), retry on fail.
4. **Media:** Image/file picker → compress `flutter_image_compress` (<1MB image, <10MB video) → Supabase Storage `message-media` → render in `_MessageRow` `chat_thread_screen.dart:406`.
5. **1:1 Voice/Video Foreground:** Wire `chat_thread_screen.dart:238` + `calls_screen.dart:194` → `webrtc_service` abstract interface (P2P `flutter_webrtc`), `RTCVideoView` stack in `call_screen.dart:109` (remote full, draggable PiP local), mute/speaker/camera/flip/end (`_ControlButton:247`), signaling via `broadcast: call:invite/accept/decline/ice/end` + 30s timeout → `call_logs` missed, duration.

### P1 Nice-to-have (NOT in MVP)

Group chats, LiveKit SFU (self-hosted), FCM + CallKit background (needs Firebase + APNs), stories 24h expiry + viewers, reactions/reply/forward/edit/delete, voice notes, location/GIF, screen share/recording, pin/archive, E2E.

## Suggested Tech Stack (FINAL)

- **Frontend:** Flutter 3.x, `flutter_riverpod` (replaces `setState`), `go_router`, `supabase_flutter`, `flutter_webrtc`, `permission_handler`, `image_picker`, `file_picker`, `emoji_picker_flutter`, `flutter_secure_storage`, `hive_flutter`, `wakelock_plus`, `flutter_image_compress`, `intl`/`google_fonts` (keep).
- **Backend:** Supabase Postgres. Tables: `users(id uuid fk auth.users, email, name, avatar_url, bio, is_online bool, last_seen timestamptz)`, `conversations(id uuid, is_group bool, name, avatar_url, created_by uuid)`, `conversation_participants(conversation_id, user_id, role, pk)`, `messages(id uuid, conversation_id fk, sender_id fk, type enum, text, media_url, reply_to_id nullable, created_at)`, `message_status(message_id, user_id, status enum, ts)`, `call_logs(id, conversation_id, caller_id, callee_id, direction, is_video, duration, started_at)`, `blocks` + `stories` (P1). Index: `messages(conversation_id, created_at desc)`, `participants(user_id)`. RLS: `participants` check — `exists (select 1 from conversation_participants where conversation_id = messages.conversation_id and user_id = auth.uid())`.
- **Realtime:** `postgres_changes` for `messages` inserts; `broadcast` for `typing/call:ice/presence` (ephemeral, no DB).
- **Infra $0:** Dev: Supabase Cloud Free + `openrelay.metered.ca:80/443` (openrelayproject). Prod: Oracle Always-Free VM Docker `supabase` + `coturn` (LT-cred, ports 3478/5349, Let's Encrypt). FCM deferred.

## Suggested UX/UI Direction

- Keep Messenger tokens `messengerTheme.dart:4` (`#0084FF`, `lightBg #FFF`, `darkBg #1C1C1E`), `ChatTile`, `StoryCircle` ring (`storyRing`), pill `MessengerSearchBar`. 
- **Add for MVP:** `CallScreen` stack (remote `RTCVideoView`, PiP local draggable, avatar fallback gradient when cam off), permission rationale sheets, empty ("No conversations"), error (retry), offline banner, shimmer loading, dark mode verified on all screens. Input bar `chat_thread_screen.dart:312` → attachment bottom sheet + emoji.

## Open Questions for YOU (Material — Answer Before Build)

**Only 3 that change what gets built:**
1. **Video background:** Confirm MVP is **foreground-only** (app must be open). Background CallKit requires Apple Developer $99/yr + Firebase APNs + 1-day setup — breaks "$0" and delays MVP by ~2 days. Do you have Apple Dev account and want it in MVP, or defer to P1 as spec does?
2. **Backend start:** Start on **Supabase Cloud Free (30 min)** now and migrate to Oracle VM later, or **self-host immediately (1 day)**? First is faster; second is forever-free from day one.
3. **Storage caps:** Confirm <1MB image / <10MB video + 1GB total Cloud free is acceptable for MVP, or must self-host from start to avoid quota?

> Reply with 1/2/3 choices; builder proceeds with defaults: (1) foreground-only, (2) Cloud Free first, (3) caps accepted — if no answer in 24h.

---

## Step-by-Step Build Plan (Ordered Milestones — Builder Must Follow)

**Milestone 0 — Contract & Scaffolding (0.5 day)**
- Create `supabase/migrations/001_init.sql` with tables/indexes/RLS + `lib/models/*.dart` (`freezed`/`json_serializable` or plain) mirroring schema. Add `API_CONTRACT.md`. Add deps: `flutter_riverpod, go_router, supabase_flutter, flutter_webrtc, permission_handler, hive_flutter, flutter_secure_storage, image_picker, file_picker, wakelock_plus, flutter_image_compress`. Wire `ProviderScope` + `Supabase.initialize` in `lib/main.dart:9`, `MaterialApp.router`, fix `splash_screen.dart:17` guard. Set `.env` (`SUPABASE_URL/ANON_KEY`, `TURN_URL/CRED`).

**Milestone 1 — Auth (1 day)**
- Replace `login_screen.dart:16` with `supabase.auth.signIn/signUp/reset`, `register_screen.dart`, `forgot_password_screen.dart`, validation, `secure_storage`, `go_router` redirect. Seed `public.users` trigger on `auth.users` insert. Verify cold restart persists.

**Milestone 2 — Users / Presence / Search (1 day)**
- Real `PeopleScreen` query, `MessengerSearchBar` `ilike`, `users.is_online` via `broadcast: presence`, `hive` cache.

**Milestone 3 — 1:1 Chat Core (2 days)**
- Conversations list pagination, thread optimistic send + `postgres_changes` listener, typing `broadcast` 300ms debounce, `message_status` updates, cursor pagination, error/retry, offline `hive` queue.

**Milestone 4 — Media (1 day)**
- Picker → compress → `supabase.storage.from('message-media').upload` → insert `messages` with `media_url` → render in `_MessageRow`.

**Milestone 5 — Foreground Voice/Video (2 days)**
- Abstract `webrtc_service.dart` (interface → `WebrtcP2pImpl`), `RTCVideoView` stack in `call_screen.dart:109`, controls `call_screen.dart:247`, `permission_handler`, `broadcast: call:*` signaling, 30s timeout, `call_logs` insert, `CallsScreen` real logs. Test two devices on different networks (proves TURN).

**Milestone 6 — Polish & QA (1 day)**
- Empty/error/offline/shimmer, permission denied flows, call interruption (GSM), TURN failure fallback snackbar, RLS tests, `flutter analyze` + widget tests.

**Milestone 7 — Self-Host Migration (P1, when ready)**
- Oracle VM Docker `supabase` + `coturn` config, switch env URLs, no code change. Add LiveKit OSS if group needed.

## Recommended Subagents (Pick Exactly 3 Active — Suggestions)

- **database-designer** — schema, RLS, indexes, `broadcast` vs `postgres_changes`
- **backend-api** — Supabase auth/storage/realtime events + `webrtc_service` signaling contract
- **frontend-flutter** — Riverpod, `go_router`, `flutter_webrtc` UI, `hive` offline, theme
- *(alternates if you swap)* **security-auditor** (RLS/validation/TURN creds) or **qa** (two-device TURN test) or **devops-cicd** (Oracle Docker `coturn`)

> Final choice of exactly 3 active subagents belongs to you.

## Definition of Done for the MVP

- [ ] `flutter analyze` + `flutter test` green; no `setState` chat logic (Riverpod).
- [ ] Flows: register → login → cold restart stays in → search user → create 1:1 → send text/image (<1MB) → recipient realtime <1s → typing indicator → seen receipt updates.
- [ ] Presence: online dot `chat_tile.dart:150` + `chat_thread_screen.dart:185` reflects within 5s.
- [ ] Call: Device A (WiFi) → Device B (mobile data) video foreground: ring → accept → both see video <1s, mute/camera/flip/speaker work, 30s timeout → missed log, end → duration saved to `call_logs`, `CallsScreen` updates.
- [ ] Edge: permission denied → downgrade to audio + snackbar; airplane mid-call → clean `call:end`; offline message queued in `hive` → sent on reconnect.
- [ ] Storage: 10MB video rejected client-side, 1GB quota not exceeded, RLS verified (user cannot read non-participant conversation).
- [ ] Env: `SUPABASE_URL/ANON_KEY` via `--dart-define`, no secrets in repo.

## Git Workflow Note

`git-ops` subagent pushes to GitHub after each completed milestone (0→6). Each push tagged `milestone-{n}` with changelog.

