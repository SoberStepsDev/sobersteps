import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const ONESIGNAL_URL = "https://api.onesignal.com/rest/v1/notifications";

serve(async (req: Request) => {
  const auth = req.headers.get("Authorization");
  const cronSecret = Deno.env.get("CRON_SECRET");
  if (!auth?.startsWith("Bearer ") || !cronSecret || auth.slice(7) !== cronSecret) {
    return new Response(JSON.stringify({ error: "unauthorized" }), { status: 401 });
  }
  const appId = Deno.env.get("ONESIGNAL_APP_ID");
  const restKey = Deno.env.get("ONESIGNAL_REST_API_KEY");
  if (!appId || !restKey) {
    return new Response(JSON.stringify({ error: "ONESIGNAL_APP_ID or ONESIGNAL_REST_API_KEY not set" }), { status: 500 });
  }

  const url = new URL(req.url);
  const type = url.searchParams.get("type") || "";
  const hour = parseInt(url.searchParams.get("hour") || "0", 10);

  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
  );

  try {
    if (type === "checkin" && hour >= 0 && hour <= 23) {
      const { data: prefs } = await supabase.from("profiles").select("id,notification_prefs").eq("checkin_reminder_hour", hour);
      const today = new Date().toISOString().slice(0, 10);
      const { data: checked } = await supabase.from("journal_entries").select("user_id").gte("created_at", `${today}T00:00:00`);
      const checkedIds = new Set((checked || []).map((r: { user_id: string }) => r.user_id));
      const toNotify: string[] = [];
      for (const p of prefs || []) {
        const np = (p.notification_prefs as Record<string, boolean>) || {};
        if (np.daily_checkin !== false && !checkedIds.has(p.id)) toNotify.push(p.id);
      }
      if (toNotify.length === 0) return json({ sent: 0 });
      const res = await fetch(ONESIGNAL_URL, {
        method: "POST",
        headers: { "Authorization": `Basic ${restKey}`, "Content-Type": "application/json" },
        body: JSON.stringify({
          app_id: appId,
          include_aliases: { external_id: toNotify },
          contents: { en: "Time for your daily check-in. How are you today?" },
          headings: { en: "SoberSteps" },
        }),
      });
      const out = await res.json();
      return json({ sent: toNotify.length, onesignal: out.errors ? out : { id: out.id } });
    }

    if (type === "letter") {
      const today = new Date().toISOString().slice(0, 10);
      const { data: letters } = await supabase.from("future_letters").select("user_id").eq("deliver_at", today).is("delivered_at", null);
      const userIds = [...new Set((letters || []).map((r: { user_id: string }) => r.user_id))];
      const { data: profs } = await supabase.from("profiles").select("id,notification_prefs").in("id", userIds);
      const toNotify = (profs || []).filter((p: { notification_prefs?: Record<string, boolean> }) => (p.notification_prefs?.letter ?? true)).map((p: { id: string }) => p.id);
      if (toNotify.length === 0) return json({ sent: 0 });
      await fetch(ONESIGNAL_URL, {
        method: "POST",
        headers: { "Authorization": `Basic ${restKey}`, "Content-Type": "application/json" },
        body: JSON.stringify({
          app_id: appId,
          include_aliases: { external_id: toNotify },
          contents: { en: "A letter from your past self is ready to read." },
          headings: { en: "SoberSteps" },
        }),
      });
      return json({ sent: toNotify.length });
    }

    if (type === "milestone") {
      const tomorrow = new Date();
      tomorrow.setDate(tomorrow.getDate() + 1);
      const tomorrowStr = tomorrow.toISOString().slice(0, 10);
      const { data: profs } = await supabase.from("profiles").select("id, sobriety_start_date, notification_prefs").not("sobriety_start_date", "is", null);
      const milestones = [1, 3, 7, 14, 30, 60, 90, 180, 365];
      const toNotify: string[] = [];
      for (const p of profs || []) {
        const np = (p.notification_prefs as Record<string, boolean>) || {};
        if (np.milestone === false) continue;
        const start = new Date(p.sobriety_start_date);
        const days = Math.floor((tomorrow.getTime() - start.getTime()) / 86400000);
        if (milestones.includes(days)) {
          const { data: achieved } = await supabase.from("milestones_achieved").select("id").eq("user_id", p.id).eq("days", days).maybeSingle();
          if (!achieved) toNotify.push(p.id);
        }
      }
      if (toNotify.length === 0) return json({ sent: 0 });
      await fetch(ONESIGNAL_URL, {
        method: "POST",
        headers: { "Authorization": `Basic ${restKey}`, "Content-Type": "application/json" },
        body: JSON.stringify({
          app_id: appId,
          include_aliases: { external_id: toNotify },
          contents: { en: "Tomorrow you'll hit a new milestone. Keep going!" },
          headings: { en: "SoberSteps" },
        }),
      });
      return json({ sent: toNotify.length });
    }

    return new Response(JSON.stringify({ error: "invalid type" }), { status: 400 });
  } catch (e) {
    console.error("[notify_users]", e);
    return new Response(JSON.stringify({ error: String(e) }), { status: 500 });
  }
});

function json(o: object) {
  return new Response(JSON.stringify(o), { headers: { "Content-Type": "application/json" } });
}
