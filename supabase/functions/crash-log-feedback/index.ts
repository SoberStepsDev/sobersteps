import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.45.0";

const ANTHROPIC_URL = "https://api.anthropic.com/v1/messages";

const SYSTEM_PROMPT = `You are a compassionate, non-judgmental companion for someone in recovery.
The user has just written a journal entry (CrashLog) about a difficult moment.
Respond in 2–3 short sentences (max 60 words).
Match the user's language (Polish if they write in Polish, English if English).
Do NOT give advice, diagnose, or use clinical language.
Reflect what you hear. Acknowledge the feeling. End with one gentle, open question.
Philosophy: Uśmiech (curiosity, not imperatives), Perspektywa (no finish line), Droga (80% is enough).`;

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
    const supabaseUrl = Deno.env.get("SUPABASE_URL");
    const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
    if (!supabaseUrl || !serviceKey) {
      return json({ error: "server_misconfigured" }, 500);
    }

    const authHeader = req.headers.get("Authorization") ?? "";
    const jwt = authHeader.replace(/^Bearer\s+/i, "").trim();
    if (!jwt) return json({ error: "unauthorized" }, 401);

    const admin = createClient(supabaseUrl, serviceKey);
    const { data: userData, error: userErr } = await admin.auth.getUser(jwt);
    if (userErr || !userData?.user) return json({ error: "unauthorized" }, 401);
    const userId = userData.user.id;

    const { entry, mode } = await req.json();
    if (!entry || typeof entry !== "string" || entry.trim().length === 0) {
      return json({ error: "entry required" }, 400);
    }

    // Rate limiting: max 5 CrashLog AI responses per day
    const today = new Date().toISOString().slice(0, 10);
    const { data: row } = await admin
      .from("crash_log_rate_limits")
      .select("count")
      .eq("user_id", userId)
      .eq("rate_date", today)
      .maybeSingle();

    const current = typeof row?.count === "number" ? row.count : 0;
    if (current >= 5) {
      return json({ error: "limit_reached" }, 429);
    }

    const apiKey = Deno.env.get("ANTHROPIC_API_KEY");
    if (!apiKey) return json({ error: "ANTHROPIC_API_KEY not set" }, 500);

    const modeLabel = mode === "deep" ? "deep reflection" : "gentle check-in";
    const userPrompt = `Mode: ${modeLabel}\nJournal entry: "${entry.trim()}"`;

    const res = await fetch(ANTHROPIC_URL, {
      method: "POST",
      headers: {
        "x-api-key": apiKey,
        "anthropic-version": "2023-06-01",
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        model: "claude-3-5-haiku-20241022",
        max_tokens: 120,
        system: SYSTEM_PROMPT,
        messages: [{ role: "user", content: userPrompt }],
      }),
    });

    if (!res.ok) {
      const err = await res.text();
      console.error("[crash-log-feedback] Anthropic error:", res.status, err);
      return json({ error: "anthropic_error", status: res.status }, 502);
    }

    const data = await res.json();
    const feedback = data?.content?.[0]?.text?.trim() ?? null;
    if (!feedback) return json({ error: "empty_response" }, 502);

    // Update rate limit
    if (current === 0) {
      await admin.from("crash_log_rate_limits").insert({
        user_id: userId,
        rate_date: today,
        count: 1,
      });
    } else {
      await admin
        .from("crash_log_rate_limits")
        .update({ count: current + 1 })
        .eq("user_id", userId)
        .eq("rate_date", today);
    }

    return json({ feedback });
  } catch (e) {
    console.error("[crash-log-feedback]", e);
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
