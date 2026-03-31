import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

/**
 * send_confirmation_email — sends a custom email confirmation after sign-up.
 * This supplements (or replaces) Supabase's built-in confirmation email
 * with SoberSteps branding and philosophy tone.
 * Called by: Supabase Auth webhook (email confirmation event).
 */
serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response(null, {
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Headers": "authorization, content-type",
      },
    });
  }

  try {
    const { email, confirmation_url, display_name } = await req.json();
    if (!email || typeof email !== "string") {
      return json({ error: "email required" }, 400);
    }
    if (!confirmation_url || typeof confirmation_url !== "string") {
      return json({ error: "confirmation_url required" }, 400);
    }

    const brevoApiKey = Deno.env.get("BREVO_API_KEY");
    if (!brevoApiKey) {
      console.error("[send_confirmation_email] BREVO_API_KEY not set");
      return json({ error: "server_misconfigured" }, 500);
    }

    const firstName = display_name ?? "there";

    const res = await fetch("https://api.brevo.com/v3/smtp/email", {
      method: "POST",
      headers: {
        "api-key": brevoApiKey,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        sender: { name: "SoberSteps", email: "noreply@sobersteps.app" },
        to: [{ email }],
        subject: "Potwierdź swój adres e-mail — SoberSteps",
        htmlContent: `
          <div style="font-family: sans-serif; max-width: 520px; margin: 0 auto; color: #1a1a2e;">
            <h2 style="color: #7c6af7;">Cześć, ${firstName}</h2>
            <p>Jeden krok — potwierdź swój adres e-mail, żeby zacząć.</p>
            <p style="margin: 24px 0;">
              <a href="${confirmation_url}"
                 style="background: #7c6af7; color: white; padding: 12px 24px; border-radius: 8px; text-decoration: none; font-weight: bold;">
                Potwierdź e-mail
              </a>
            </p>
            <p style="color: #666; font-size: 13px;">
              Jeśli przycisk nie działa, skopiuj ten link do przeglądarki:<br/>
              <a href="${confirmation_url}">${confirmation_url}</a>
            </p>
            <p style="color: #888; font-size: 12px; margin-top: 32px;">
              SoberSteps © 2026 · Uśmiech ↔ Perspektywa ↔ Droga
            </p>
          </div>
        `,
      }),
    });

    const result = await res.json();
    console.log("[send_confirmation_email] sent:", result);
    return json({ success: true });
  } catch (error) {
    console.error("[send_confirmation_email] error:", error);
    return json({ error: "internal_server_error" }, 500);
  }
});

function json(o: object, status = 200) {
  return new Response(JSON.stringify(o), {
    status,
    headers: {
      "Content-Type": "application/json",
      "Access-Control-Allow-Origin": "*",
    },
  });
}
