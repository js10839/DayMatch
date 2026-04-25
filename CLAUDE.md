# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Layout

This is a monorepo with two app surfaces:

- **Root** — Flutter mobile app (Dart, SDK ^3.11.4). Standard Flutter layout: `lib/`, `ios/`, `android/`, `web/`, `pubspec.yaml`.
- **`backend/`** — Node.js + Express REST API backed by Supabase. See `backend/CLAUDE.md` for backend-specific details (auth flow, DB schema, RLS, triggers).

The two halves communicate over HTTP. The Flutter app calls the backend at `http://localhost:3000/api` (or `http://10.0.2.2:3000/api` from an Android emulator); the backend then talks to Supabase using the JS client.

## Common Commands

**Backend** (run from `backend/`):
```bash
npm run dev    # nodemon — auto-restarts on file changes (preferred for dev)
npm start      # production
```

**Flutter** (run from repo root):
```bash
flutter pub get
flutter run             # requires emulator/device
flutter run -d chrome   # web
flutter test            # all widget tests
flutter test test/widget_test.dart   # single test file
flutter analyze         # lint via flutter_lints (config in analysis_options.yaml)
```

There are no test or lint commands in `backend/package.json`.

## Architecture

### Backend → Supabase

The backend has no ORM — every controller imports the singleton Supabase client (`backend/src/config/supabase.js`) and queries directly. Two non-obvious patterns make the auth flow work and are easy to break:

1. **`handle_new_user` DB trigger.** Register does NOT insert into `public.user` directly. Instead, profile fields are passed via `supabase.auth.signUp({ options: { data: {...} } })`, and a `SECURITY DEFINER` trigger on `auth.users` reads `raw_user_meta_data` and inserts the row. This bypasses RLS and works even when the client doesn't yet have a session token.
2. **Logout uses the Supabase REST API directly**, not the JS SDK. The SDK's `signOut()` does not reliably invalidate server-side sessions when called from a stateless server context. The controller calls `POST /auth/v1/logout?scope=global` with the user's bearer token to revoke all sessions globally.

RLS policies on `public.user` enforce ownership via `email = auth.email()` — keep this constraint in mind when adding queries that touch the user table from authenticated requests.

### Flutter app

Currently minimal: `lib/main.dart` plus `lib/screens/sign_in_screen.dart` and `sign_up_screen.dart`. No state management library, no Dio/http client wired up yet — auth screens exist as UI but the API integration is still being built out. `google_sign_in`, `font_awesome_flutter`, and `google_fonts` are the only third-party deps beyond Flutter itself.

## Repo Quirks

- **Build artifacts are tracked.** `.gitignore` excludes `frontend/.dart_tool/` and `frontend/build/`, but the Flutter project lives at the root, so `.dart_tool/`, `build/`, `.idea/`, and `.flutter-plugins-dependencies` are committed. Don't reflexively `rm -rf` them — fix `.gitignore` first if cleaning up.
- **Empty `frontend/` directory** exists at the root from an earlier reorganization; the live Flutter code is at the root, not inside `frontend/`.
- **Branch model:** `main` is the integration branch. There is also a long-lived `frontend` branch that gets periodically merged into `main`.

## Language Convention

All code comments, server response messages, log output, and UI strings must be in English (carried over from `backend/CLAUDE.md`).
