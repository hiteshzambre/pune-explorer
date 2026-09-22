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
