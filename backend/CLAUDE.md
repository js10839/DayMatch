# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Language

All code comments, server response messages, log output, and UI strings must be written in English.

## Project Structure

```
DayMatch/
├── backend/   # Node.js + Express REST API
└── (root)/    # Flutter mobile app (lib/, ios/, android/, pubspec.yaml at repo root)
```

## Backend

**Stack:** Node.js, Express, `@supabase/supabase-js`

**Run:**
```bash
cd backend
npm run dev     # development (nodemon)
npm start       # production
```

**Environment (`backend/.env`):**
```
PORT=3000
NODE_ENV=development
SUPABASE_URL=https://vtwfibfhlqoarbseszde.supabase.co
SUPABASE_ANON_KEY=<anon key>
```

**Architecture:**
- `src/config/supabase.js` — Supabase client singleton. Used only for stateless calls (`auth.getUser(jwt)` in the protect middleware, plain `.from()` reads in non-auth controllers). **Never** call `signInWithIdToken` / `refreshSession` / `signInWithPassword` on this singleton — those mutate the client's session and would leak across concurrent requests.
- `src/controllers/authController.js` — uses local helpers `freshClient()` (for ID-token sign-in and refresh) and `clientWithToken(token)` (for any DB query that depends on `auth.email()` for RLS).
- `src/controllers/` — other route handlers; all DB queries go through Supabase directly (no ORM).
- `src/middlewares/auth.js` — verifies Supabase JWT via `supabase.auth.getUser(token)`; attaches `req.user` (Supabase auth user object with `.email`).
- `src/middlewares/validate.js` — `requireFields(fields)` middleware for request body validation; `isValidEmail(email)` utility.
- `src/routes/` — Express routers mounted at `/api`.

**Auth endpoints (Google-only sign-in):**

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| POST | `/api/auth/google` | — | Sign in with Google ID token; required: `id_token`. Rejects non-`@nyu.edu` emails with 403. Returns `token`, `refreshToken`, `user`, `hasProfile`. |
| POST | `/api/auth/profile` | Bearer | Complete the user profile after first Google sign-in; required: `gender`. Optional: `name`, `pronouns`, `college`, `ethnicity`, `age`, `birth_data`. |
| POST | `/api/auth/logout` | Bearer | Invalidates session globally via Supabase REST API. |
| POST | `/api/auth/refresh` | — | Exchange `refresh_token` for new `token` + `refreshToken`. |
| GET  | `/api/auth/me` | Bearer | Returns the `public.user` row for the caller and `hasProfile`. |

There are no email/password endpoints — `/register`, `/login`, `/forgot-password` were removed when the app pivoted to Google sign-in.

**Auth implementation notes:**
- `signInWithGoogle` calls `supabase.auth.signInWithIdToken({ provider: 'google', token })` on a `freshClient()`. If it's the user's first sign-in, the `handle_new_user` trigger automatically inserts a row into `public.user` with `email` and `name` (from Google's `raw_user_meta_data`); all other profile fields stay NULL.
- NYU domain check: if `data.user.email` does not end with `@nyu.edu`, the controller calls `POST /auth/v1/logout?scope=global` to revoke the session and returns 403. (The `auth.users` row still exists in Supabase but the session is dead and future sign-ins will be rejected the same way.)
- `hasProfile = !!user.gender` — `gender` is the sentinel for "profile completed". The Flutter splash gate uses this to decide between an empty `SignUpScreen` and the locked/`alreadyCompleted` view.
- `completeProfile` uses `clientWithToken(bearer)` so the UPDATE passes the `users_update_own` RLS policy (`email = auth.email()`).
- Logout calls `POST /auth/v1/logout?scope=global` directly (Supabase REST API) — SDK `signOut()` does not reliably invalidate server-side sessions.
- `protect` middleware verifies the Bearer token via `supabase.auth.getUser(token)` (stateless — does not mutate the singleton's session).

## Frontend

**Stack:** Flutter (Dart), `http`, `flutter_secure_storage`, `google_sign_in`.

**Run (from repo root):**
```bash
flutter pub get
flutter run             # requires emulator/device
flutter run -d chrome   # web
```

**Architecture:**
- `lib/services/auth_service.dart` — singleton `AuthService` with `signInWithGoogle` / `completeProfile` / `logout` / `getMe` / `getStoredToken`. Tokens are stored in `flutter_secure_storage`. Base URL is platform-aware (`10.0.2.2` for Android emulator, `localhost` otherwise).
- `lib/screens/sign_in_screen.dart` — single Google login button; on success branches by `hasProfile`.
- `lib/screens/sign_up_screen.dart` — profile completion form. Accepts `initialName` (prefilled from Google) and `alreadyCompleted` (locks the form for users that already finished sign-up).
- `lib/main.dart` — `_SplashGate` reads the stored token and (if present) calls `/me`; routes to `SignInScreen` (no token / invalid), `SignUpScreen` empty (token + `!hasProfile`), or `SignUpScreen` locked (token + `hasProfile`). There is no home screen yet.

**Google OAuth wiring:**
- `auth_service.dart` `_googleServerClientId` is the **Web** OAuth Client ID (also configured in Supabase → Auth → Providers → Google). With `serverClientId` set, the `idToken` returned by `GoogleSignIn` has audience = Web Client ID, which is what Supabase verifies.
- iOS: `ios/Runner/Info.plist` carries the iOS OAuth client's reversed Client ID as a URL scheme (used for the on-device OAuth flow only — not for token validation).
- Android (TODO): create an Android OAuth client with the SHA-1 of the signing key. `serverClientId` stays as the Web Client ID; no extra Flutter wiring needed beyond that.

## Database (Supabase — project: nyu-daymatch)

Tables in `public` schema:
- `user` — `user_id` (bigint PK), `email`, `name`, `gender` (**nullable** — NULL means profile not completed), `pronouns`, `college`, `ethnicity`, `age` (text), `birth_data` (date).
- `event` — `event_id` (bigint PK), `user_id` (FK → user), `title`, `category`, `end_time`, `capacity`, `upload_time`.
- `event_user_link` — `user_id` + `event_id` (composite PK, many-to-many join).

RLS is enabled on all tables. Policies on `public.user`:
- `users_insert_own` — authenticated users can INSERT where `email = auth.email()`.
- `users_select_own` — authenticated users can SELECT their own row.
- `users_update_own` — authenticated users can UPDATE their own row.

DB trigger `on_auth_user_created` on `auth.users` → calls `public.handle_new_user()` (SECURITY DEFINER) which inserts `(email, COALESCE(raw_user_meta_data->>'name', raw_user_meta_data->>'full_name'))` into `public.user`. The trigger does **not** populate any other profile fields — those are filled later via `/api/auth/profile`.
