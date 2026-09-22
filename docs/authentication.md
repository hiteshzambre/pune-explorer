# PuneExplorer — Supabase Authentication Architecture & Integration Guide

## 1. Overview

PuneExplorer leverages **Supabase Auth** (built on GoTrue and PostgreSQL) for identity management across both the **Consumer Web Application** and the **Enterprise Admin Portal & CMS**.

`
┌─────────────────────────────────────────────────────────────┐
│                      Client Interface                       │
│     (Consumer App / Admin Portal - Flutter Web 3.x)         │
└──────────────────────────────┬──────────────────────────────┘
                               │
            HTTPS / WSS        │ JWT Bearer & PKCE Flow
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                       Supabase Auth                         │
│   • Email + Password    • Google OAuth    • Magic Link OTP  │
└──────────────────────────────┬──────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                    PostgreSQL Engine                        │
│   • auth.users (Credentials, identities, metadata)          │
│   • public.handle_new_user() trigger (Automated sync)       │
│   • public.profiles (User profile, avatar, preferences)     │
│   • public.user_roles (RBAC role assignments)               │
└─────────────────────────────────────────────────────────────┘
`

---

## 2. Authentication Methods & Configuration

### 2.1 Email and Password
- **Default for both Consumers and Staff**.
- Password complexity requirements: minimum 8 characters, with letters and numbers.
- Handled natively via SupabaseClient.auth.signUp() and SupabaseClient.auth.signInWithPassword().

### 2.2 Google OAuth (Web PKCE Flow)
- Uses OAuth 2.0 with PKCE (Proof Key for Code Exchange) suited for Single Page Applications (Flutter Web).
- Configured in Supabase Console under **Authentication > Providers > Google**.
- Authorized redirect URLs configured:
  - Production: https://puneexplorer.web.app/
  - Local Dev: http://localhost:8080/, http://localhost:3000/

`dart
// Google Sign-In with PKCE redirect for Flutter Web
await Supabase.instance.client.auth.signInWithOAuth(
  OAuthProvider.google,
  redirectTo: kIsWeb ? null : 'puneexplorer://auth-callback',
);
`

### 2.3 Magic Link / OTP Authentication
- Frictionless email-based authentication for travelers who prefer passwordless login.
- Generates a secure, 6-digit OTP or time-limited verification link valid for 10 minutes.

---

## 3. Automated User Provisioning & Lifecycle Trigger

When an identity is confirmed in uth.users, a database trigger synchronously provisions records in public.profiles and public.user_roles. This guarantees relational integrity without relying on client-side creation hooks.

`sql
-- Trigger Function: Sync auth.users to public.profiles and public.user_roles
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS 
BEGIN
  -- Insert profile
  INSERT INTO public.profiles (id, email, full_name, avatar_url, role, status)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', 'Pune Explorer'),
    NEW.raw_user_meta_data->>'avatar_url',
    COALESCE(NEW.raw_user_meta_data->>'role', 'user'),
    'active'
  )
  ON CONFLICT (id) DO UPDATE SET
    email = EXCLUDED.email,
    full_name = COALESCE(EXCLUDED.full_name, profiles.full_name),
    avatar_url = COALESCE(EXCLUDED.avatar_url, profiles.avatar_url);

  -- Assign user role
  INSERT INTO public.user_roles (user_id, role_id)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'role', 'customer')
  )
  ON CONFLICT (user_id, role_id) DO NOTHING;

  RETURN NEW;
END;
;

-- Trigger definition on auth.users
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
`

---

## 4. Session Persistence & Token Refreshing

### 4.1 Web Storage Management
- On Flutter Web, supabase_flutter persists sessions via window.localStorage.
- Tokens are automatically renewed in the background before the 1-hour JWT expiration limit.
- Automatic recovery on browser refresh ensures uninterrupted user workflows.

### 4.2 Auth State Listener
The application listens to onAuthStateChange in Riverpod to drive reactive navigation:

`dart
Supabase.instance.client.auth.onAuthStateChange.listen((data) {
  final AuthChangeEvent event = data.event;
  final Session? session = data.session;

  switch (event) {
    case AuthChangeEvent.signedIn:
      ref.read(authNotifierProvider.notifier).syncUserSession(session);
      break;
    case AuthChangeEvent.signedOut:
      ref.read(authNotifierProvider.notifier).clearSession();
      break;
    case AuthChangeEvent.tokenRefreshed:
      debugPrint('Auth token refreshed successfully');
      break;
    default:
      break;
  }
});
`

---

## 5. Security & Production Checklist

1. **Email Confirmation**: Enable *Confirm Email* in production console to verify traveler email addresses before bookings.
2. **Brute Force Protection**: Configure Supabase rate limits (e.g. 5 sign-in attempts per 5 minutes per IP).
3. **Password Security**: Supabase securely stores password hashes with bcrypt; passwords are never transmitted or stored in plaintext.
4. **Token Security**: Never store raw JWT tokens or service-role keys in application state or code commits.
