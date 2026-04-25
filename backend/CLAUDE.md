# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Language

All code comments, server response messages, log output, and UI strings must be written in English.

## Project Structure

```
DayMatch/
├── backend/   # Node.js + Express REST API
└── frontend/  # Flutter mobile app
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
- `src/config/supabase.js` — Supabase client singleton; imported wherever DB or Auth access is needed
- `src/controllers/` — route handlers; all DB queries go through the Supabase client directly (no ORM)
- `src/middlewares/auth.js` — verifies Supabase JWT via `supabase.auth.getUser(token)`; attaches `req.user` (Supabase auth user object with `.email`)
- `src/middlewares/validate.js` — `requireFields(fields)` middleware for request body validation; `isValidEmail(email)` utility
- `src/routes/` — Express routers mounted at `/api`

**Auth endpoints:**

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| POST | `/api/auth/register` | — | Sign up; required: `email`, `password`, `name`, `gender` |
| POST | `/api/auth/login` | — | Sign in; returns `token`, `refreshToken`, `user` |
| POST | `/api/auth/logout` | Bearer | Invalidates session globally via Supabase REST API |
| POST | `/api/auth/refresh` | — | Exchange `refresh_token` for new `token` + `refreshToken` |
| GET  | `/api/auth/me` | Bearer | Returns full `public.user` row |
| POST | `/api/auth/forgot-password` | — | Sends password reset email |

**Auth implementation notes:**
- Register passes all profile fields via `supabase.auth.signUp({ options: { data: {...} } })`; a DB trigger (`handle_new_user`) inserts the row into `public.user` automatically
- Logout calls `POST /auth/v1/logout?scope=global` directly (Supabase REST API) — SDK `signOut()` does not reliably invalidate server-side sessions
- `protect` middleware (`src/middlewares/auth.js`) verifies the Bearer token via `supabase.auth.getUser(token)` and attaches `req.user`

## Frontend

**Stack:** Flutter (Dart), Dio, flutter_secure_storage

**Run:**
```bash
cd frontend
flutter pub get
flutter run          # requires a running emulator or device
flutter run -d chrome  # web
```

**Architecture:**
- `lib/core/api/api_client.dart` — singleton Dio client; auto-attaches Bearer token from secure storage on every request
- `lib/core/constants/api_constants.dart` — base URL and endpoint paths. **Switch `baseUrl` for target platform:**
  - Android emulator: `http://10.0.2.2:3000/api`
  - iOS simulator / physical device: `http://localhost:3000/api`
- `lib/features/<feature>/` — feature-first structure with `screens/`, `services/`, `models/` subdirectories
- `lib/main.dart` — app entry point; `_SplashGate` checks stored token and redirects to `/login` or `/home`

## Database (Supabase — project: nyu-daymatch)

Tables in `public` schema:
- `user` — `user_id` (bigint PK), `email`, `name`, `gender` (**NOT NULL**), `pronouns`, `college`, `ethnicity`, `age`, `birth_data`
- `event` — `event_id` (bigint PK), `user_id` (FK → user), `title`, `category`, `end_time`, `capacity`, `upload_time`
- `event_user_link` — `user_id` + `event_id` (composite PK, many-to-many join)

RLS is enabled on all tables. Policies on `public.user`:
- `users_insert_own` — authenticated users can INSERT where `email = auth.email()`
- `users_select_own` — authenticated users can SELECT their own row
- `users_update_own` — authenticated users can UPDATE their own row

DB trigger `on_auth_user_created` on `auth.users` → calls `public.handle_new_user()` (SECURITY DEFINER) to insert into `public.user` from `raw_user_meta_data` on every new signup.
