# PuneExplorer — Admin Roles, Permissions & RBAC Architecture Guide

## 1. Overview of Role-Based Access Control (RBAC)

PuneExplorer implements a strict, multi-tiered **Role-Based Access Control (RBAC)** model. Permissions are enforced at two distinct layers:
1. **Database Layer (RLS & RPCs)**: PostgreSQL verifies user claims and roles on every query.
2. **Presentation Layer (Flutter Web)**: UI elements, menu items, action buttons, and route guards adapt to the active staff profile.

`
┌─────────────────────────────────────────────────────────────┐
│                    User Account (auth.users)                │
└──────────────────────────────┬──────────────────────────────┘
                               │ 1:N
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                 Role Assignment (user_roles)                │
│             role: super_admin / content_admin / ...         │
└──────────────────────────────┬──────────────────────────────┘
                               │ N:M
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                 Role Permissions (role_permissions)        │
│    permissions: 'content.edit', 'payment.verify', ...       │
└─────────────────────────────────────────────────────────────┘
`

---

## 2. Standard Roles Matrix & Capability Grid

| Feature / Resource Area | Super Admin | Content Admin | Booking Admin | Support Admin | Analytics Viewer |
| :--- | :---: | :---: | :---: | :---: | :---: |
| **Manage Destinations & Tours** | ✅ Full | ✅ Full | ❌ No | ❌ No | 👁️ Read-Only |
| **Heritage Walks & Audio Guides**| ✅ Full | ✅ Full | ❌ No | ❌ No | 👁️ Read-Only |
| **Homepage CMS & Banners** | ✅ Full | ✅ Full | ❌ No | ❌ No | 👁️ Read-Only |
| **Media Library Uploads** | ✅ Full | ✅ Full | ❌ No | ❌ No | 👁️ Read-Only |
| **View Bookings & Rosters** | ✅ Full | ❌ No | ✅ Full | 👁️ Read-Only | 👁️ Read-Only |
| **Payment Claim Verification** | ✅ Full | ❌ No | ✅ Full | ❌ No | ❌ No |
| **Refund Processing** | ✅ Full | ❌ No | ✅ Full | ❌ No | ❌ No |
| **Customer Support Tickets** | ✅ Full | ❌ No | ❌ No | ✅ Full | 👁️ Read-Only |
| **Review Moderation** | ✅ Full | ❌ No | ❌ No | ✅ Full | 👁️ Read-Only |
| **Manage Admin Accounts & Roles**| ✅ Full | ❌ No | ❌ No | ❌ No | ❌ No |
| **Audit Logs & Security Trails**| ✅ Full | ❌ No | ❌ No | ❌ No | ❌ No |
| **System Settings & Backups** | ✅ Full | ❌ No | ❌ No | ❌ No | ❌ No |

---

## 3. Database Security Functions

PostgreSQL helper functions evaluate role privileges inside RLS policies and RPC routines without joining user tables redundantly.

### 3.1 is_admin() Function
`sql
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
AS 
  SELECT EXISTS (
    SELECT 1 FROM public.user_roles
    WHERE user_id = auth.uid()
    AND role IN ('super_admin', 'content_admin', 'booking_admin', 'support')
  );
;
`

### 3.2 has_permission(text) Function
`sql
CREATE OR REPLACE FUNCTION public.has_permission(required_perm text)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
AS 
  SELECT EXISTS (
    SELECT 1 FROM public.user_roles ur
    JOIN public.role_permissions rp ON ur.role = rp.role
    WHERE ur.user_id = auth.uid()
    AND (rp.permission = required_perm OR ur.role = 'super_admin')
  );
;
`

---

## 4. Administrative User Management (Deno Edge Function)

Client devices must **never** hold administrative service keys to create or elevate staff accounts. Staff provisioning is mediated through the secure Edge Function:
supabase/functions/admin-manage-user/index.ts.

### Invocation Pattern from Flutter Web:
`dart
Future<void> provisionStaffUser({
  required String email,
  required String password,
  required String fullName,
  required String role,
}) async {
  final res = await client.functions.invoke(
    'admin-manage-user',
    body: {
      'action': 'create',
      'email': email,
      'password': password,
      'fullName': fullName,
      'role': role,
    },
  );

  if (res.status != 200) {
    throw Exception(res.data['error'] ?? 'Staff provisioning failed');
  }
}
`

---

## 5. Audit Logging & Compliance

Every privilege elevation, ticket assignment, payment verification, and deletion is recorded to public.audit_logs:

`dart
await auditRepo.log(
  actorEmail: currentUser.email,
  actorRole: currentUser.role,
  action: 'PAYMENT_VERIFIED',
  resourceType: 'payment',
  resourceId: paymentId,
  metadata: {
    'booking_id': bookingId,
    'verified_amount': amount,
    'utr_number': utr,
  },
);
`
