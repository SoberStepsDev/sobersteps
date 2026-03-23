import { assertEquals } from "https://deno.land/std@0.168.0/testing/asserts.ts";
import { computeUsersApproachingMilestone, handleNotifyRequest, prefEnabled, sendPush } from "./index.ts";

Deno.test("notify_users returns unauthorized without valid cron token", async () => {
  Deno.env.set("CRON_SECRET", "secret");
  const req = new Request("https://example.com/functions/v1/notify_users?type=checkin&hour=9");
  const res = await handleNotifyRequest(req);
  assertEquals(res.status, 401);
});

Deno.test("prefEnabled handles defaults and explicit false", () => {
  assertEquals(prefEnabled(null, "daily_checkin"), true);
  assertEquals(prefEnabled({}, "daily_checkin"), true);
  assertEquals(prefEnabled({ daily_checkin: true }, "daily_checkin"), true);
  assertEquals(prefEnabled({ daily_checkin: false }, "daily_checkin"), false);
});

Deno.test("sendPush chunks user ids and counts sent", async () => {
  const originalFetch = globalThis.fetch;
  let calls = 0;
  globalThis.fetch = (async () => {
    calls += 1;
    return new Response(JSON.stringify({ id: "ok" }), { status: 200 });
  }) as typeof fetch;
  try {
    const ids = Array.from({ length: 4001 }, (_, i) => `u-${i}`);
    const sent = await sendPush("app", "key", ids, { en: "h" }, { en: "c" }, { type: "t" });
    assertEquals(sent, 4001);
    assertEquals(calls, 3);
  } finally {
    globalThis.fetch = originalFetch;
  }
});

Deno.test("computeUsersApproachingMilestone selects users reaching milestone tomorrow", () => {
  const now = new Date("2026-03-23T20:00:00.000Z");
  const profiles = [
    { id: "u1", sobriety_start_date: "2026-03-17", notification_prefs: {} }, // tomorrow day 7
    { id: "u2", sobriety_start_date: "2026-03-18", notification_prefs: {} }, // tomorrow day 6
    { id: "u3", sobriety_start_date: "2026-02-22", notification_prefs: {} }, // tomorrow day 30
  ];

  const result = computeUsersApproachingMilestone(profiles, now);
  assertEquals(result.map((r) => `${r.userId}:${r.milestoneDay}`).sort(), ["u1:7", "u3:30"]);
});
