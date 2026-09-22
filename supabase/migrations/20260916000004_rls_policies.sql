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
