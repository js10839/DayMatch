# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Layout

Monorepo with two app surfaces:

- **Root** — Flutter mobile app (Dart SDK `^3.11.4`). Standard layout: `lib/`, `ios/`, `android/`, `web/`, `pubspec.yaml`.
- **`backend/`** — Node.js + Express REST API backed by Supabase. See `backend/CLAUDE.md` for backend-specific details (auth flow, DB schema, RLS, triggers).

The Flutter app calls the backend at `http://localhost:3000/api` (or `http://10.0.2.2:3000/api` from an Android emulator); the backend then talks to Supabase using the JS client. **Chat is the exception** — `lib/screens/chat_screen.dart` writes to Firebase Firestore directly, bypassing Express. All other features go through Express → Supabase.

## Common Commands

**Backend** (run from `backend/`):
```bash
npm run dev    # nodemon — preferred for dev
npm start      # production
```
There are no test/lint commands in `backend/package.json`.

**Flutter** (run from repo root):
```bash
flutter pub get
flutter run                                  # requires emulator/device
flutter run -d <simulator-uuid>              # specific simulator
flutter run -d chrome --web-port=5555        # web (must use a fixed port — see iOS/Web Auth Gotchas)
flutter test                                 # all tests
flutter test test/widget_test.dart           # single test file
flutter analyze                              # lint via flutter_lints (analysis_options.yaml)
```

iOS pods need a re-install whenever a new native plugin lands: `cd ios && pod install`.

## Architecture

### Service singletons

`lib/services/auth_service.dart` and `lib/services/event_service.dart` are the only paths to the backend — UI never calls `http` directly. Both are singletons. `AuthService` owns token storage (`flutter_secure_storage`) and an in-memory `_cachedUser`; `EventService` reads `AuthService().accessToken` and `baseUrl` for every request.

`AuthService.currentUserId` is the bigint PK from `public.user` and is what every event-related backend call sends in its body. It's populated when `signInWithGoogle` / `completeProfile` / `getMe` returns, and cleared by `clearTokens()`.

### Splash gate (`lib/main.dart`)

`_SplashGate` is the app entry point. It branches on stored token + `hasProfile`:

| Stored token? | `hasProfile` | Destination |
|---|---|---|
| no | — | `SignInScreen` |
| yes, but `/me` returns 401 | — | `SignInScreen` (tokens cleared) |
| yes | `false` | `SignUpScreen` (profile completion) |
| yes | `true` | `HomeScreen` |

`hasProfile` from the backend is computed as `!!user.gender` — `gender` is the sentinel for "profile completed". Don't rely on any other field for that check.

### Backend-side patterns (cross-link)

`backend/src/controllers/authController.js` and `eventController.js` create **per-request** Supabase clients via local `freshClient()` / `clientWithToken(token)` helpers. **Never** call `signInWithIdToken` / `refreshSession` / `signInWithPassword` on the shared `backend/src/config/supabase.js` singleton — those mutate the client's session and would leak across concurrent requests. The singleton is reserved for stateless calls (`auth.getUser(jwt)` in the protect middleware).

RLS on every `public.*` table is keyed off `auth.email()` resolving to `public.user.user_id`. When adding new tables/policies, mirror the existing pattern: `user_id = (SELECT u.user_id FROM public.user u WHERE u.email = auth.email())`.

### Firebase scope

Firebase is initialized in `main.dart` (`Firebase.initializeApp(...)`) and used **only** by `chat_screen.dart` for Firestore-backed messaging. `firebase_auth` is in `pubspec.yaml` but **is not used** for sign-in — Google sign-in goes through `google_sign_in` → backend `/api/auth/google` → Supabase. Don't add Firebase Auth flows; they would conflict with the existing token model.

## iOS / Web Auth Gotchas

- **iOS Info.plist** must have both `GIDClientID` (iOS OAuth client) and `GIDServerClientID` (Web OAuth client, audience for the id_token Supabase validates) plus the reversed iOS client ID as a URL scheme. Without these, `GoogleSignIn` crashes with "No active configuration."
- **Web** rejects the `serverClientId` parameter on `GoogleSignIn(...)`. The constructor in `auth_service.dart` gates it with `kIsWeb ? null : _googleServerClientId`. Web reads the client ID from `<meta name="google-signin-client_id">` in `web/index.html`.
- **Supabase Dashboard → Auth → Providers → Google** must have **Skip nonce checks** enabled. The iOS GoogleSignIn SDK injects a nonce into the id_token but the Flutter package doesn't expose it, so we can't forward it; without skipping, Supabase rejects the token with "Passed nonce and nonce in id_token should either both exist or not."
- **Web dev** must run on a **fixed port** that's been added to the Web OAuth client's *Authorized JavaScript origins* in Google Cloud Console (the project standard is `http://localhost:5555`).

## Repo Quirks

- **Empty `frontend/` directory** at the root from an earlier reorganization. The live Flutter code is at the root, not inside `frontend/`.
- **Branch model:** `main` is the integration branch. A long-lived `frontend` branch gets periodically merged into `main` and tends to bring large screen / dependency churn each time.
- **`backend/.env`** holds `SUPABASE_URL` and `SUPABASE_ANON_KEY`; not committed.

## Language Convention

All code comments, server response messages, log output, and UI strings must be in English.
