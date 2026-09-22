# Messenger — Modern Chat (Flutter)

Production Messenger clone — Flutter 3.x + Supabase ($0 forever) + P2P WebRTC. Same codebase: Android, iOS, **Web**.

Live demo (after Pages deploy): `https://<username>.github.io/messenger/`  
*Replace `<username>` with your GitHub username after you create the repo — or set a custom domain in repo Settings → Pages.*

[![Deploy to GitHub Pages](https://github.com/<username>/messenger/actions/workflows/deploy.yml/badge.svg)](https://github.com/<username>/messenger/actions)

## Stack

- **Frontend:** Flutter 3.44, Riverpod, go_router, supabase_flutter, flutter_webrtc, hive_flutter, wakelock_plus, image_picker / file_picker, cached_network_image
- **Backend:** Supabase Postgres + Auth (GoTrue) + Realtime (`postgres_changes` for messages, `broadcast` for typing/presence/call) + Storage
- **WebRTC:** P2P `flutter_webrtc` + STUN `stun.l.google.com:19302` + TURN `openrelay.metered.ca` (dev) → `coturn` self-hosted (prod)
- **Web live:** Flutter web → GitHub Pages via `actions/deploy-pages` (free, no Firebase needed)

## Screens (responsive — phone / tablet / desktop)

- Chats (conversations, pagination, `MessengerSearchBar` `ilike`, offline Hive queue)
- Chat thread (optimistic send, typing 300ms debounce, read receipts `sent→delivered→seen`, cursor pagination 20/msg)
- People (real users query, presence `is_online/last_seen` via broadcast)
- Stories, Calls (foreground voice/video P2P, draggable PiP, mute/speaker/camera/flip/end, 30s timeout → missed log)

Theme tokens: `#0084FF`, `light #FFF` / `dark #121214` (OLED, spec `darkBg #1C1C1E` used for `theme-color` dark), pill search, `StoryCircle` ring.

## Quick start (local)

```bash
flutter pub get

# Supabase keys — Cloud Free (30min) or self-hosted. Never commit .env.
flutter run \
  --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=eyJ... \
  --dart-define=TURN_URL=turn:openrelay.metered.ca:80 \
  --dart-define=TURN_URL2=turn:openrelay.metered.ca:443 \
  --dart-define=TURN_USER=openrelayproject \
  --dart-define=TURN_CRED=openrelayproject

# Or create .env locally (gitignored) — loader reads same dart-defines, .env.example for shape only
```

Supabase setup: apply `supabase/migrations/001_init.sql` (tables/indexes/RLS `conversation_participants` check), create Storage bucket `message-media` (public), add Auth email templates + `public.users` trigger on `auth.users` insert.

```bash
flutter analyze
flutter test
flutter build web --release --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
```

## Make it live on GitHub Pages (2 min) — $0 forever

This repo ships with `.github/workflows/deploy.yml` — builds web with correct `base-href` and deploys via **GitHub Actions → Pages** (artifact, no `gh-pages` branch).

**1. Create GitHub repo + push**
```bash
# in this folder:
git remote add origin https://github.com/<YOUR_USERNAME>/messenger.git
git branch -M master   # or main
git push -u origin master
# Or with GitHub CLI (installed):
gh auth login
gh repo create messenger --public --source=. --remote=origin --push
```

**2. Enable Pages → Actions**
- GitHub repo → Settings → Pages → Build and deployment → **Source: GitHub Actions**
- Add Secrets: Settings → Secrets and variables → Actions → New repository secret
  - `SUPABASE_URL` = `https://xxx.supabase.co`
  - `SUPABASE_ANON_KEY` = `eyJ...`
  - (optional) `TURN_URL`, `TURN_URL2`, `TURN_USER`, `TURN_CRED` — defaults to `openrelay.metered.ca` open TURN (free 20GB/mo)

**3. Push triggers deploy**
```bash
git push origin master
# Watch: GitHub → Actions → "Deploy Messenger Web to GitHub Pages" → green check
# URL: https://<YOUR_USERNAME>.github.io/messenger/
# Hard-refresh /home tests SPA 404 fallback (workflow copies index.html → 404.html)
```

**Base href note:** Workflow builds with `--base-href "/messenger/"` for project pages (`username.github.io/messenger`). For a user site (`username.github.io`) change to `"/"` in `deploy.yml`. For custom domain, keep `"/"` and set CNAME in Pages.

**Local Pages-like serve:**
```bash
flutter build web --base-href "/messenger/" --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
npx serve build/web
```

## Env vars

Via `--dart-define` (no secrets in repo):

```
SUPABASE_URL, SUPABASE_ANON_KEY
TURN_URL (default turn:openrelay.metered.ca:80)
TURN_URL2 (default turn:openrelay.metered.ca:443)
TURN_USER / TURN_CRED (default openrelayproject)
```

Self-host prod (Oracle Always-Free): Docker `supabase` + `coturn` (3478/5349, Let's Encrypt), switch env URLs — no code change.

## Structure

```
lib/main.dart                ProviderScope + Supabase.initialize + MaterialApp.router
lib/core/config/             app_router (go_router guard), supabase_config (isConfigured, iceServers)
lib/core/providers/          Riverpod auth + chat providers
lib/core/services/           supabase_service, storage_service (bytes API, web-safe), webrtc_service (P2P abstract)
lib/models/                  user, conversation, message, call_log
lib/features/chat/           chat_repository (optimistic + postgres_changes + broadcast typing)
lib/screens/                 splash (guard), login/register, chats, chat_thread, people, calls, call_screen, stories
lib/theme/                   messenger_theme + app_tokens (#0084FF, shimmer, radii)
lib/widgets/                 chat_tile, story_circle, messenger_search_bar, responsive_shell (compact/medium/expanded)
supabase/migrations/         001_init.sql (RLS, indexes)
web/                         index.html (loader, OG, a11y), manifest.json (PWA, shortcuts), icons
.github/workflows/deploy.yml  Build → artifact → deploy-pages (copies index.html→404.html, .nojekyll)
```

## Edge handling (MVP DoD)

- Offline: `Hive` queue `offline_queue` replays on reconnect; banner when `!isConfigured`
- Media caps: `<1MB` image / `<10MB` video client check, compress `imageQuality:70 / max 1024`
- Permissions: camera/mic denied → downgrade to audio + snackbar + `kIsWeb` branch (browser getUserMedia)
- Presence: dot in `chat_tile` + thread within 5s (broadcast)
- Call: ring → accept within 1s (both see video), mute/camera/flip/speaker, 30s missed → `call_logs`, airplane → `call:end`
- RLS: participant check `exists (select 1 from conversation_participants ... auth.uid())`, indexes `messages(conversation_id, created_at desc)`

## Tests & analysis

```bash
flutter analyze   # info-level only (withOpacity → withValues deprecations noted)
flutter test
```

## Roadmap (P1)

Group chats, LiveKit SFU, FCM + CallKit background (needs Apple Dev $99/yr), stories 24h + viewers, reactions/reply/forward/edit/delete, voice notes, pin/archive.

## License

Private — MVP spec FINAL v1.0 (`docs/build-spec.md`).
