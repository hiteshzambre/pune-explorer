# PuneExplorer — Supabase Setup & Installation Guide

This document provides end-to-end instructions for configuring Supabase for **PuneExplorer**, both for local development with the Supabase CLI and for production provisioning on Supabase Cloud.

---

## 1. Prerequisites

- **Docker Desktop** installed and running (for local development).
- **Node.js** (v18+) and **npm** or **Deno** installed.
- **Supabase CLI**:
  ```bash
  # Windows (via Scoop or npm)
  scoop bucket add supabase https://github.com/supabase/scoop-bucket.git
  scoop install supabase

  # Or via npm
  npm install -g supabase
  ```

---

## 2. Local Supabase Development

### 2.1 Initialize Local Stack
From the project root:
```bash
supabase init
```

### 2.2 Start Local Supabase
```bash
supabase start
```
This boots:
- PostgreSQL engine on `localhost:54322`
- PostgREST API on `localhost:54321`
- Supabase Studio Dashboard on `http://localhost:54323`
- Mailpit local email server on `http://localhost:54324`

### 2.3 Apply Database Migrations & Seeds
Run all SQL migrations located in `supabase/migrations/`:
```bash
supabase migration up
```

Apply Pune travel catalog seed data:
```bash
supabase db reset
# Or directly seed
psql -h localhost -p 54322 -U postgres -d postgres -f supabase/seed.sql
```

---

## 3. Cloud Project Setup (Supabase Cloud)

1. Navigate to [https://supabase.com/dashboard](https://supabase.com/dashboard) and create an organization and a new project named `pune-explorer-prod`.
2. Note your project credentials from **Settings > API**:
   - **Project URL**: `https://<project-ref>.supabase.co`
   - **Anon / Public Key**: `eyJhbGciOi...` (Safe for Flutter Web)
   - **Service Role Key**: `eyJhbGciOi...` (KEEP SECRET! Never put in Flutter code)
3. Link your local repository to the cloud project:
   ```bash
   supabase login
   supabase link --project-ref <project-ref>
   ```
4. Push all migrations and seed data:
   ```bash
   supabase db push
   ```

---

## 4. Deploying Edge Functions

Deploy the privileged Edge Functions to Supabase Cloud:
```bash
supabase functions deploy verify-payment
supabase functions deploy process-refund
supabase functions deploy admin-manage-user
```

Set required Edge Function secrets:
```bash
supabase secrets set SUPABASE_URL=https://<project-ref>.supabase.co
supabase secrets set SUPABASE_SERVICE_ROLE_KEY=<service-role-secret>
```

---

## 5. Running the Flutter Web Application with Supabase

Launch the Flutter Web app passing the Supabase environment variables:

```bash
# Debug development
flutter run -d chrome \
  --dart-define=SUPABASE_URL=https://<project-ref>.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=<anon-key>

# Production web build
flutter build web --release \
  --dart-define=SUPABASE_URL=https://<project-ref>.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=<anon-key>
```
