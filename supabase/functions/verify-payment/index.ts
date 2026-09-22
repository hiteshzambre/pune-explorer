// Supabase Edge Function: verify-payment
// Privileged server-side endpoint for payment verification (UPI webhook / manual review)

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.0";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
    const supabaseServiceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";

    if (!supabaseUrl || !supabaseServiceRoleKey) {
      return new Response(
        JSON.stringify({ error: "Missing Supabase server configuration." }),
        { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // Verify caller authentication
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return new Response(
        JSON.stringify({ error: "Missing Authorization header." }),
        { status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const supabaseAdmin = createClient(supabaseUrl, supabaseServiceRoleKey, {
      auth: { persistSession: false },
    });

    // Validate JWT caller
    const token = authHeader.replace("Bearer ", "");
    const { data: { user }, error: userError } = await supabaseAdmin.auth.getUser(token);

    if (userError || !user) {
      return new Response(
        JSON.stringify({ error: "Invalid or expired session token." }),
        { status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // Check caller permission
    const { data: hasPerm } = await supabaseAdmin.rpc("has_permission", {
      p_user_id: user.id,
      p_permission: "verify_payments",
    });

    if (!hasPerm) {
      return new Response(
        JSON.stringify({ error: "Unauthorized: 'verify_payments' permission required." }),
        { status: 403, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const body = await req.json();
    const { orderId, action, reason, notes } = body;

    if (!orderId || !action) {
      return new Response(
        JSON.stringify({ error: "Missing required fields: orderId, action." }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    let result;
    if (action === "verify") {
      const { data, error } = await supabaseAdmin.rpc("verify_payment_claim", {
        p_order_id: orderId,
        p_verified_by: user.email ?? user.id,
        p_notes: notes ?? "Verified by admin via Edge Function",
      });
      if (error) throw error;
      result = data;
    } else if (action === "reject") {
      const { data, error } = await supabaseAdmin.rpc("reject_payment_claim", {
        p_order_id: orderId,
        p_reason: reason ?? "Invalid UTR or payment not received",
        p_rejected_by: user.email ?? user.id,
      });
      if (error) throw error;
      result = data;
    } else {
      return new Response(
        JSON.stringify({ error: "Invalid action. Must be 'verify' or 'reject'." }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    return new Response(
      JSON.stringify({ success: true, data: result }),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  } catch (err: any) {
    return new Response(
      JSON.stringify({ error: err.message ?? "Internal server error." }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});
