import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

serve(async (req: Request) => {
  try {
    const { row_id, table_name, reason } = await req.json();
    const brevoApiKey = Deno.env.get("BREVO_API_KEY");
    const adminEmail = Deno.env.get("ADMIN_EMAIL") || "admin@sobersteps.app";

    if (!brevoApiKey) {
      console.error("[send_moderation_email] BREVO_API_KEY not set");
      return new Response(JSON.stringify({ error: "no api key" }), { status: 500 });
    }

    const res = await fetch("https://api.brevo.com/v3/smtp/email", {
      method: "POST",
      headers: {
        "api-key": brevoApiKey,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        sender: { name: "SoberSteps Moderation", email: "noreply@sobersteps.app" },
        to: [{ email: adminEmail }],
        subject: `[Moderation] Flagged content in ${table_name}`,
        htmlContent: `<p>Row ID: ${row_id}</p><p>Table: ${table_name}</p><p>Reason: ${reason}</p><p>Please review in the Supabase dashboard.</p>`,
      }),
    });

    const result = await res.json();
    console.log("[send_moderation_email] sent:", result);

    return new Response(JSON.stringify({ success: true }), {
      headers: { "Content-Type": "application/json" },
    });
  } catch (error) {
    console.error("[send_moderation_email] error:", error);
    return new Response(JSON.stringify({ error: String(error) }), { status: 500 });
  }
});
