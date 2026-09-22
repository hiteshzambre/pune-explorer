# PuneExplorer — Row Level Security (RLS) & Security Architecture

This document specifies the Row Level Security (RLS) architecture, access control matrix, and storage security policies for **PuneExplorer**.

---

## 1. Threat Model & Security Principles

1. **Defense-in-Depth**: Client-side logic in Flutter Web is treated as untrusted. Every database query, mutation, and file upload is validated at the PostgreSQL engine level via Row Level Security.
2. **Zero `service_role` Exposure**: The privileged Supabase `service_role` key is **never** embedded in Flutter code, JavaScript bundles, or client web environments.
3. **Strict Isolation**: Travelers can only read and mutate their own bookings, tickets, profile records, and payment receipts.
4. **RBAC via Database Functions**: Granular permissions (`verify_payments`, `manage_destinations`, `process_refunds`) are evaluated using `public.has_permission(auth.uid(), '<perm>')`.

---

## 2. Table-by-Table RLS Policy Matrix

| Table | Operations Allowed: Public | Operations Allowed: Authenticated Customer | Operations Allowed: Staff / Admin |
| :--- | :--- | :--- | :--- |
| `profiles` | `SELECT` (Public fields) | `SELECT`, `UPDATE` (own record where `auth.uid() = id`) | Full `SELECT`, `UPDATE` (via `is_admin`) |
| `roles` & `permissions` | None | `SELECT` (Read roles) | `manage_users` permission |
| `user_roles` | None | `SELECT` (own assigned roles) | Full management (via `manage_users`) |
| `destinations` | `SELECT` (where `is_active = true`) | `SELECT` (where `is_active = true`) | Full `ALL` (via `manage_destinations`) |
| `tours` | `SELECT` (where `is_active = true`) | `SELECT` (where `is_active = true`) | Full `ALL` (via `manage_tours`) |
| `darshan_circuits` | `SELECT` (where `is_active = true`) | `SELECT` (where `is_active = true`) | Full `ALL` (via `manage_tours`) |
| `heritage_walks` | `SELECT` (where `is_active = true`) | `SELECT` (where `is_active = true`) | Full `ALL` (via `manage_tours`) |
| `bookings` | None | `SELECT`, `INSERT`, `UPDATE` (own where `auth.uid() = user_id`) | Full `SELECT`, `UPDATE` (via `view_bookings` / `manage_bookings`) |
| `payments` | None | `SELECT`, `INSERT`, `UPDATE` (own where `auth.uid() = user_id`) | Full `SELECT`, `UPDATE` (via `verify_payments`) |
| `refund_requests` | None | `SELECT`, `INSERT` (own where `auth.uid() = user_id`) | Full `SELECT`, `UPDATE` (via `process_refunds`) |
| `coupons` | `SELECT` (where `is_active = true`) | `SELECT` (where `is_active = true`) | Full `ALL` (via `manage_coupons`) |
| `reviews` | `SELECT` (where `status = 'approved'`) | `INSERT`, `UPDATE`, `DELETE` (own reviews) | Full `ALL` (Moderation) |
| `support_tickets` | None | `SELECT`, `INSERT` (own where `auth.uid() = user_id`) | Full `ALL` (via `manage_support`) |
| `support_messages` | None | `SELECT`, `INSERT` (messages on own tickets) | Full `ALL` (via `manage_support`) |
| `app_settings` | `SELECT` (Public configurations) | `SELECT` (Public configurations) | Full `UPDATE` (via `manage_settings`) |
| `audit_logs` | None | None | `SELECT` only (via `view_audit_logs`) |

---

## 3. Storage Bucket Security Policies

### 3.1 Public Media Buckets
- Buckets: `destinations`, `tours`, `heritage-walks`, `media-library`, `branding`.
- `SELECT`: Unrestricted public read (`true`).
- `INSERT` / `UPDATE` / `DELETE`: Restricted to authenticated users with `public.is_admin(auth.uid()) = true`.

### 3.2 Private Customer Receipts (`receipts`)
- `SELECT`: Allowed ONLY if:
  1. The authenticated user is the payer: `(storage.foldername(name))[1] = auth.uid()::text`
  2. The caller has `verify_payments` permission: `public.has_permission(auth.uid(), 'verify_payments')`
- `INSERT`: Authenticated users can upload receipts only to their own user-scoped directory.

---

## 4. Atomic Database Security Functions

To prevent race conditions and Insecure Direct Object Reference (IDOR) attacks:
- **`verify_payment_claim()`**: Uses `FOR UPDATE` lock on the payment row, verifies current status, updates payment and booking atomically, and writes an audit log in the same database transaction.
- **`validate_and_apply_coupon()`**: Atomically inspects expiry dates, usage ceilings, and minimum booking thresholds inside PostgreSQL, preventing client-side discount tampering.
