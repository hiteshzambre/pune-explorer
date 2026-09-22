# PuneExplorer — Backend Architecture & Cloud Integration Specification

## 1. Architectural Blueprint

PuneExplorer employs a unified cloud architecture where **Supabase (PostgreSQL 15+)** acts as the single source of truth for both the **Consumer Web Application** and the **Enterprise Admin Portal**.

```
                           ┌─────────────────────────────────────────┐
                           │      PuneExplorer Flutter Web App       │
                           │     (Consumer Web + Admin Portal)       │
                           └────────────────────┬────────────────────┘
                                                │
                                       HTTPS / WSS (SSL)
                                                │
                     ┌──────────────────────────┴──────────────────────────┐
                     │                                                     │
                     ▼                                                     ▼
      ┌──────────────────────────────┐                      ┌──────────────────────────────┐
      │   Supabase Auth & Session    │                      │       Supabase Storage       │
      │   - JWT Bearer Tokens        │                      │  - /destinations (public)    │
      │   - Role Claims & Profiles   │                      │  - /receipts (private RLS)   │
      │   - Auth State Change Stream │                      │  - /avatars (user managed)   │
      └──────────────┬───────────────┘                      └──────────────────────────────┘
                     │
                     ▼
      ┌────────────────────────────────────────────────────────────────────┐
      │                  PostgreSQL 15+ Relational Engine                  │
      │  ┌──────────────────────────────────────────────────────────────┐  │
      │  │ Row Level Security (RLS) on ALL tables                       │  │
      │  │ - Catalog: Public read-only, staff write via RBAC            │  │
      │  │ - Orders & Bookings: User-scoped isolation, staff oversight  │  │
      │  │ - Payment claims: UTR verification state machine             │  │
      │  └──────────────────────────────────────────────────────────────┘  │
      │  ┌──────────────────────────────────────────────────────────────┐  │
      │  │ Stored Functions & Triggers:                                 │  │
      │  │ - handle_new_user() on auth.users insert                     │  │
      │  │ - verify_payment_claim() atomic transaction                  │  │
      │  │ - validate_and_apply_coupon() pricing engine                 │  │
      │  │ - process_refund_claim() cancellation engine                 │  │
      │  └──────────────────────────────────────────────────────────────┘  │
      └──────────────────────────────────┬─────────────────────────────────┘
                                         │
                   ┌─────────────────────┴─────────────────────┐
                   ▼                                           ▼
    ┌──────────────────────────────┐            ┌──────────────────────────────┐
    │     Supabase Realtime        │            │   Deno Edge Functions        │
    │  - payments channel          │            │  - verify-payment (webhook)  │
    │  - bookings channel          │            │  - process-refund            │
    │  - support tickets channel   │            │  - admin-manage-user         │
    └──────────────────────────────┘            └──────────────────────────────┘
```

---

## 2. Key Subsystems

### 2.1 Supabase Auth & RBAC
- All identity operations run through Supabase GoTrue Auth.
- Profiles table (`public.profiles`) mirrors `auth.users`, maintaining avatar, full name, phone number, and user role.
- RBAC is enforced via `public.roles`, `public.permissions`, `public.user_roles`, and `public.role_permissions`.
- Database security helper functions `is_admin(uuid)` and `has_permission(uuid, text)` evaluate privileges in microseconds.

### 2.2 Relational PostgreSQL Database
- Comprises 30+ normalized tables covering destinations, tours, darshan circuits, heritage walks, bookings, payment orders, coupons, reviews, support tickets, and audit logs.
- Strict foreign key constraints and cascade rules maintain referential integrity.
- Automatic `updated_at` triggers maintain audit timestamps across all records.

### 2.3 Row Level Security (RLS)
- Every single public table has RLS explicitly enabled (`ALTER TABLE ... ENABLE ROW LEVEL SECURITY;`).
- Public catalog tables allow unrestricted read for active content, but mutations require verified administrative permissions.
- Customer records (bookings, payments, support tickets) are isolated so users can only read and modify their own records.

### 2.4 Supabase Storage
- Modular bucket hierarchy separating public media (destinations, tours, heritage walks, media library) from sensitive customer assets (payment receipts).
- Receipts bucket uses strict RLS allowing only the submitting customer or authorized finance staff (`verify_payments` permission) to view receipts.

### 2.5 Deno Edge Functions
- Privileged operations requiring the `service_role` key run strictly within server-side Edge Functions in Deno runtime.
- Edge functions authenticate caller JWT tokens and verify RBAC permissions before performing high-privilege tasks.

### 2.6 Dual-Mode Resilience & Offline Fallback
- The Flutter client inspects `SupabaseConfig.isConfigured` at runtime.
- When Supabase credentials are provided, the app connects directly to the cloud backend.
- When credentials are absent (e.g. during headless automated test runs or offline demo mode), the repository provider cleanly falls back to local in-memory repositories, ensuring 100% test suite reliability without external network dependencies.
