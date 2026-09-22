// Supabase Edge Function: admin-manage-user
// Privileged server-side user role and permission administration

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

    const token = authHeader.replace("Bearer ", "");
    const { data: { user }, error: userError } = await supabaseAdmin.auth.getUser(token);

    if (userError || !user) {
      return new Response(
        JSON.stringify({ error: "Invalid or expired session token." }),
        { status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // Require 'manage_users' permission
    const { data: hasPerm } = await supabaseAdmin.rpc("has_permission", {
      p_user_id: user.id,
      p_permission: "manage_users",
    });

    if (!hasPerm) {
      return new Response(
        JSON.stringify({ error: "Unauthorized: 'manage_users' permission required." }),
        { status: 403, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const body = await req.json();
    const { action, targetUserId, newRole, email } = body;

    if (action === "assign_role") {
      if (!targetUserId || !newRole) {
        return new Response(
          JSON.stringify({ error: "targetUserId and newRole required." }),
          { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );
      }

      // Upsert into user_roles
      const { error: roleError } = await supabaseAdmin
        .from("user_roles")
        .upsert({ user_id: targetUserId, role_id: newRole, assigned_by: user.id });

      if (roleError) throw roleError;

      // Update profiles role column
      await supabaseAdmin
        .from("profiles")
        .update({ role: newRole })
        .eq("id", targetUserId);

      // Audit log
      await supabaseAdmin.from("audit_logs").insert({
        id: `audit_${Date.now()}_${Math.random().toString(36).substring(2, 7)}`,
        user_id: user.id,
        user_email: user.email ?? "",
        action: "USER_ROLE_CHANGED",
        entity_type: "user",
        entity_id: targetUserId,
        new_values: { new_role: newRole },
      });

      return new Response(
        JSON.stringify({ success: true, message: `Role updated to ${newRole}` }),
        { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    if (action === "invite_staff") {
      if (!email || !newRole) {
        return new Response(
          JSON.stringify({ error: "email and newRole required." }),
          { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );
      }

      const { data: inviteData, error: inviteError } = await supabaseAdmin.auth.admin.inviteUserByEmail(email, {
        data: { role: newRole },
      });

      if (inviteError) throw inviteError;

      return new Response(
        JSON.stringify({ success: true, user: inviteData.user }),
        { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    return new Response(
      JSON.stringify({ error: `Unknown action: ${action}` }),
      { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  } catch (err: any) {
    return new Response(
      JSON.stringify({ error: err.message ?? "Internal server error." }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});
