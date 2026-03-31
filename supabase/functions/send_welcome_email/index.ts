import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

/**
 * send_welcome_email — triggered after a new user registers.
 * Called by: Supabase Auth webhook or from the app after successful sign-up.
 * Sends a welcome email via Brevo (Sendinblue).
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
    const { email, display_name } = await req.json();
    if (!email || typeof email !== "string") {
      return json({ error: "email required" }, 400);
    }

    const brevoApiKey = Deno.env.get("BREVO_API_KEY");
    if (!brevoApiKey) {
      console.error("[send_welcome_email] BREVO_API_KEY not set");
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
        sender: { name: "Patryk from SoberSteps", email: "noreply@sobersteps.app" },
        to: [{ email }],
        subject: "Witaj w SoberSteps — droga zaczyna się teraz",
        htmlContent: `
          <div style="font-family: sans-serif; max-width: 520px; margin: 0 auto; color: #1a1a2e;">
            <h2 style="color: #7c6af7;">Cześć, ${firstName} 👋</h2>
            <p>Cieszę się, że tu jesteś. Naprawdę.</p>
            <p>SoberSteps to nie kolejna aplikacja z licznikiem dni. To towarzysz — bez oceniania, bez motywacyjnego cukru, z pełnym szacunkiem dla tego, że droga nie jest prosta.</p>
            <p><strong>Filozofia, która prowadzi każde słowo w aplikacji:</strong></p>
            <ul>
              <li><strong>Uśmiech</strong> — ciekawość zamiast imperatywów</li>
              <li><strong>Perspektywa</strong> — brak mety, tylko horyzont</li>
              <li><strong>Droga</strong> — 80% wystarczy</li>
            </ul>
            <p>Jeśli masz pytania, pisz: <a href="mailto:sobersteps@pm.me">sobersteps@pm.me</a></p>
            <p style="color: #888; font-size: 12px; margin-top: 32px;">
              SoberSteps © 2026 · <a href="https://soberstepsdev.github.io/sobersteps-landing/">sobersteps.app</a>
            </p>
          </div>
        `,
      }),
    });

    const result = await res.json();
    console.log("[send_welcome_email] sent:", result);
    return json({ success: true });
  } catch (error) {
    console.error("[send_welcome_email] error:", error);
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
