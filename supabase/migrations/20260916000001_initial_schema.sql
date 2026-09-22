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
