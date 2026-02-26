// supabase/functions/moderate_three_am_post/index.ts

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const supabase = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? ""
    );

    const payload = await req.json();
    console.log("[WEBHOOK] Otrzymano:", JSON.stringify(payload, null, 2));

    if (payload.type !== "INSERT" || payload.table !== "three_am_wall") {
      return new Response("Nie INSERT three_am_wall", { status: 200 });
    }

    const record = payload.record;
    if (!record?.id || !record?.user_id || !record?.content) {
      return new Response(JSON.stringify({ error: "Brak id/user_id/content" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const content = (record.content as string).toLowerCase().trim();

    // Lista słów kluczowych – bazujemy na Twoim dokumencie + rozszerzenia
    const badWords = [
      "samobójstwo", "samobój", "popełnię samobójstwo", "zabiję się", "powieszę się",
      "podetnę sobie żyły", "skoczę z okna", "nie chcę żyć", "lepiej umrzeć",
      "suicide", "kill myself", "end my life", "hang myself", "cut myself",
      "overdose", "overdosing", "przedawkować", "heroin", "metamfetamina",
      "fentanyl", "kokaina", "crack", "diler", "sprzedam prochy", "kupię dragi",
      "http", "https://", "www.", "bit.ly", "tinyurl"
    ];

    let isToxic = badWords.some(word => content.includes(word));
    let reason = isToxic ? "dopasowanie słów kluczowych" : "";

    // Prosty filtr linków (lepszy niż tylko "http")
    if (/(https?:\/\/[^\s]+)|(www\.[^\s]+)|(bit\.ly|tinyurl\.com)/i.test(content)) {
      isToxic = true;
      reason += (reason ? " + " : "") + "podejrzany link";
    }

    const updateData = {
      is_visible: !isToxic,
      auto_moderated_at: new Date().toISOString(),
    };

    // Aktualizacja rekordu
    const { error: updateErr } = await supabase
      .from("three_am_wall")
      .update(updateData)
      .eq("id", record.id);

    if (updateErr) throw updateErr;

    // Jeśli toksyczne → do moderation_queue
    if (isToxic) {
      await supabase
        .from("moderation_queue")
        .insert({
          table_name: "three_am_wall",
          row_id: record.id,
          user_id: record.user_id,
          reason: reason || "Wykryto treść potencjalnie szkodliwą",
          content: record.content,
          status: "pending",
        })
        .catch(err => console.error("Queue insert failed:", err));
    }

    return new Response(
      JSON.stringify({ success: true, is_visible: updateData.is_visible }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" }, status: 200 }
    );
  } catch (err) {
    console.error("Błąd funkcji:", err);
    return new Response(
      JSON.stringify({ error: err.message }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" }, status: 500 }
    );
  }
});