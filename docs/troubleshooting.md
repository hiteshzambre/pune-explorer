# PuneExplorer — Production Troubleshooting & Diagnostics Guide

## 1. Common Errors & Resolution Matrix

| Error Code / Symptom | Root Cause | Immediate Resolution |
| :--- | :--- | :--- |
| **`42501 permission denied for table ...`** | Row Level Security (RLS) policy rejected query because user lacks matching role or claim. | Check `public.user_roles` table for active user ID; verify policy condition using SQL diagnostic below. |
| **`23505 duplicate key value violates unique constraint`** | Attempting to insert duplicate booking reference code, coupon code, or email. | Inspect incoming code; use `ON CONFLICT DO UPDATE` or generate random collision-free suffix. |
| **`AuthException: Invalid login credentials`** | Password mismatch or unconfirmed email address. | Check user status in `auth.users`; verify if email confirmation is required in project auth settings. |
| **`StorageException: Bucket not found`** | Requested bucket ID has not been created or schema migration not pushed. | Run `supabase/migrations/20260916000003_storage_buckets.sql` to initialize all 7 buckets. |
| **`CORS error on image load (Flutter Web)`** | Storage bucket missing CORS wildcard headers for custom web domain. | Update bucket CORS policy in Supabase Dashboard > Storage > Configuration to allow origin `*` or app domain. |
| **`WebSocket connection failed / Realtime drops`** | Corporate firewall or proxy blocking secure WebSockets (`wss://`). | Verify fallback to long-polling or test network; confirm table is added to `supabase_realtime` publication. |
| **`Edge Function 401 Unauthorized`** | Missing or invalid Authorization header or Bearer JWT token in invocation. | Ensure client passes user JWT via `client.functions.invoke()` or configure `--no-verify-jwt` if public webhook. |

---

## 2. SQL Diagnostic Queries

Execute these queries in the Supabase SQL Editor to rapidly isolate production anomalies.

### 2.1 Inspect User Roles & Permissions
```sql
-- Check assigned roles for a specific email
SELECT p.id, p.email, p.full_name, ur.role
FROM public.profiles p
LEFT JOIN public.user_roles ur ON p.id = ur.user_id
WHERE p.email = 'admin@puneexplorer.com';
```

### 2.2 Verify RLS Policies on Any Table
```sql
-- List all active RLS policies for bookings table
SELECT polname, polcmd, polroles, polqual, polwithcheck
FROM pg_policy
WHERE polrelid = 'public.bookings'::regclass;
```

### 2.3 Verify Storage Buckets
```sql
-- Check storage buckets and public flags
SELECT id, name, public, file_size_limit, allowed_mime_types
FROM storage.buckets;
```

### 2.4 Verify Realtime Publication Enrolment
```sql
-- Check which tables broadcast Realtime events
SELECT tablename
FROM pg_publication_tables
WHERE pubname = 'supabase_realtime';
```

---

## 3. Flutter Web Client Diagnostics

### 3.1 Inspecting Runtime Environment Flags
Verify that `--dart-define` credentials reached the running web bundle:
```dart
void checkSupabaseEnv() {
  debugPrint('Is Configured: ${SupabaseConfig.isConfigured}');
  debugPrint('Supabase URL: ${SupabaseConfig.url}');
  debugPrint('Anon Key Present: ${SupabaseConfig.anonKey.isNotEmpty}');
}
```

### 3.2 Inspecting Active Session in Browser Console
In Chrome DevTools > Application > Storage > Local Storage:
- Look for key `sb-<project-ref>-auth-token`.
- Decode the JWT at [jwt.io](https://jwt.io) to verify user `sub`, `role`, and token expiration (`exp`).

---

## 4. Deno Edge Functions Diagnostics

To inspect server-side execution logs in real-time:
```bash
# Stream live logs for a specific Edge Function
supabase functions logs verify-payment

# Inspect recent error stack traces
supabase functions logs process-refund --tail
```
