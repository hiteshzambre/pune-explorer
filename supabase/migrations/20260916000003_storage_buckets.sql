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
