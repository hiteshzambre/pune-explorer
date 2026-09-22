# PuneExplorer — Production Deployment & Cloud Hosting Guide

## 1. Overview & Cloud Architecture

`
┌─────────────────────────────────────────────────────────────┐
│                 Hosting Layer (Cloudflare / Firebase)       │
│                Flutter Web 3.x Production Bundle            │
└──────────────────────────────┬──────────────────────────────┘
                               │ HTTPS (REST / GraphQL / Auth)
                               │ WSS (Realtime Streaming)
                               ▼
┌─────────────────────────────────────────────────────────────┐
│             Supabase Cloud (ap-south-1 Mumbai)              │
│   • Auth (GoTrue)           • PostgreSQL 15+ & RLS          │
│   • Storage Buckets (CDN)   • Deno Edge Functions           │
└─────────────────────────────────────────────────────────────┘
`

---

## 2. Supabase Cloud Project Setup

1. Create an organization and new project on [Supabase Dashboard](https://supabase.com/dashboard).
2. **Region Selection**: Select **South Asia (Mumbai) p-south-1** to ensure single-digit millisecond latency for travelers and administrators in Pune and Maharashtra.
3. Save your project credentials securely:
   - SUPABASE_URL: e.g., https://xyzprojectref.supabase.co
   - SUPABASE_ANON_KEY: public anonymous client key.
   - SUPABASE_SERVICE_ROLE_KEY: server-side secret (keep private, never bundle in Flutter code).

---

## 3. Database Migration Deployment

Deploy all schema migrations, RLS policies, triggers, and functions using the Supabase CLI:

`ash
# Authenticate CLI
supabase login

# Link local repository to your remote project
supabase link --project-ref <your-project-ref>

# Push all migrations in supabase/migrations/
supabase db push

# Apply seed data catalog
supabase db reset --seed
`

---

## 4. Deploying Deno Edge Functions

Deploy server-side privileged routines to Supabase's globally distributed Edge network:

`ash
# Deploy each function
supabase functions deploy verify-payment --no-verify-jwt
supabase functions deploy process-refund
supabase functions deploy admin-manage-user

# Set required environment secrets
supabase secrets set \
  SUPABASE_URL=https://<your-project-ref>.supabase.co \
  SUPABASE_SERVICE_ROLE_KEY=<your-service-role-key>
`

---

## 5. Flutter Web Production Build

Build the Flutter Web client by supplying compile-time --dart-define parameters. This compiles your credentials directly into web assembly / JavaScript while leaving zero sensitive service secrets exposed.

`ash
flutter build web --release \
  --dart-define=SUPABASE_URL=https://<your-project-ref>.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=<your-anon-key> \
  --pwa-strategy=none \
  --web-renderer canvaskit
`

### Static Hosting Deployments:

#### Firebase Hosting:
`ash
firebase deploy --only hosting
`

#### Cloudflare Pages:
Configure build settings:
- **Build command**: lutter build web --release --dart-define=SUPABASE_URL= --dart-define=SUPABASE_ANON_KEY=
- **Build output directory**: uild/web

---

## 6. Post-Deployment Verification Checklist

1. [ ] **Public Read**: Verify destinations and tours load on the homepage without requiring login.
2. [ ] **Authentication**: Create a new traveler account with email/password; check that public.profiles auto-populates.
3. [ ] **Booking Flow**: Complete a test tour booking; confirm record is written to public.bookings.
4. [ ] **Payment Verification**: Upload payment screenshot; verify admin can view receipt via signed URL and approve claim.
5. [ ] **Realtime Updates**: Confirm checkout screen updates to erified within 500ms of admin action.
6. [ ] **Admin RBAC**: Attempt to access /admin/users as a customer; confirm immediate rejection by RLS and router guard.
