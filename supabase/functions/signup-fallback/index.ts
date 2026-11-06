import { createClient } from "npm:@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  if (req.method !== "POST") {
    return new Response(
      JSON.stringify({ error: "Method not allowed" }),
      { status: 405, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }

  try {
    const supabaseUrl = Deno.env.get("SUPABASE_URL");
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

    if (!supabaseUrl || !supabaseServiceKey) {
      return new Response(
        JSON.stringify({ error: "Server configuration missing" }),
        { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const supabase = createClient(supabaseUrl, supabaseServiceKey);
    const body = await req.json();
    const { email, password, full_name, phone_number, ...extraMeta } = body ?? {};

    const cleanEmail = typeof email === "string" ? email.trim() : "";
    const cleanPassword = typeof password === "string" ? password : "";
    const cleanName = typeof full_name === "string" ? full_name.trim() : "";
    const cleanPhone = typeof phone_number === "string" ? phone_number.trim() : "";

    const emailRegex = /^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$/;
    if (!cleanEmail || !emailRegex.test(cleanEmail)) {
      return new Response(
        JSON.stringify({ error: "Format email tidak valid" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    if (!cleanPassword || cleanPassword.length < 8) {
      return new Response(
        JSON.stringify({ error: "Password minimal 8 karakter" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    if (!cleanName) {
      return new Response(
        JSON.stringify({ error: "Nama lengkap tidak boleh kosong" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const { data: usersData, error: listError } = await supabase.auth.admin.listUsers();
    if (listError) {
      return new Response(
        JSON.stringify({ error: listError.message }),
        { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const existingUser = usersData.users.find(
      (u) => u.email?.toLowerCase() === cleanEmail.toLowerCase()
    );

    const userMetadata = {
      ...extraMeta,
      full_name: cleanName,
      phone_number: cleanPhone,
      email_verified_via_otp: false,
      email_otp_skipped: true,
      verification_status: "unverified",
      role: "customer",
    };

    let userId: string;

    if (existingUser) {
      if (existingUser.email_confirmed_at) {
        return new Response(
          JSON.stringify({ error: "Email sudah terdaftar" }),
          { status: 409, headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );
      }

      const { data: updated, error: updateError } = await supabase.auth.admin.updateUserById(
        existingUser.id,
        {
          password: cleanPassword,
          email_confirm: true,
          user_metadata: userMetadata,
        }
      );

      if (updateError || !updated.user) {
        return new Response(
          JSON.stringify({ error: updateError?.message ?? "Gagal memperbarui pengguna" }),
          { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );
      }
      userId = updated.user.id;
    } else {
      const { data: created, error: createError } = await supabase.auth.admin.createUser({
        email: cleanEmail,
        password: cleanPassword,
        email_confirm: true,
        user_metadata: userMetadata,
      });

      if (createError || !created.user) {
        return new Response(
          JSON.stringify({ error: createError?.message ?? "Gagal membuat pengguna" }),
          { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );
      }
      userId = created.user.id;
    }

    try {
      await supabase.from("profiles").upsert({
        id: userId,
        full_name: cleanName,
        phone_number: cleanPhone,
        verification_status: "unverified",
        role: "customer",
      });
    } catch (_) {}

    return new Response(
      JSON.stringify({
        success: true,
        user_id: userId,
        message: "Akun berhasil dibuat dengan fallback",
      }),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  } catch (err: unknown) {
    const errorMsg = err instanceof Error ? err.message : String(err);
    return new Response(
      JSON.stringify({ error: errorMsg }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});
