import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.45.0";

type NotifyType = "checkin" | "letter" | "path" | "milestone";

const ONE_SIGNAL_URL = "https://onesignal.com/api/v1/notifications";

export async function handleNotifyRequest(req: Request): Promise<Response> {
  if (req.method === "OPTIONS") {
    return json({ ok: true });
  }

  try {
    if (req.method !== "GET") {
      return json({ error: "method_not_allowed" }, 405);
    }

    const cronSecret = Deno.env.get("CRON_SECRET") ?? "";
    const authHeader = req.headers.get("Authorization") ?? "";
    const token = authHeader.replace(/^Bearer\s+/i, "").trim();
    if (!cronSecret || token !== cronSecret) {
      return json({ error: "unauthorized" }, 401);
    }

    const supabaseUrl = Deno.env.get("SUPABASE_URL");
    const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
    const oneSignalAppId = Deno.env.get("ONESIGNAL_APP_ID");
    const oneSignalApiKey = Deno.env.get("ONESIGNAL_REST_API_KEY");
    if (!supabaseUrl || !serviceRoleKey || !oneSignalAppId || !oneSignalApiKey) {
      return json({ error: "server_misconfigured" }, 500);
    }

    const url = new URL(req.url);
    const type = (url.searchParams.get("type") ?? "").trim() as NotifyType;
    const hour = Number(url.searchParams.get("hour") ?? -1);
    if (!["checkin", "letter", "path", "milestone"].includes(type)) {
      return json({ error: "invalid_type" }, 400);
    }

    const admin = createClient(supabaseUrl, serviceRoleKey);
    const today = new Date().toISOString().slice(0, 10);
    const nowIso = new Date().toISOString();

    if (type === "checkin") {
      if (!Number.isInteger(hour) || hour < 0 || hour > 23) {
        return json({ error: "invalid_hour" }, 400);
      }
      const { data, error } = await admin
        .from("profiles")
        .select("id, checkin_reminder_hour, notification_prefs")
        .eq("checkin_reminder_hour", hour);
      if (error) return json({ error: "profiles_query_failed", details: error.message }, 500);

      const userIds = (data ?? [])
        .filter((p) => prefEnabled(p.notification_prefs, "daily_checkin"))
        .map((p) => p.id);
      const sent = await sendPush(oneSignalAppId, oneSignalApiKey, userIds, {
        en: "Ciekawie wrócić do siebie na chwilę?",
        pl: "Może chwila spokojnego check-inu?",
      }, {
        en: "Jedno zdanie też wystarczy. 80% jest OK.",
        pl: "Jedno zdanie też wystarczy. 80% jest OK.",
      }, { type: "checkin" });
      return json({ ok: true, type, targeted: userIds.length, sent });
    }

    if (type === "letter") {
      const { data, error } = await admin
        .from("future_letters")
        .select("id, user_id")
        .eq("deliver_at", today)
        .is("delivered_at", null);
      if (error) return json({ error: "letters_query_failed", details: error.message }, 500);

      const letters = data ?? [];
      const userIds = [...new Set(letters.map((l) => l.user_id))];
      const enabledUserIds = await filterUsersByPref(admin, userIds, "letter");
      const sent = await sendPush(oneSignalAppId, oneSignalApiKey, enabledUserIds, {
        en: "A letter from you is waiting.",
        pl: "Czeka na Ciebie list od Ciebie.",
      }, {
        en: "When it feels right, you can read it with curiosity.",
        pl: "Możesz zajrzeć do niego wtedy, gdy poczujesz gotowość.",
      }, { type: "letter" });

      const letterIds = letters.filter((l) => enabledUserIds.includes(l.user_id)).map((l) => l.id);
      if (letterIds.length > 0) {
        const { error: updateError } = await admin
          .from("future_letters")
          .update({ delivered_at: nowIso })
          .in("id", letterIds);
        if (updateError) {
          return json({ error: "letters_update_failed", details: updateError.message }, 500);
        }
      }
      return json({ ok: true, type, targeted: enabledUserIds.length, sent, letters_marked: letterIds.length });
    }

    if (type === "path") {
      const { data, error } = await admin
        .from("profiles")
        .select("id, notification_prefs");
      if (error) return json({ error: "profiles_query_failed", details: error.message }, 500);

      const userIds = (data ?? [])
        .filter((p) => prefEnabled(p.notification_prefs, "streak"))
        .map((p) => p.id);
      const sent = await sendPush(oneSignalAppId, oneSignalApiKey, userIds, {
        en: "You are still on your path.",
        pl: "Nadal jesteś na swojej drodze.",
      }, {
        en: "Ciekawie sprawdzić, co dziś już w Tobie żyje?",
        pl: "Ciekawe, co dziś już w Tobie żyje?",
      }, { type: "path" });
      return json({ ok: true, type, targeted: userIds.length, sent });
    }

    const milestoneDays = [1, 7, 30, 90, 180, 365];
    const dayBeforeList = milestoneDays.filter((d) => d > 1).map((d) => d - 1);
    const { data, error } = await admin
      .from("milestones_achieved")
      .select("user_id, days")
      .in("days", dayBeforeList);
    if (error) return json({ error: "milestones_query_failed", details: error.message }, 500);

    const userIds = [...new Set((data ?? []).map((m) => m.user_id))];
    const enabledUserIds = await filterUsersByPref(admin, userIds, "milestone");
    const sent = await sendPush(oneSignalAppId, oneSignalApiKey, enabledUserIds, {
      en: "Your next step is close.",
      pl: "Kolejny krok jest blisko.",
    }, {
      en: "Może jutro zauważysz, jak daleko już doszedłeś.",
      pl: "Może jutro zauważysz, jak daleko już jesteś.",
    }, { type: "milestone" });
    return json({ ok: true, type, targeted: enabledUserIds.length, sent });
  } catch (e) {
    console.error("[notify_users]", e);
    return json({ error: "internal_server_error" }, 500);
  }
}

