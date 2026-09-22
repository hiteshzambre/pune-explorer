-- ==============================================================================
-- PUNEEXPLORER — DATABASE SCHEMA MIGRATION 02: RBAC ROLES & PERMISSIONS
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- 1. ROLES & PERMISSIONS DEFINITION
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.roles (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT DEFAULT '',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.permissions (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  category TEXT NOT NULL DEFAULT 'general',
  description TEXT DEFAULT '',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.user_roles (
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  role_id TEXT NOT NULL REFERENCES public.roles(id) ON DELETE CASCADE,
  assigned_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
  assigned_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (user_id, role_id)
);

CREATE TABLE IF NOT EXISTS public.role_permissions (
  role_id TEXT NOT NULL REFERENCES public.roles(id) ON DELETE CASCADE,
  permission_id TEXT NOT NULL REFERENCES public.permissions(id) ON DELETE CASCADE,
  PRIMARY KEY (role_id, permission_id)
);

-- ------------------------------------------------------------------------------
-- 2. SEED DEFAULT ROLES
-- ------------------------------------------------------------------------------
INSERT INTO public.roles (id, name, description) VALUES
  ('super_admin', 'Super Administrator', 'Full unrestricted access to all operations, RBAC, financial actions, and audit logs.'),
  ('admin', 'Administrator', 'Operational access to content, bookings, payments, and refunds.'),
  ('editor', 'Content Editor', 'Manage destinations, tours, darshan, heritage walks, and CMS content.'),
  ('support', 'Support Staff', 'Handle support tickets, customer inquiries, and view bookings.'),
  ('customer', 'Customer', 'Browse catalog, create bookings, claim payments, and manage own profile.')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description;

-- ------------------------------------------------------------------------------
-- 3. SEED DEFAULT PERMISSIONS
-- ------------------------------------------------------------------------------
INSERT INTO public.permissions (id, name, category, description) VALUES
  ('manage_destinations', 'Manage Destinations', 'content', 'Create, update, and publish Pune destinations.'),
  ('manage_tours', 'Manage Tours', 'content', 'Create and modify tours, darshan circuits, and heritage walks.'),
  ('manage_cms', 'Manage CMS', 'content', 'Update homepage slides, sections, and announcements.'),
  ('manage_coupons', 'Manage Coupons', 'marketing', 'Create and manage discount codes and promotions.'),
  ('view_bookings', 'View All Bookings', 'operations', 'View complete list of traveler bookings.'),
  ('manage_bookings', 'Manage Bookings', 'operations', 'Confirm, reschedule, or cancel traveler bookings.'),
  ('verify_payments', 'Verify Payments', 'finance', 'Review UTR claims and approve or reject payments.'),
  ('process_refunds', 'Process Refunds', 'finance', 'Approve and disburse booking refund requests.'),
  ('manage_support', 'Manage Support Desk', 'customers', 'Respond to support tickets and manage inquiries.'),
  ('manage_users', 'Manage User Roles', 'security', 'Grant or revoke roles and manage user accounts.'),
  ('manage_settings', 'Manage Global Settings', 'system', 'Configure app branding, payment gateway UPI, and cutoffs.'),
  ('view_audit_logs', 'View Audit Logs', 'security', 'Access security and operational audit trails.')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  category = EXCLUDED.category,
  description = EXCLUDED.description;

-- Grant all permissions to super_admin
INSERT INTO public.role_permissions (role_id, permission_id)
SELECT 'super_admin', id FROM public.permissions
ON CONFLICT (role_id, permission_id) DO NOTHING;

-- Grant operational permissions to admin
INSERT INTO public.role_permissions (role_id, permission_id)
SELECT 'admin', id FROM public.permissions
WHERE id IN (
  'manage_destinations',
  'manage_tours',
  'manage_cms',
  'manage_coupons',
  'view_bookings',
  'manage_bookings',
  'verify_payments',
  'process_refunds',
  'manage_support',
  'manage_settings',
  'view_audit_logs'
)
ON CONFLICT (role_id, permission_id) DO NOTHING;

-- Grant content permissions to editor
INSERT INTO public.role_permissions (role_id, permission_id)
SELECT 'editor', id FROM public.permissions
WHERE id IN ('manage_destinations', 'manage_tours', 'manage_cms', 'manage_coupons')
ON CONFLICT (role_id, permission_id) DO NOTHING;

-- Grant support permissions to support
INSERT INTO public.role_permissions (role_id, permission_id)
SELECT 'support', id FROM public.permissions
WHERE id IN ('view_bookings', 'manage_support')
ON CONFLICT (role_id, permission_id) DO NOTHING;

-- ------------------------------------------------------------------------------
-- 4. SECURITY DEFINER HELPER FUNCTIONS
-- ------------------------------------------------------------------------------
-- Fast role check for admin
CREATE OR REPLACE FUNCTION public.is_admin(p_user_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
SECURITY DEFINER
STABLE
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.user_roles ur
    WHERE ur.user_id = p_user_id
      AND ur.role_id IN ('super_admin', 'admin')
  );
$$;

-- Granular permission check
CREATE OR REPLACE FUNCTION public.has_permission(p_user_id UUID, p_permission TEXT)
RETURNS BOOLEAN
LANGUAGE sql
SECURITY DEFINER
STABLE
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.user_roles ur
    JOIN public.role_permissions rp ON ur.role_id = rp.role_id
    WHERE ur.user_id = p_user_id
      AND (rp.permission_id = p_permission OR ur.role_id = 'super_admin')
  );
$$;

-- ------------------------------------------------------------------------------
-- 5. TRIGGER ON auth.users (AUTO-CREATE PROFILE & ASSIGN CUSTOMER ROLE)
-- ------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_role TEXT := 'customer';
BEGIN
  -- If user metadata specifies a default role, sanitize and apply
  IF NEW.raw_user_meta_data->>'role' = 'admin' THEN
    v_role := 'admin';
  END IF;

  INSERT INTO public.profiles (id, email, full_name, avatar_url, role)
  VALUES (
    NEW.id,
    COALESCE(NEW.email, ''),
    COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.raw_user_meta_data->>'name', 'Explorer'),
    COALESCE(NEW.raw_user_meta_data->>'avatar_url', ''),
    v_role
  )
  ON CONFLICT (id) DO UPDATE SET
    email = EXCLUDED.email,
    full_name = CASE WHEN profiles.full_name = '' THEN EXCLUDED.full_name ELSE profiles.full_name END;

  -- Assign user_role
  INSERT INTO public.user_roles (user_id, role_id)
  VALUES (NEW.id, v_role)
  ON CONFLICT (user_id, role_id) DO NOTHING;

  RETURN NEW;
END;
$$;

-- Attach trigger to auth.users
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
