import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const BLOCKLIST_PATTERNS = [
  /suicid/i,
  /kill\s*(my|him|her|them)?self/i,
  /heroin/i,
  /cocaine/i,
  /fentanyl/i,
  /meth(amphetamine)?/i,
  /https?:\/\//i,
  /bit\.ly/i,
  /t\.co/i,
];

serve(async (req: Request) => {
  try {
    const body = await req.json();
    console.log("[moderate_three_am_post] invoked", JSON.stringify(body));

    const { record } = body;
    if (!record) {
      console.log("[moderate_three_am_post] no record found");
      return new Response(JSON.stringify({ error: "no record" }), { status: 400 });
    }

    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const supabase = createClient(supabaseUrl, serviceRoleKey);

    const text = record.outcome_text || "";
    const isFlagged = BLOCKLIST_PATTERNS.some((p) => p.test(text));

    console.log(`[moderate_three_am_post] triggered for row ${record.id}, flagged: ${isFlagged}`);

    if (isFlagged) {
      await supabase.from("moderation_queue").insert({
        table_name: "three_am_wall",
        row_id: record.id,
        reason: "blocklist_match",
      });
      console.log(`[moderate_three_am_post] is_visible set to false (flagged)`);
    } else {
      await supabase
        .from("three_am_wall")
        .update({ is_visible: true, auto_moderated_at: new Date().toISOString() })
        .eq("id", record.id);
      console.log(`[moderate_three_am_post] is_visible set to true`);
    }

    return new Response(JSON.stringify({ success: true, flagged: isFlagged }), {
      headers: { "Content-Type": "application/json" },
    });
  } catch (error) {
    console.error("[moderate_three_am_post] error:", error);
    return new Response(JSON.stringify({ error: "internal_server_error" }), { status: 500 });
  }
});