async function filterUsersByPref(
  admin: any,
  userIds: string[],
  key: string,
): Promise<string[]> {
  if (userIds.length === 0) return [];
  const { data, error } = await admin
    .from("profiles")
    .select("id, notification_prefs")
    .in("id", userIds);
  if (error) {
    console.error("[notify_users] filterUsersByPref", error.message);
    return [];
  }
  return ((data ?? []) as Array<{ id: string; notification_prefs: unknown }>)
    .filter((p) => prefEnabled(p.notification_prefs, key))
    .map((p) => p.id);
}

export function prefEnabled(prefs: unknown, key: string): boolean {
  if (!prefs || typeof prefs !== "object") return true;
  const value = (prefs as Record<string, unknown>)[key];
  return value !== false;
}

export function computeUsersApproachingMilestone(
  profiles: Array<{ id: string; sobriety_start_date: string; notification_prefs: unknown }>,
  now: Date,
): Array<{ userId: string; milestoneDay: number }> {
  const milestoneDays = [1, 7, 30, 90, 180, 365];
  const tomorrow = new Date(now);
  tomorrow.setUTCDate(tomorrow.getUTCDate() + 1);
  const tomorrowStr = tomorrow.toISOString().slice(0, 10);

  const results: Array<{ userId: string; milestoneDay: number }> = [];
  for (const profile of profiles) {
    if (!prefEnabled(profile.notification_prefs, "milestone")) continue;
    const start = new Date(profile.sobriety_start_date);
    for (const day of milestoneDays) {
      const milestoneDate = new Date(start);
      milestoneDate.setUTCDate(milestoneDate.getUTCDate() + day);
      if (milestoneDate.toISOString().slice(0, 10) === tomorrowStr) {
        results.push({ userId: profile.id, milestoneDay: day });
      }
    }
  }
  return results;
}

export async function sendPush(
  appId: string,
  apiKey: string,
  userIds: string[],
  headings: Record<string, string>,
  contents: Record<string, string>,
  data: Record<string, string>,
): Promise<number> {
  if (userIds.length === 0) return 0;

  const chunkSize = 2000;
  let total = 0;

  for (let i = 0; i < userIds.length; i += chunkSize) {
    const chunk = userIds.slice(i, i + chunkSize);
    const res = await fetch(ONE_SIGNAL_URL, {
      method: "POST",
      headers: {
        "Content-Type": "application/json; charset=utf-8",
        "Authorization": `Basic ${apiKey}`,
      },
      body: JSON.stringify({
        app_id: appId,
        include_external_user_ids: chunk,
        channel_for_external_user_ids: "push",
        headings,
        contents,
        data,
      }),
    });

    if (!res.ok) {
      const text = await res.text();
      console.error("[notify_users] OneSignal error", res.status, text);
      continue;
    }
    total += chunk.length;
  }

  return total;
}

function json(body: Record<string, unknown>, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      "Content-Type": "application/json",
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Headers": "authorization, content-type",
    },
  });
}

if (import.meta.main) {
  serve(handleNotifyRequest);
}