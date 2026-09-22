-- ==============================================================================
-- FILE: 20260916000001_initial_schema.sql
-- ==============================================================================
-- ==============================================================================
-- PUNEEXPLORER — DATABASE SCHEMA MIGRATION 01: CORE TABLES & CONSTRAINTS
-- ==============================================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Helper function to auto-update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ------------------------------------------------------------------------------
-- 1. PROFILES (Extends Supabase auth.users)
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL,
  full_name TEXT NOT NULL DEFAULT '',
  phone TEXT DEFAULT '',
  avatar_url TEXT DEFAULT '',
  bio TEXT DEFAULT '',
  role TEXT NOT NULL DEFAULT 'customer',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER set_profiles_updated_at
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ------------------------------------------------------------------------------
-- 2. CATEGORIES & TAGS
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.categories (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT DEFAULT '',
  icon_name TEXT DEFAULT '',
  display_order INT NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.tags (
  id TEXT PRIMARY KEY,
  label TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ------------------------------------------------------------------------------
-- 3. DESTINATIONS (Historical, Forts, Gardens, Temples, etc.)
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.destinations (
  id TEXT PRIMARY KEY,
  slug TEXT NOT NULL UNIQUE,
  name TEXT NOT NULL,
  marathi_name TEXT NOT NULL DEFAULT '',
  category_id TEXT NOT NULL REFERENCES public.categories(id) ON DELETE RESTRICT,
  tag TEXT NOT NULL DEFAULT 'heritage',
  short_description TEXT NOT NULL DEFAULT '',
  full_description TEXT NOT NULL DEFAULT '',
  hero_image TEXT NOT NULL DEFAULT '',
  rating NUMERIC(3,2) NOT NULL DEFAULT 4.5,
  review_count INT NOT NULL DEFAULT 0,
  entry_fee NUMERIC(10,2) NOT NULL DEFAULT 0,
  best_time_to_visit TEXT NOT NULL DEFAULT 'October to March',
  timings TEXT NOT NULL DEFAULT '9:00 AM - 6:00 PM',
  ideal_duration TEXT NOT NULL DEFAULT '2-3 hours',
  latitude NUMERIC(10,6) NOT NULL DEFAULT 18.5204,
  longitude NUMERIC(10,6) NOT NULL DEFAULT 73.8567,
  address TEXT NOT NULL DEFAULT '',
  how_to_reach TEXT NOT NULL DEFAULT '',
  is_featured BOOLEAN NOT NULL DEFAULT false,
  is_trending BOOLEAN NOT NULL DEFAULT false,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER set_destinations_updated_at
  BEFORE UPDATE ON public.destinations
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE INDEX IF NOT EXISTS idx_destinations_category ON public.destinations(category_id);
CREATE INDEX IF NOT EXISTS idx_destinations_is_active ON public.destinations(is_active);
CREATE INDEX IF NOT EXISTS idx_destinations_is_featured ON public.destinations(is_featured);

-- Child tables for Destination details
CREATE TABLE IF NOT EXISTS public.destination_images (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  destination_id TEXT NOT NULL REFERENCES public.destinations(id) ON DELETE CASCADE,
  image_url TEXT NOT NULL,
  caption TEXT DEFAULT '',
  display_order INT NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.destination_highlights (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  destination_id TEXT NOT NULL REFERENCES public.destinations(id) ON DELETE CASCADE,
  highlight TEXT NOT NULL,
  display_order INT NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS public.destination_food_spots (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  destination_id TEXT NOT NULL REFERENCES public.destinations(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  speciality TEXT DEFAULT '',
  distance_meters INT DEFAULT 500,
  price_for_two NUMERIC(8,2) DEFAULT 300,
  display_order INT NOT NULL DEFAULT 0
);

-- ------------------------------------------------------------------------------
-- 4. TOUR PACKAGES
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.tours (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  subtitle TEXT NOT NULL DEFAULT '',
  tour_type TEXT NOT NULL DEFAULT 'trek', -- 'darshan', 'trek', 'heritage_walk', 'weekend_getaway'
  duration_days INT NOT NULL DEFAULT 1,
  duration_hours INT NOT NULL DEFAULT 8,
  price_per_person NUMERIC(10,2) NOT NULL,
  discounted_price NUMERIC(10,2),
  hero_image TEXT NOT NULL DEFAULT '',
  overview TEXT NOT NULL DEFAULT '',
  difficulty TEXT NOT NULL DEFAULT 'Easy',
  max_group_size INT NOT NULL DEFAULT 20,
  rating NUMERIC(3,2) NOT NULL DEFAULT 4.8,
  review_count INT NOT NULL DEFAULT 0,
  is_active BOOLEAN NOT NULL DEFAULT true,
  is_featured BOOLEAN NOT NULL DEFAULT false,
  inclusions JSONB NOT NULL DEFAULT '[]'::jsonb,
  exclusions JSONB NOT NULL DEFAULT '[]'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER set_tours_updated_at
  BEFORE UPDATE ON public.tours
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TABLE IF NOT EXISTS public.tour_itinerary_items (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  tour_id TEXT NOT NULL REFERENCES public.tours(id) ON DELETE CASCADE,
  day_number INT NOT NULL DEFAULT 1,
  time_slot TEXT NOT NULL,
  title TEXT NOT NULL,
  description TEXT NOT NULL DEFAULT '',
  display_order INT NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS public.tour_boarding_points (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  tour_id TEXT NOT NULL REFERENCES public.tours(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  landmark TEXT NOT NULL DEFAULT '',
  departure_time TEXT NOT NULL,
  display_order INT NOT NULL DEFAULT 0
);

-- ------------------------------------------------------------------------------
-- 5. PUNE DARSHAN CIRCUITS
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.darshan_circuits (
  id TEXT PRIMARY KEY,
  circuit_code TEXT NOT NULL UNIQUE,
  title TEXT NOT NULL,
  description TEXT NOT NULL DEFAULT '',
  departure_time TEXT NOT NULL DEFAULT '07:30 AM',
  return_time TEXT NOT NULL DEFAULT '06:00 PM',
  bus_type TEXT NOT NULL DEFAULT 'AC Electric Coach',
  fare_per_seat NUMERIC(10,2) NOT NULL DEFAULT 500,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.darshan_stops (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  circuit_id TEXT NOT NULL REFERENCES public.darshan_circuits(id) ON DELETE CASCADE,
  destination_id TEXT REFERENCES public.destinations(id) ON DELETE SET NULL,
  stop_name TEXT NOT NULL,
  arrival_time TEXT NOT NULL,
  duration_minutes INT NOT NULL DEFAULT 45,
  stop_order INT NOT NULL DEFAULT 1
);

-- ------------------------------------------------------------------------------
-- 6. HERITAGE WALKS
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.heritage_walks (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  tagline TEXT NOT NULL DEFAULT '',
  description TEXT NOT NULL DEFAULT '',
  hero_image TEXT NOT NULL DEFAULT '',
  duration_minutes INT NOT NULL DEFAULT 120,
  distance_km NUMERIC(4,2) NOT NULL DEFAULT 2.5,
  difficulty TEXT NOT NULL DEFAULT 'Easy',
  start_point TEXT NOT NULL,
  end_point TEXT NOT NULL,
  ticket_price NUMERIC(10,2) NOT NULL DEFAULT 299,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.heritage_walk_stops (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  walk_id TEXT NOT NULL REFERENCES public.heritage_walks(id) ON DELETE CASCADE,
  stop_number INT NOT NULL,
  title TEXT NOT NULL,
  historical_context TEXT NOT NULL DEFAULT '',
  latitude NUMERIC(10,6) NOT NULL,
  longitude NUMERIC(10,6) NOT NULL,
  audio_url TEXT DEFAULT '',
  image_url TEXT DEFAULT '',
  display_order INT NOT NULL DEFAULT 0
);

-- ------------------------------------------------------------------------------
-- 7. BOOKINGS & TRAVELERS
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.bookings (
  id TEXT PRIMARY KEY,
  booking_code TEXT NOT NULL UNIQUE,
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  tour_id TEXT NOT NULL,
  booking_type TEXT NOT NULL DEFAULT 'tour', -- 'tour', 'darshan', 'walk'
  booking_date DATE NOT NULL DEFAULT CURRENT_DATE,
  travel_date DATE NOT NULL,
  boarding_point TEXT NOT NULL DEFAULT 'Swargate',
  total_travelers INT NOT NULL DEFAULT 1,
  total_amount NUMERIC(10,2) NOT NULL,
  discount_amount NUMERIC(10,2) NOT NULL DEFAULT 0,
  final_amount NUMERIC(10,2) NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending', -- 'pending', 'confirmed', 'cancelled', 'completed'
  payment_status TEXT NOT NULL DEFAULT 'unpaid', -- 'unpaid', 'under_verification', 'paid', 'refunded'
  notes TEXT DEFAULT '',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER set_bookings_updated_at
  BEFORE UPDATE ON public.bookings
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE INDEX IF NOT EXISTS idx_bookings_user ON public.bookings(user_id);
CREATE INDEX IF NOT EXISTS idx_bookings_status ON public.bookings(status);
CREATE INDEX IF NOT EXISTS idx_bookings_travel_date ON public.bookings(travel_date);

CREATE TABLE IF NOT EXISTS public.booking_travelers (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  booking_id TEXT NOT NULL REFERENCES public.bookings(id) ON DELETE CASCADE,
  full_name TEXT NOT NULL,
  age INT NOT NULL DEFAULT 25,
  gender TEXT NOT NULL DEFAULT 'Other',
  is_lead_traveler BOOLEAN NOT NULL DEFAULT false,
  contact_phone TEXT DEFAULT '',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ------------------------------------------------------------------------------
-- 8. PAYMENTS & UTR VERIFICATIONS
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.payments (
  id TEXT PRIMARY KEY,
  order_id TEXT NOT NULL UNIQUE,
  booking_id TEXT NOT NULL REFERENCES public.bookings(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  amount NUMERIC(10,2) NOT NULL,
  status TEXT NOT NULL DEFAULT 'created', -- 'created', 'under_verification', 'verified', 'rejected', 'refunded'
  payment_method TEXT NOT NULL DEFAULT 'UPI_QR',
  upi_transaction_id TEXT, -- Customer claimed UTR
  receipt_url TEXT,
  merchant_upi_id TEXT NOT NULL DEFAULT 'puneexplorer@icici',
  merchant_name TEXT NOT NULL DEFAULT 'PuneExplorer Tourism',
  verified_by TEXT,
  verified_at TIMESTAMPTZ,
  rejection_reason TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER set_payments_updated_at
  BEFORE UPDATE ON public.payments
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE INDEX IF NOT EXISTS idx_payments_status ON public.payments(status);
CREATE INDEX IF NOT EXISTS idx_payments_booking ON public.payments(booking_id);
CREATE INDEX IF NOT EXISTS idx_payments_utr ON public.payments(upi_transaction_id);

-- ------------------------------------------------------------------------------
-- 9. REFUND REQUESTS
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.refund_requests (
  id TEXT PRIMARY KEY,
  refund_code TEXT NOT NULL UNIQUE,
  booking_id TEXT NOT NULL REFERENCES public.bookings(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  customer_name TEXT NOT NULL DEFAULT '',
  customer_email TEXT NOT NULL DEFAULT '',
  original_amount NUMERIC(10,2) NOT NULL,
  cancellation_fee NUMERIC(10,2) NOT NULL DEFAULT 0,
  refund_amount NUMERIC(10,2) NOT NULL,
  reason TEXT NOT NULL DEFAULT '',
  status TEXT NOT NULL DEFAULT 'requested', -- 'requested', 'review', 'approved', 'rejected', 'processing', 'completed'
  approved_by TEXT,
  processed_at TIMESTAMPTZ,
  notes TEXT DEFAULT '',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER set_refund_requests_updated_at
  BEFORE UPDATE ON public.refund_requests
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ------------------------------------------------------------------------------
-- 10. COUPONS & PROMOTIONS
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.coupons (
  id TEXT PRIMARY KEY,
  code TEXT NOT NULL UNIQUE,
  title TEXT NOT NULL,
  description TEXT NOT NULL DEFAULT '',
  discount_type TEXT NOT NULL DEFAULT 'percentage', -- 'percentage', 'flat'
  discount_value NUMERIC(10,2) NOT NULL,
  min_booking_amount NUMERIC(10,2) NOT NULL DEFAULT 0,
  max_discount_amount NUMERIC(10,2) NOT NULL DEFAULT 1000,
  valid_from TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  valid_until TIMESTAMPTZ NOT NULL,
  usage_limit INT NOT NULL DEFAULT 1000,
  times_used INT NOT NULL DEFAULT 0,
  applicable_category TEXT DEFAULT 'ALL',
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.coupon_redemptions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  coupon_id TEXT NOT NULL REFERENCES public.coupons(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  booking_id TEXT NOT NULL REFERENCES public.bookings(id) ON DELETE CASCADE,
  discount_applied NUMERIC(10,2) NOT NULL,
  redeemed_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ------------------------------------------------------------------------------
-- 11. REVIEWS & RATINGS
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.reviews (
  id TEXT PRIMARY KEY,
  destination_id TEXT REFERENCES public.destinations(id) ON DELETE CASCADE,
  tour_id TEXT REFERENCES public.tours(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  author_name TEXT NOT NULL,
  rating NUMERIC(2,1) NOT NULL DEFAULT 5.0,
  title TEXT NOT NULL DEFAULT '',
  comment TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'approved', -- 'pending', 'approved', 'rejected'
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_reviews_destination ON public.reviews(destination_id);
CREATE INDEX IF NOT EXISTS idx_reviews_tour ON public.reviews(tour_id);

-- ------------------------------------------------------------------------------
-- 12. FAQS & NOTIFICATIONS
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.faqs (
  id TEXT PRIMARY KEY,
  question TEXT NOT NULL,
  answer TEXT NOT NULL,
  category TEXT NOT NULL DEFAULT 'General',
  display_order INT NOT NULL DEFAULT 0,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.notifications (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  category TEXT NOT NULL DEFAULT 'General',
  priority TEXT NOT NULL DEFAULT 'normal', -- 'normal', 'high', 'urgent'
  target_audience TEXT NOT NULL DEFAULT 'all',
  is_active BOOLEAN NOT NULL DEFAULT true,
  valid_from TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  valid_until TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ------------------------------------------------------------------------------
-- 13. CUSTOMER SUPPORT TICKETS & MESSAGES
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.support_tickets (
  id TEXT PRIMARY KEY,
  ticket_code TEXT NOT NULL UNIQUE,
  user_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
  customer_name TEXT NOT NULL,
  customer_email TEXT NOT NULL,
  customer_phone TEXT DEFAULT '',
  subject TEXT NOT NULL,
  category TEXT NOT NULL DEFAULT 'General Inquiry',
  priority TEXT NOT NULL DEFAULT 'medium', -- 'low', 'medium', 'high', 'urgent'
  status TEXT NOT NULL DEFAULT 'open', -- 'open', 'in_progress', 'resolved', 'closed'
  booking_id TEXT REFERENCES public.bookings(id) ON DELETE SET NULL,
  assigned_to TEXT DEFAULT '',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER set_support_tickets_updated_at
  BEFORE UPDATE ON public.support_tickets
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TABLE IF NOT EXISTS public.support_messages (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  ticket_id TEXT NOT NULL REFERENCES public.support_tickets(id) ON DELETE CASCADE,
  sender_id TEXT NOT NULL,
  sender_name TEXT NOT NULL,
  sender_type TEXT NOT NULL DEFAULT 'customer', -- 'customer', 'staff', 'system'
  message TEXT NOT NULL,
  is_internal_note BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_support_messages_ticket ON public.support_messages(ticket_id);

-- ------------------------------------------------------------------------------
-- 14. CMS (HOMEPAGE SLIDES, SECTIONS, MEDIA)
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.homepage_slides (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  subtitle TEXT NOT NULL DEFAULT '',
  image_url TEXT NOT NULL,
  cta_text TEXT NOT NULL DEFAULT 'Explore Now',
  cta_route TEXT NOT NULL DEFAULT '/explore',
  display_order INT NOT NULL DEFAULT 0,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.homepage_sections (
  id TEXT PRIMARY KEY,
  section_key TEXT NOT NULL UNIQUE,
  title TEXT NOT NULL,
  subtitle TEXT NOT NULL DEFAULT '',
  is_visible BOOLEAN NOT NULL DEFAULT true,
  display_order INT NOT NULL DEFAULT 0,
  metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.media_assets (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  file_name TEXT NOT NULL,
  file_url TEXT NOT NULL,
  file_size INT NOT NULL DEFAULT 0,
  mime_type TEXT NOT NULL DEFAULT 'image/jpeg',
  category TEXT NOT NULL DEFAULT 'general',
  dimensions TEXT DEFAULT '',
  uploaded_by TEXT DEFAULT '',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ------------------------------------------------------------------------------
-- 15. GLOBAL APP SETTINGS & AUDIT LOGS
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.app_settings (
  key TEXT PRIMARY KEY,
  value JSONB NOT NULL,
  description TEXT DEFAULT '',
  updated_by TEXT DEFAULT '',
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.audit_logs (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  user_email TEXT NOT NULL,
  action TEXT NOT NULL,
  entity_type TEXT NOT NULL,
  entity_id TEXT NOT NULL,
  old_values JSONB,
  new_values JSONB,
  ip_address TEXT DEFAULT '',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_audit_logs_action ON public.audit_logs(action);
CREATE INDEX IF NOT EXISTS idx_audit_logs_created_at ON public.audit_logs(created_at DESC);


-- ==============================================================================
-- FILE: 20260916000002_roles_and_permissions.sql
-- ==============================================================================
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


-- ==============================================================================
-- FILE: 20260916000003_storage_buckets.sql
-- ==============================================================================
-- ==============================================================================
-- PUNEEXPLORER — DATABASE SCHEMA MIGRATION 03: STORAGE BUCKETS & POLICIES
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- 1. INITIALIZE STORAGE BUCKETS
-- ------------------------------------------------------------------------------
INSERT INTO storage.buckets (id, name, public) VALUES
  ('destinations', 'destinations', true),
  ('tours', 'tours', true),
  ('heritage-walks', 'heritage-walks', true),
  ('media-library', 'media-library', true),
  ('branding', 'branding', true),
  ('receipts', 'receipts', false),
  ('avatars', 'avatars', true)
ON CONFLICT (id) DO UPDATE SET
  public = EXCLUDED.public;

-- ------------------------------------------------------------------------------
-- 2. ENABLE RLS ON STORAGE OBJECTS
-- ------------------------------------------------------------------------------
-- Storage objects table has RLS enabled by default in Supabase

-- ------------------------------------------------------------------------------
-- 3. PUBLIC BUCKETS READ ACCESS
-- ------------------------------------------------------------------------------
CREATE POLICY "Public Read for Public Buckets"
  ON storage.objects FOR SELECT
  USING (bucket_id IN ('destinations', 'tours', 'heritage-walks', 'media-library', 'branding', 'avatars'));

-- ------------------------------------------------------------------------------
-- 4. STAFF WRITE ACCESS FOR CONTENT BUCKETS
-- ------------------------------------------------------------------------------
CREATE POLICY "Staff Manage Content Media"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id IN ('destinations', 'tours', 'heritage-walks', 'media-library', 'branding')
    AND auth.role() = 'authenticated'
    AND public.is_admin(auth.uid())
  );

CREATE POLICY "Staff Update Content Media"
  ON storage.objects FOR UPDATE
  USING (
    bucket_id IN ('destinations', 'tours', 'heritage-walks', 'media-library', 'branding')
    AND auth.role() = 'authenticated'
    AND public.is_admin(auth.uid())
  );

CREATE POLICY "Staff Delete Content Media"
  ON storage.objects FOR DELETE
  USING (
    bucket_id IN ('destinations', 'tours', 'heritage-walks', 'media-library', 'branding')
    AND auth.role() = 'authenticated'
    AND public.is_admin(auth.uid())
  );

-- ------------------------------------------------------------------------------
-- 5. AVATARS USER ACCESS
-- ------------------------------------------------------------------------------
CREATE POLICY "Authenticated Users Upload Avatar"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'avatars'
    AND auth.role() = 'authenticated'
    AND (storage.foldername(name))[1] = auth.uid()::text
  );

CREATE POLICY "Users Update Own Avatar"
  ON storage.objects FOR UPDATE
  USING (
    bucket_id = 'avatars'
    AND auth.role() = 'authenticated'
    AND (storage.foldername(name))[1] = auth.uid()::text
  );

-- ------------------------------------------------------------------------------
-- 6. PAYMENT RECEIPTS (PRIVATE & SECURE)
-- ------------------------------------------------------------------------------
CREATE POLICY "Customer Upload Payment Receipt"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'receipts'
    AND auth.role() = 'authenticated'
  );

CREATE POLICY "View Payment Receipt Policy"
  ON storage.objects FOR SELECT
  USING (
    bucket_id = 'receipts'
    AND auth.role() = 'authenticated'
    AND (
      -- Payer who uploaded receipt
      (storage.foldername(name))[1] = auth.uid()::text
      -- Or staff authorized to verify payments
      OR public.has_permission(auth.uid(), 'verify_payments')
    )
  );


-- ==============================================================================
-- FILE: 20260916000004_rls_policies.sql
-- ==============================================================================
-- ==============================================================================
-- PUNEEXPLORER — DATABASE SCHEMA MIGRATION 04: ROW LEVEL SECURITY POLICIES
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- 1. ENABLE ROW LEVEL SECURITY ON ALL TABLES
-- ------------------------------------------------------------------------------
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.permissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.role_permissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.destinations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.destination_images ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.destination_highlights ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.destination_food_spots ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tours ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tour_itinerary_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tour_boarding_points ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.darshan_circuits ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.darshan_stops ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.heritage_walks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.heritage_walk_stops ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.booking_travelers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.refund_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.coupons ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.coupon_redemptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.faqs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.support_tickets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.support_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.homepage_slides ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.homepage_sections ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.media_assets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.app_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.audit_logs ENABLE ROW LEVEL SECURITY;

-- ------------------------------------------------------------------------------
-- 2. PROFILES & ROLES POLICIES
-- ------------------------------------------------------------------------------
CREATE POLICY "Public profiles are viewable by everyone"
  ON public.profiles FOR SELECT
  USING (true);

CREATE POLICY "Users can insert their own profile"
  ON public.profiles FOR INSERT
  WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can update own profile or staff update"
  ON public.profiles FOR UPDATE
  USING (auth.uid() = id OR public.is_admin(auth.uid()));

CREATE POLICY "Roles are viewable by authenticated users"
  ON public.roles FOR SELECT
  USING (auth.role() = 'authenticated');

CREATE POLICY "Permissions viewable by authenticated users"
  ON public.permissions FOR SELECT
  USING (auth.role() = 'authenticated');

CREATE POLICY "User roles viewable by self or admin"
  ON public.user_roles FOR SELECT
  USING (user_id = auth.uid() OR public.is_admin(auth.uid()));

CREATE POLICY "Admin manage user roles"
  ON public.user_roles FOR ALL
  USING (public.has_permission(auth.uid(), 'manage_users'));

-- ------------------------------------------------------------------------------
-- 3. PUBLIC CATALOG POLICIES (DESTINATIONS, TOURS, DARSHAN, WALKS)
-- ------------------------------------------------------------------------------
-- Categories & Tags
CREATE POLICY "Categories viewable by everyone"
  ON public.categories FOR SELECT USING (true);
CREATE POLICY "Staff manage categories"
  ON public.categories FOR ALL
  USING (public.is_admin(auth.uid()));

CREATE POLICY "Tags viewable by everyone"
  ON public.tags FOR SELECT USING (true);
CREATE POLICY "Staff manage tags"
  ON public.tags FOR ALL
  USING (public.is_admin(auth.uid()));

-- Destinations
CREATE POLICY "Public view active destinations or staff view all"
  ON public.destinations FOR SELECT
  USING (is_active = true OR public.is_admin(auth.uid()));

CREATE POLICY "Staff manage destinations"
  ON public.destinations FOR ALL
  USING (public.has_permission(auth.uid(), 'manage_destinations'));

CREATE POLICY "Public view destination images"
  ON public.destination_images FOR SELECT USING (true);
CREATE POLICY "Staff manage destination images"
  ON public.destination_images FOR ALL
  USING (public.has_permission(auth.uid(), 'manage_destinations'));

CREATE POLICY "Public view destination highlights"
  ON public.destination_highlights FOR SELECT USING (true);
CREATE POLICY "Staff manage destination highlights"
  ON public.destination_highlights FOR ALL
  USING (public.has_permission(auth.uid(), 'manage_destinations'));

CREATE POLICY "Public view destination food spots"
  ON public.destination_food_spots FOR SELECT USING (true);
CREATE POLICY "Staff manage destination food spots"
  ON public.destination_food_spots FOR ALL
  USING (public.has_permission(auth.uid(), 'manage_destinations'));

-- Tours
CREATE POLICY "Public view active tours or staff view all"
  ON public.tours FOR SELECT
  USING (is_active = true OR public.is_admin(auth.uid()));

CREATE POLICY "Staff manage tours"
  ON public.tours FOR ALL
  USING (public.has_permission(auth.uid(), 'manage_tours'));

CREATE POLICY "Public view tour itinerary"
  ON public.tour_itinerary_items FOR SELECT USING (true);
CREATE POLICY "Staff manage tour itinerary"
  ON public.tour_itinerary_items FOR ALL
  USING (public.has_permission(auth.uid(), 'manage_tours'));

CREATE POLICY "Public view tour boarding points"
  ON public.tour_boarding_points FOR SELECT USING (true);
CREATE POLICY "Staff manage tour boarding points"
  ON public.tour_boarding_points FOR ALL
  USING (public.has_permission(auth.uid(), 'manage_tours'));

-- Darshan Circuits
CREATE POLICY "Public view active darshan circuits"
  ON public.darshan_circuits FOR SELECT
  USING (is_active = true OR public.is_admin(auth.uid()));

CREATE POLICY "Staff manage darshan circuits"
  ON public.darshan_circuits FOR ALL
  USING (public.has_permission(auth.uid(), 'manage_tours'));

CREATE POLICY "Public view darshan stops"
  ON public.darshan_stops FOR SELECT USING (true);
CREATE POLICY "Staff manage darshan stops"
  ON public.darshan_stops FOR ALL
  USING (public.has_permission(auth.uid(), 'manage_tours'));

-- Heritage Walks
CREATE POLICY "Public view active heritage walks"
  ON public.heritage_walks FOR SELECT
  USING (is_active = true OR public.is_admin(auth.uid()));

CREATE POLICY "Staff manage heritage walks"
  ON public.heritage_walks FOR ALL
  USING (public.has_permission(auth.uid(), 'manage_tours'));

CREATE POLICY "Public view heritage walk stops"
  ON public.heritage_walk_stops FOR SELECT USING (true);
CREATE POLICY "Staff manage heritage walk stops"
  ON public.heritage_walk_stops FOR ALL
  USING (public.has_permission(auth.uid(), 'manage_tours'));

-- ------------------------------------------------------------------------------
-- 4. BOOKINGS & TRAVELERS POLICIES
-- ------------------------------------------------------------------------------
CREATE POLICY "Users view own bookings or staff view all"
  ON public.bookings FOR SELECT
  USING (auth.uid() = user_id OR public.has_permission(auth.uid(), 'view_bookings'));

CREATE POLICY "Authenticated users create booking"
  ON public.bookings FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users update own pending booking or staff manage"
  ON public.bookings FOR UPDATE
  USING (auth.uid() = user_id OR public.has_permission(auth.uid(), 'manage_bookings'));

CREATE POLICY "View booking travelers"
  ON public.booking_travelers FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.bookings b
      WHERE b.id = booking_travelers.booking_id
        AND (b.user_id = auth.uid() OR public.has_permission(auth.uid(), 'view_bookings'))
    )
  );

CREATE POLICY "Insert booking travelers"
  ON public.booking_travelers FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.bookings b
      WHERE b.id = booking_travelers.booking_id
        AND b.user_id = auth.uid()
    )
  );

-- ------------------------------------------------------------------------------
-- 5. PAYMENTS POLICIES
-- ------------------------------------------------------------------------------
CREATE POLICY "Users view own payments or staff view all"
  ON public.payments FOR SELECT
  USING (auth.uid() = user_id OR public.has_permission(auth.uid(), 'verify_payments'));

CREATE POLICY "Users create payment claim"
  ON public.payments FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users submit transaction id or staff verify"
  ON public.payments FOR UPDATE
  USING (auth.uid() = user_id OR public.has_permission(auth.uid(), 'verify_payments'));

-- ------------------------------------------------------------------------------
-- 6. REFUND REQUESTS POLICIES
-- ------------------------------------------------------------------------------
CREATE POLICY "Users view own refunds or staff view all"
  ON public.refund_requests FOR SELECT
  USING (auth.uid() = user_id OR public.has_permission(auth.uid(), 'process_refunds'));

CREATE POLICY "Users submit refund request"
  ON public.refund_requests FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Staff process refund requests"
  ON public.refund_requests FOR UPDATE
  USING (public.has_permission(auth.uid(), 'process_refunds'));

-- ------------------------------------------------------------------------------
-- 7. COUPONS POLICIES
-- ------------------------------------------------------------------------------
CREATE POLICY "Public view active coupons or staff view all"
  ON public.coupons FOR SELECT
  USING (is_active = true OR public.has_permission(auth.uid(), 'manage_coupons'));

CREATE POLICY "Staff manage coupons"
  ON public.coupons FOR ALL
  USING (public.has_permission(auth.uid(), 'manage_coupons'));

CREATE POLICY "Users view own redemptions"
  ON public.coupon_redemptions FOR SELECT
  USING (auth.uid() = user_id OR public.is_admin(auth.uid()));

CREATE POLICY "Users record redemption"
  ON public.coupon_redemptions FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- ------------------------------------------------------------------------------
-- 8. REVIEWS & RATINGS POLICIES
-- ------------------------------------------------------------------------------
CREATE POLICY "Public view approved reviews or author view own"
  ON public.reviews FOR SELECT
  USING (status = 'approved' OR auth.uid() = user_id OR public.is_admin(auth.uid()));

CREATE POLICY "Authenticated users submit review"
  ON public.reviews FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users edit own review or staff moderate"
  ON public.reviews FOR UPDATE
  USING (auth.uid() = user_id OR public.is_admin(auth.uid()));

CREATE POLICY "Users delete own review or staff delete"
  ON public.reviews FOR DELETE
  USING (auth.uid() = user_id OR public.is_admin(auth.uid()));

-- ------------------------------------------------------------------------------
-- 9. FAQS & NOTIFICATIONS POLICIES
-- ------------------------------------------------------------------------------
CREATE POLICY "Public view active faqs"
  ON public.faqs FOR SELECT
  USING (is_active = true OR public.is_admin(auth.uid()));

CREATE POLICY "Staff manage faqs"
  ON public.faqs FOR ALL
  USING (public.has_permission(auth.uid(), 'manage_cms'));

CREATE POLICY "Public view active notifications"
  ON public.notifications FOR SELECT
  USING (is_active = true OR public.is_admin(auth.uid()));

CREATE POLICY "Staff manage notifications"
  ON public.notifications FOR ALL
  USING (public.has_permission(auth.uid(), 'manage_cms'));

-- ------------------------------------------------------------------------------
-- 10. SUPPORT TICKETS & MESSAGES POLICIES
-- ------------------------------------------------------------------------------
CREATE POLICY "Users view own tickets or staff view all"
  ON public.support_tickets FOR SELECT
  USING (user_id = auth.uid() OR public.has_permission(auth.uid(), 'manage_support'));

CREATE POLICY "Users create support ticket"
  ON public.support_tickets FOR INSERT
  WITH CHECK (auth.uid() = user_id OR user_id IS NULL);

CREATE POLICY "Staff manage support tickets"
  ON public.support_tickets FOR UPDATE
  USING (public.has_permission(auth.uid(), 'manage_support'));

CREATE POLICY "Users view messages for accessible tickets"
  ON public.support_messages FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.support_tickets t
      WHERE t.id = support_messages.ticket_id
        AND (t.user_id = auth.uid() OR public.has_permission(auth.uid(), 'manage_support'))
    )
    AND (is_internal_note = false OR public.has_permission(auth.uid(), 'manage_support'))
  );

CREATE POLICY "Users and staff post messages"
  ON public.support_messages FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.support_tickets t
      WHERE t.id = support_messages.ticket_id
        AND (t.user_id = auth.uid() OR public.has_permission(auth.uid(), 'manage_support'))
    )
  );

-- ------------------------------------------------------------------------------
-- 11. CMS & MEDIA POLICIES
-- ------------------------------------------------------------------------------
CREATE POLICY "Public view homepage slides"
  ON public.homepage_slides FOR SELECT USING (true);
CREATE POLICY "Staff manage homepage slides"
  ON public.homepage_slides FOR ALL
  USING (public.has_permission(auth.uid(), 'manage_cms'));

CREATE POLICY "Public view homepage sections"
  ON public.homepage_sections FOR SELECT USING (true);
CREATE POLICY "Staff manage homepage sections"
  ON public.homepage_sections FOR ALL
  USING (public.has_permission(auth.uid(), 'manage_cms'));

CREATE POLICY "Public view media assets"
  ON public.media_assets FOR SELECT USING (true);
CREATE POLICY "Staff manage media assets"
  ON public.media_assets FOR ALL
  USING (public.has_permission(auth.uid(), 'manage_cms'));

-- ------------------------------------------------------------------------------
-- 12. APP SETTINGS & AUDIT LOGS POLICIES
-- ------------------------------------------------------------------------------
CREATE POLICY "Public read app settings"
  ON public.app_settings FOR SELECT USING (true);
CREATE POLICY "Staff manage app settings"
  ON public.app_settings FOR ALL
  USING (public.has_permission(auth.uid(), 'manage_settings'));

CREATE POLICY "Staff view audit logs"
  ON public.audit_logs FOR SELECT
  USING (public.has_permission(auth.uid(), 'view_audit_logs'));

CREATE POLICY "Authenticated users record audit log"
  ON public.audit_logs FOR INSERT
  WITH CHECK (auth.role() = 'authenticated');


-- ==============================================================================
-- FILE: 20260916000005_functions_and_triggers.sql
-- ==============================================================================
-- ==============================================================================
-- PUNEEXPLORER — DATABASE SCHEMA MIGRATION 05: RPC FUNCTIONS & REALTIME
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- 1. ATOMIC PAYMENT CLAIM VERIFICATION
-- ------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.verify_payment_claim(
  p_order_id TEXT,
  p_verified_by TEXT,
  p_notes TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_payment RECORD;
  v_booking RECORD;
BEGIN
  -- 1. Find payment record
  SELECT * INTO v_payment
  FROM public.payments
  WHERE order_id = p_order_id
  FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Payment order with ID % not found.', p_order_id;
  END IF;

  IF v_payment.status = 'verified' THEN
    RAISE EXCEPTION 'Payment order % is already verified.', p_order_id;
  END IF;

  -- 2. Update payment record
  UPDATE public.payments
  SET
    status = 'verified',
    verified_by = p_verified_by,
    verified_at = NOW(),
    rejection_reason = NULL,
    updated_at = NOW()
  WHERE order_id = p_order_id;

  -- 3. Update booking record
  UPDATE public.bookings
  SET
    status = 'confirmed',
    payment_status = 'paid',
    notes = CASE
      WHEN p_notes IS NOT NULL AND p_notes <> ''
      THEN COALESCE(notes, '') || E'\nPayment Verified: ' || p_notes
      ELSE notes
    END,
    updated_at = NOW()
  WHERE id = v_payment.booking_id
  RETURNING * INTO v_booking;

  -- 4. Record audit log
  INSERT INTO public.audit_logs (
    id, user_id, user_email, action, entity_type, entity_id, old_values, new_values
  ) VALUES (
    'audit_' || extract(epoch from now())::bigint || '_' || substr(md5(random()::text), 1, 6),
    p_verified_by,
    p_verified_by,
    'PAYMENT_VERIFIED',
    'payment',
    p_order_id,
    jsonb_build_object('previous_status', v_payment.status, 'amount', v_payment.amount),
    jsonb_build_object('status', 'verified', 'verified_by', p_verified_by, 'booking_id', v_payment.booking_id)
  );

  RETURN jsonb_build_object(
    'success', true,
    'order_id', p_order_id,
    'booking_id', v_payment.booking_id,
    'amount', v_payment.amount,
    'verified_by', p_verified_by,
    'verified_at', NOW()
  );
END;
$$;

-- ------------------------------------------------------------------------------
-- 2. ATOMIC PAYMENT REJECTION
-- ------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.reject_payment_claim(
  p_order_id TEXT,
  p_reason TEXT,
  p_rejected_by TEXT
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_payment RECORD;
BEGIN
  SELECT * INTO v_payment
  FROM public.payments
  WHERE order_id = p_order_id
  FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Payment order with ID % not found.', p_order_id;
  END IF;

  UPDATE public.payments
  SET
    status = 'rejected',
    rejection_reason = p_reason,
    verified_by = p_rejected_by,
    updated_at = NOW()
  WHERE order_id = p_order_id;

  -- Update booking back to unpaid pending
  UPDATE public.bookings
  SET
    status = 'pending',
    payment_status = 'unpaid',
    updated_at = NOW()
  WHERE id = v_payment.booking_id;

  -- Record audit log
  INSERT INTO public.audit_logs (
    id, user_id, user_email, action, entity_type, entity_id, old_values, new_values
  ) VALUES (
    'audit_' || extract(epoch from now())::bigint || '_' || substr(md5(random()::text), 1, 6),
    p_rejected_by,
    p_rejected_by,
    'PAYMENT_REJECTED',
    'payment',
    p_order_id,
    jsonb_build_object('previous_status', v_payment.status),
    jsonb_build_object('status', 'rejected', 'reason', p_reason, 'rejected_by', p_rejected_by)
  );

  RETURN jsonb_build_object(
    'success', true,
    'order_id', p_order_id,
    'status', 'rejected',
    'reason', p_reason
  );
END;
$$;

-- ------------------------------------------------------------------------------
-- 3. VALIDATE AND APPLY COUPON
-- ------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.validate_and_apply_coupon(
  p_code TEXT,
  p_booking_amount NUMERIC,
  p_user_id UUID DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_coupon RECORD;
  v_discount NUMERIC := 0;
  v_final NUMERIC;
BEGIN
  -- Normalize code
  p_code := UPPER(TRIM(p_code));

  SELECT * INTO v_coupon
  FROM public.coupons
  WHERE UPPER(code) = p_code;

  IF NOT FOUND THEN
    RETURN jsonb_build_object('valid', false, 'message', 'Coupon code does not exist.');
  END IF;

  IF NOT v_coupon.is_active THEN
    RETURN jsonb_build_object('valid', false, 'message', 'This coupon is no longer active.');
  END IF;

  IF v_coupon.valid_from > NOW() THEN
    RETURN jsonb_build_object('valid', false, 'message', 'This promotional coupon has not started yet.');
  END IF;

  IF v_coupon.valid_until < NOW() THEN
    RETURN jsonb_build_object('valid', false, 'message', 'This coupon has expired.');
  END IF;

  IF v_coupon.times_used >= v_coupon.usage_limit THEN
    RETURN jsonb_build_object('valid', false, 'message', 'Coupon usage limit has been reached.');
  END IF;

  IF p_booking_amount < v_coupon.min_booking_amount THEN
    RETURN jsonb_build_object(
      'valid', false,
      'message', 'Minimum booking amount of ₹' || v_coupon.min_booking_amount || ' required for this coupon.'
    );
  END IF;

  -- Calculate discount
  IF v_coupon.discount_type = 'percentage' THEN
    v_discount := ROUND((p_booking_amount * (v_coupon.discount_value / 100.0)), 2);
    IF v_discount > v_coupon.max_discount_amount THEN
      v_discount := v_coupon.max_discount_amount;
    END IF;
  ELSE
    -- Flat discount
    v_discount := v_coupon.discount_value;
  END IF;

  IF v_discount > p_booking_amount THEN
    v_discount := p_booking_amount;
  END IF;

  v_final := p_booking_amount - v_discount;

  RETURN jsonb_build_object(
    'valid', true,
    'code', v_coupon.code,
    'discount_type', v_coupon.discount_type,
    'discount_value', v_coupon.discount_value,
    'discount_amount', v_discount,
    'original_amount', p_booking_amount,
    'final_amount', v_final,
    'message', 'Coupon applied successfully!'
  );
END;
$$;

-- ------------------------------------------------------------------------------
-- 4. PROCESS REFUND CLAIM
-- ------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.process_refund_claim(
  p_refund_id TEXT,
  p_status TEXT,
  p_deduction_fee NUMERIC,
  p_notes TEXT,
  p_admin_id TEXT
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_refund RECORD;
  v_calculated_refund NUMERIC;
BEGIN
  SELECT * INTO v_refund
  FROM public.refund_requests
  WHERE id = p_refund_id
  FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Refund request with ID % not found.', p_refund_id;
  END IF;

  v_calculated_refund := v_refund.original_amount - COALESCE(p_deduction_fee, 0);
  IF v_calculated_refund < 0 THEN
    v_calculated_refund := 0;
  END IF;

  UPDATE public.refund_requests
  SET
    status = p_status,
    cancellation_fee = COALESCE(p_deduction_fee, cancellation_fee),
    refund_amount = v_calculated_refund,
    notes = COALESCE(p_notes, notes),
    approved_by = p_admin_id,
    processed_at = NOW(),
    updated_at = NOW()
  WHERE id = p_refund_id;

  -- If approved or completed, update booking status
  IF p_status IN ('approved', 'completed') THEN
    UPDATE public.bookings
    SET
      status = 'cancelled',
      payment_status = 'refunded',
      updated_at = NOW()
    WHERE id = v_refund.booking_id;
  END IF;

  RETURN jsonb_build_object(
    'success', true,
    'refund_id', p_refund_id,
    'status', p_status,
    'refund_amount', v_calculated_refund,
    'processed_at', NOW()
  );
END;
$$;

-- ------------------------------------------------------------------------------
-- 5. REALTIME PUBLICATION SUBSCRIPTIONS
-- ------------------------------------------------------------------------------
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_publication WHERE pubname = 'supabase_realtime') THEN
    EXECUTE 'ALTER PUBLICATION supabase_realtime ADD TABLE public.payments';
    EXECUTE 'ALTER PUBLICATION supabase_realtime ADD TABLE public.bookings';
    EXECUTE 'ALTER PUBLICATION supabase_realtime ADD TABLE public.support_tickets';
    EXECUTE 'ALTER PUBLICATION supabase_realtime ADD TABLE public.support_messages';
    EXECUTE 'ALTER PUBLICATION supabase_realtime ADD TABLE public.notifications';
  END IF;
EXCEPTION WHEN OTHERS THEN
  -- Table may already be in publication; ignore gracefully
  NULL;
END;
$$;


-- ==============================================================================
-- FILE: seed.sql
-- ==============================================================================
-- ==============================================================================
-- PUNEEXPLORER — DATABASE SEED DATA (DESTINATIONS, TOURS, WALKS, COUPONS, FAQS)
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- 1. CATEGORIES & TAGS SEED
-- ------------------------------------------------------------------------------
INSERT INTO public.categories (id, name, description, icon_name, display_order) VALUES
  ('historical', 'Historical & Forts', 'Ancient forts, wadas, and historical palaces of Maratha heritage', 'fort', 1),
  ('religious', 'Temples & Spiritual', 'Sacred temples, shrines, and darshan pilgrimage sites', 'temple', 2),
  ('nature', 'Nature & Viewpoints', 'Scenic hills, botanical gardens, lakes, and trekking trails', 'nature', 3),
  ('museum', 'Museums & Culture', 'Renowned art, artifact, and historical collections', 'museum', 4),
  ('food', 'Culinary & Culture', 'Famous food hubs, Puneri misal, and heritage sweet shops', 'restaurant', 5)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description;

INSERT INTO public.tags (id, label) VALUES
  ('heritage', 'Heritage'),
  ('trek', 'Sahyadri Trek'),
  ('spiritual', 'Spiritual'),
  ('scenic', 'Scenic Viewpoint'),
  ('family', 'Family Friendly'),
  ('budget', 'Budget Friendly')
ON CONFLICT (id) DO NOTHING;

-- ------------------------------------------------------------------------------
-- 2. DESTINATIONS SEED
-- ------------------------------------------------------------------------------
INSERT INTO public.destinations (
  id, slug, name, marathi_name, category_id, tag, short_description, full_description,
  hero_image, rating, review_count, entry_fee, best_time_to_visit, timings, ideal_duration,
  latitude, longitude, address, how_to_reach, is_featured, is_trending, is_active
) VALUES
  (
    'shaniwar-wada',
    'shaniwar-wada',
    'Shaniwar Wada',
    'शनिवार वाडा',
    'historical',
    'heritage',
    'Historical 18th-century fortification of the Peshwa rulers in Pune.',
    'Built in 1732 by Peshwa Baji Rao I, Shaniwar Wada served as the seat of the Peshwa rulers of the Maratha Empire until 1818. The fortress features massive spiked teakwood gates (Delhi Darwaza), intricate fountain gardens including the Hazari Karanje, and foundational stone plinths of the original seven-storey palace.',
    'https://images.unsplash.com/photo-1590050752117-238cb0fb12b1?w=1200&q=80',
    4.6, 1280, 25.0,
    'October to March',
    '8:00 AM - 6:30 PM (Light & Sound: 7:00 PM)',
    '2 hours',
    18.5196, 73.8553,
    'Shaniwar Peth, Pune, Maharashtra 411030',
    'Easily accessible via PMPML bus routes to Shaniwar Wada depot or Pune Metro Civil Court Station.',
    true, true, true
  ),
  (
    'aga-khan-palace',
    'aga-khan-palace',
    'Aga Khan Palace',
    'आगाखान पॅलेस',
    'historical',
    'heritage',
    'Majestic palace and memorial where Mahatma Gandhi was interned during the Freedom Movement.',
    'Constructed in 1892 by Sultan Muhammad Shah Aga Khan III as an act of charity to help famine-struck villagers. In 1942, Mahatma Gandhi, Kasturba Gandhi, and Mahadev Desai were imprisoned here during the Quit India Movement. The Italian arches and sprawling lawns house Kasturba Gandhi’s samadhi memorial.',
    'https://images.unsplash.com/photo-1582510003544-4d00b7f74220?w=1200&q=80',
    4.7, 940, 50.0,
    'October to February',
    '9:00 AM - 5:30 PM',
    '2-3 hours',
    18.5524, 73.9015,
    'Pune-Nagar Road, Kalyani Nagar, Pune, Maharashtra 411006',
    'Located along Ahmednagar Highway, near Kalyani Nagar Metro Station. Direct auto-rickshaws available from Pune Junction.',
    true, true, true
  ),
  (
    'sinhagad-fort',
    'sinhagad-fort',
    'Sinhagad Fort',
    'सिंहगड किल्ला',
    'historical',
    'trek',
    'Legendary hill fortress atop the Sahyadri mountains with sweeping vistas and military history.',
    'Perched at 1,312 meters above sea level, Sinhagad is immortalized by Tanaji Malusare’s valiant 1670 battle. It commands 360-degree views of Khadakwasla Dam and the Western Ghats. Famous for rural Maharashtrian delicacy stalls serving steaming hot Kanda Bhaji, Pithla Bhakri, and chilled matka dahi.',
    'https://images.unsplash.com/photo-1578632767115-351597cf2477?w=1200&q=80',
    4.8, 3420, 20.0,
    'June to February (Monsoon & Winter)',
    '6:00 AM - 6:00 PM',
    'Half day (4-5 hours)',
    18.3663, 73.7558,
    'Sinhagad Ghat Road, Thoptewadi, Maharashtra 411025',
    '30 km from Pune center. Direct PMPML buses ply from Swargate to Sinhagad Paytha (foothills). Shared jeeps drive to top gate.',
    true, true, true
  ),
  (
    'dagdusheth-ganpati',
    'dagdusheth-ganpati',
    'Shreemant Dagdusheth Halwai Ganpati Temple',
    'श्रीमंत दगडूशेठ हलवाई गणपती',
    'religious',
    'spiritual',
    'One of the most revered and visited Ganesh temples in Maharashtra.',
    'Founded in 1893 by sweet merchant Dagdusheth Gadve and his wife Lakshmibai after losing their son to the plague, this temple is the beating heart of Pune’s Ganeshotsav. The gold-adorned Ganpati idol is admired by millions of devotees and tourists worldwide.',
    'https://images.unsplash.com/photo-1567157577867-05ccb1388e66?w=1200&q=80',
    4.9, 5100, 0.0,
    'Year-round (Special during Ganeshotsav)',
    '6:00 AM - 10:30 PM',
    '1 hour',
    18.5165, 73.8560,
    'Ganpati Bhavan, 250, Budhwar Peth, Pune 411002',
    'Located in central Budhwar Peth, 5 minutes walk from Shaniwar Wada and Mandai Metro Station.',
    true, true, true
  ),
  (
    'pataleshwar-cave',
    'pataleshwar-cave',
    'Pataleshwar Cave Temple',
    'पाताळेश्वर गुहा मंदिर',
    'historical',
    'heritage',
    'Monolithic 8th-century rock-cut Shiva cave temple carved from basalt rock.',
    'Carved during the Rashtrakuta dynasty in the 8th century CE, this underground basalt cave temple honors Lord Shiva with a massive circular Nandi mandapa on stone pillars. Shaded by grand banyan trees on bustling JM Road.',
    'https://images.unsplash.com/photo-1544735716-392fe2489ffa?w=1200&q=80',
    4.5, 870, 0.0,
    'October to March',
    '8:30 AM - 5:30 PM',
    '1 hour',
    18.5283, 73.8504,
    'Jangali Maharaj Road, Shivajinagar, Pune 411005',
    'Walking distance from Shivajinagar Railway Station and PMC Metro Station.',
    false, false, true
  ),
  (
    'parvati-hill',
    'parvati-hill',
    'Parvati Hill & Peshwa Museum',
    'पार्वती टेकडी',
    'historical',
    'scenic',
    'Scenic hilltop with 103 stone steps offering panoramic city views and historic Peshwa temples.',
    'Standing 640 meters above sea level, Parvati Hill features a cluster of five 18th-century Peshwa-era temples dedicated to Devdeveshwar, Kartikeya, Vishnu, and Vitthal. The hill features the Peshwa Museum housing original Maratha artifacts, coins, and portraits.',
    'https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=1200&q=80',
    4.6, 1150, 0.0,
    'Early morning & late evening year-round',
    '5:00 AM - 8:00 PM',
    '2 hours',
    18.4975, 73.8475,
    'Parvati Paytha, Pune 411009',
    'Near Swargate bus terminus. Accessible by auto or city bus to Parvati Paytha.',
    false, true, true
  )
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  marathi_name = EXCLUDED.marathi_name,
  short_description = EXCLUDED.short_description,
  full_description = EXCLUDED.full_description,
  hero_image = EXCLUDED.hero_image,
  entry_fee = EXCLUDED.entry_fee,
  best_time_to_visit = EXCLUDED.best_time_to_visit,
  timings = EXCLUDED.timings,
  latitude = EXCLUDED.latitude,
  longitude = EXCLUDED.longitude,
  address = EXCLUDED.address;

-- Destination Highlights
INSERT INTO public.destination_highlights (destination_id, highlight, display_order) VALUES
  ('shaniwar-wada', 'Delhi Darwaza with anti-elephant spikes', 1),
  ('shaniwar-wada', 'Hazari Karanje (Thousand Jet Fountain)', 2),
  ('shaniwar-wada', 'Evening Light & Sound Show in Marathi and English', 3),
  ('sinhagad-fort', 'Kalyan Darwaza and Pune Darwaza fortifications', 1),
  ('sinhagad-fort', 'Authentic Pithla Bhakri, Thecha & Matka Dahi stalls', 2),
  ('sinhagad-fort', 'Tanaji Malusare Samadhi and memorial memorial', 3),
  ('aga-khan-palace', 'Kasturba Gandhi and Mahadev Desai Samadhis', 1),
  ('aga-khan-palace', 'Italian architectural arches and 19-acre lawns', 2),
  ('aga-khan-palace', 'Gandhi National Memorial museum galleries', 3);

-- Destination Food Spots
INSERT INTO public.destination_food_spots (destination_id, name, speciality, distance_meters, price_for_two, display_order) VALUES
  ('shaniwar-wada', 'Bedekar Tea Stall', 'Puneri Misal & Chai', 400, 180, 1),
  ('shaniwar-wada', 'Sujata Mastani', 'Mango and Kesar Mastani Ice Cream Milkshake', 300, 200, 2),
  ('sinhagad-fort', 'Tanaji Chulhavarachi Bhakri', 'Pithla Bhakri with Green Mirchi Thecha', 50, 250, 1),
  ('sinhagad-fort', 'Ghavan & Kanda Bhaji Shack', 'Crispy Kanda Bhaji & Chai', 80, 150, 2),
  ('dagdusheth-ganpati', 'Kaka Halwai Sweet Centre', 'Kaju Katli & Ukadiche Modak', 150, 220, 1),
  ('dagdusheth-ganpati', 'Chitale Bandhu Mithaiwale', 'Famous Puneri Bakarwadi & Amba Barfi', 350, 250, 2);

-- ------------------------------------------------------------------------------
-- 3. TOUR PACKAGES SEED
-- ------------------------------------------------------------------------------
INSERT INTO public.tours (
  id, title, subtitle, tour_type, duration_days, duration_hours, price_per_person,
  discounted_price, hero_image, overview, difficulty, max_group_size, rating, review_count,
  is_active, is_featured, inclusions, exclusions
) VALUES
  (
    'pune-darshan-full-day',
    'Pune Darshan Guided AC Coach Tour',
    'Cover all top 10 iconic Pune landmarks in a single comfortable day',
    'darshan',
    1, 9, 650.0, 500.0,
    'https://images.unsplash.com/photo-1544735716-392fe2489ffa?w=1200&q=80',
    'The quintessential Pune city tour. Experience Shaniwar Wada, Aga Khan Palace, Dagdusheth Halwai Ganpati, Pataleshwar Caves, Kelkar Museum, and Saras Baug with a certified Marathi & English speaking tour guide in an electric AC luxury coach.',
    'Easy', 35, 4.9, 412,
    true, true,
    '["AC Electric Coach Transportation", "Certified Multilingual Guide", "All Monument Entry Tickets", "Complimentary Water Bottle"]'::jsonb,
    '["Lunch and Snacks", "Personal Souvenirs", "Camera Fees at Museums"]'::jsonb
  ),
  (
    'sinhagad-sunrise-trek',
    'Sinhagad Fort Sunrise Trek & Rural Breakfast',
    'Breathtaking sunrise ridge climb followed by authentic Chulhavarachi Pithla Bhakri',
    'trek',
    1, 6, 899.0, 749.0,
    'https://images.unsplash.com/photo-1578632767115-351597cf2477?w=1200&q=80',
    'Climb the historic ridge route from Donje village in the pre-dawn cool. Reach Pune Darwaza just as the first sun rays light up the Sahyadri mountains. Tour Tanaji Malusare’s monument and enjoy a piping hot village breakfast.',
    'Moderate', 20, 4.8, 184,
    true, true,
    '["Round-trip AC Transport from Swargate", "Experienced Trek Leader", "Authentic Pithla Bhakri Breakfast & Chai", "First Aid Support"]'::jsonb,
    '["Personal trekking gear", "Extra beverages"]'::jsonb
  ),
  (
    'rajgad-monsoon-trek',
    'Rajgad Fort Citadel & Padmavati Machi Trek',
    'Conquer the King of Forts — capital of Chhatrapati Shivaji Maharaj for over 25 years',
    'trek',
    1, 10, 1299.0, 1099.0,
    'https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=1200&q=80',
    'A majestic high-altitude trek visiting Chor Darwaza, Padmavati Temple, Suvela Machi, and the needle-eye Nedhe rock formation. Includes fort history briefing by expert Sahyadri mountaineers.',
    'Difficult', 25, 4.9, 96,
    true, false,
    '["Private Tempo Traveler Transport", "Certified Mountaineering Guides", "Full Rural Breakfast & Lunch", "Safety Equipment"]'::jsonb,
    '["Dinner", "Personal medical kit"]'::jsonb
  )
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  subtitle = EXCLUDED.subtitle,
  price_per_person = EXCLUDED.price_per_person,
  discounted_price = EXCLUDED.discounted_price,
  overview = EXCLUDED.overview,
  inclusions = EXCLUDED.inclusions,
  exclusions = EXCLUDED.exclusions;

-- Tour Boarding Points
INSERT INTO public.tour_boarding_points (tour_id, name, landmark, departure_time, display_order) VALUES
  ('pune-darshan-full-day', 'Swargate Bus Stand', 'Opposite Hotel Panchami', '07:30 AM', 1),
  ('pune-darshan-full-day', 'Pune Station', 'Near Inox Multiplex Gate', '08:00 AM', 2),
  ('pune-darshan-full-day', 'Shivajinagar', 'Outside Shivajinagar Metro Station', '08:20 AM', 3),
  ('sinhagad-sunrise-trek', 'Swargate', 'Near Mitra Mandal Chowk', '05:00 AM', 1),
  ('sinhagad-sunrise-trek', 'Kothrud Stand', 'Opposite Chandani Chowk Flyover', '05:25 AM', 2);

-- ------------------------------------------------------------------------------
-- 4. PUNE DARSHAN CIRCUITS SEED
-- ------------------------------------------------------------------------------
INSERT INTO public.darshan_circuits (
  id, circuit_code, title, description, departure_time, return_time, bus_type, fare_per_seat, is_active
) VALUES
  (
    'circuit-central-heritage',
    'PDC-01',
    'Classic Pune Heritage & Temples Circuit',
    'Visits Shaniwar Wada, Dagdusheth Ganpati, Saras Baug, Raja Kelkar Museum, and Parvati Hill.',
    '07:30 AM', '05:30 PM', 'AC Electric Coach', 500.0, true
  ),
  (
    'circuit-spiritual-suburban',
    'PDC-02',
    'Spiritual & Suburban Icons Circuit',
    'Visits Chaturshringi Temple, ISKCON NVCC Pune, Katraj Jain Temple, and Dehu Alandi Pilgrim Path.',
    '08:00 AM', '06:30 PM', 'AC Electric Coach', 650.0, true
  )
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  description = EXCLUDED.description,
  fare_per_seat = EXCLUDED.fare_per_seat;

-- ------------------------------------------------------------------------------
-- 5. HERITAGE WALKS SEED
-- ------------------------------------------------------------------------------
INSERT INTO public.heritage_walks (
  id, title, tagline, description, hero_image, duration_minutes, distance_km, difficulty,
  start_point, end_point, ticket_price, is_active
) VALUES
  (
    'walk-old-pune-wadas',
    'Old Pune Peths & Wada Architecture Trail',
    'Step back into the 18th-century alleys and timber courtyards of the Peshwa capital',
    'Wander through Kasba Peth, Raviwar Peth, and Somwar Peth. Learn how Maratha courtyard houses were engineered with rainwater cisterns, carved teak woodwork, and secret escape tunnels.',
    'https://images.unsplash.com/photo-1590050752117-238cb0fb12b1?w=1200&q=80',
    150, 3.2, 'Easy',
    'Shaniwar Wada Delhi Gate',
    'Nana Wada Courtyard',
    299.0, true
  ),
  (
    'walk-camp-colonial-charm',
    'Pune Camp & Colonial Legacy Walk',
    'Victorian churches, Irani bakeries, and military cantonment history',
    'Explore St. Mary’s Church, the iconic West End Cinema, Kohinoor Restaurant for Bun Maska Chai, and the vintage architecture of MG Road.',
    'https://images.unsplash.com/photo-1582510003544-4d00b7f74220?w=1200&q=80',
    120, 2.5, 'Easy',
    'St. Mary’s Church, Camp',
    'East Street Irani Bakery',
    349.0, true
  )
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  tagline = EXCLUDED.tagline,
  ticket_price = EXCLUDED.ticket_price;

-- ------------------------------------------------------------------------------
-- 6. COUPONS & PROMOTIONS SEED
-- ------------------------------------------------------------------------------
INSERT INTO public.coupons (
  id, code, title, description, discount_type, discount_value,
  min_booking_amount, max_discount_amount, valid_from, valid_until,
  usage_limit, times_used, is_active
) VALUES
  (
    'coup-darshan50',
    'DARSHAN50',
    'Pune Darshan Special ₹50 Off',
    'Flat ₹50 off per seat on all Pune Darshan bus circuits',
    'flat', 50.0, 450.0, 50.0,
    NOW() - INTERVAL '30 days', NOW() + INTERVAL '180 days',
    5000, 128, true
  ),
  (
    'coup-trek15',
    'TREK15',
    'Sahyadri Monsoon Trek 15% Off',
    '15% instant discount on all weekend Sahyadri fort treks',
    'percentage', 15.0, 700.0, 250.0,
    NOW() - INTERVAL '30 days', NOW() + INTERVAL '180 days',
    1000, 64, true
  ),
  (
    'coup-puneri99',
    'PUNERI99',
    'Heritage Walk Flat ₹99 Off',
    'Special promotion for guided walking tours in historic peths',
    'flat', 99.0, 250.0, 99.0,
    NOW() - INTERVAL '10 days', NOW() + INTERVAL '120 days',
    500, 31, true
  ),
  (
    'coup-pune2026',
    'PUNE2026',
    'Explore Pune 2026 Launch Special',
    '10% off across all tours and packages for registered members',
    'percentage', 10.0, 500.0, 300.0,
    NOW() - INTERVAL '5 days', NOW() + INTERVAL '365 days',
    10000, 214, true
  )
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  description = EXCLUDED.description,
  discount_value = EXCLUDED.discount_value,
  is_active = EXCLUDED.is_active;

-- ------------------------------------------------------------------------------
-- 7. FAQS SEED
-- ------------------------------------------------------------------------------
INSERT INTO public.faqs (id, question, answer, category, display_order, is_active) VALUES
  (
    'faq-darshan-timing',
    'What are the timings of the Pune Darshan bus tour?',
    'The bus departs sharp at 07:30 AM from Swargate and 08:00 AM from Pune Station. The tour concludes around 05:30 PM to 06:00 PM at Swargate.',
    'Tours & Darshan', 1, true
  ),
  (
    'faq-payment-methods',
    'Which payment modes are supported for booking confirmation?',
    'We support instant UPI QR Code payments (Google Pay, PhonePe, Paytm, BHIM, Cred) as well as direct UTR verification.',
    'Payments & Bookings', 2, true
  ),
  (
    'faq-cancellation-policy',
    'What is the cancellation and refund policy?',
    'Cancellations made 24 hours prior to travel date receive an 80% refund. Cancellations within 24 hours incur a 50% fee. Same day no-shows are non-refundable.',
    'Cancellations & Refunds', 3, true
  ),
  (
    'faq-monsoon-trekking',
    'Is Sinhagad or Rajgad fort trek safe during heavy monsoon?',
    'All guided treks are led by certified Sahyadri mountaineers equipped with safety ropes and first aid. If weather authorities issue a Red Alert, trips are rescheduled at no extra charge.',
    'Safety & Trekking', 4, true
  )
ON CONFLICT (id) DO UPDATE SET
  question = EXCLUDED.question,
  answer = EXCLUDED.answer;

-- ------------------------------------------------------------------------------
-- 8. APP SETTINGS SEED
-- ------------------------------------------------------------------------------
INSERT INTO public.app_settings (key, value, description, updated_by) VALUES
  (
    'general',
    '{"app_name": "PuneExplorer", "helpline": "1363", "support_email": "support@puneexplorer.in", "emergency_police": "112", "maintenance_mode": false}'::jsonb,
    'Core general application metadata',
    'system'
  ),
  (
    'payments',
    '{"merchant_upi_id": "puneexplorer@icici", "merchant_name": "PuneExplorer Tourism", "default_currency": "INR", "payment_timeout_minutes": 20, "auto_verify_threshold": 0}'::jsonb,
    'UPI and payment gateway settlement settings',
    'system'
  ),
  (
    'booking_rules',
    '{"same_day_cutoff_hours": 3, "cancellation_grace_hours": 24, "max_travelers_per_booking": 10}'::jsonb,
    'Booking business rules and constraints',
    'system'
  )
ON CONFLICT (key) DO UPDATE SET
  value = EXCLUDED.value;


