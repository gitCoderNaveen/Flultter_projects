import { serve } from "https://deno.land/std/http/server.ts";

serve(async (req) => {
  try {
    const { token, title, body } = await req.json();

    const resp = await fetch("https://fcm.googleapis.com/fcm/send", {
      method: "POST",
      headers: {
        "Authorization": "key=" + Deno.env.get("FCM_SERVER_KEY"), // stored in Supabase secrets
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        to: token,
        notification: { title, body },
        priority: "high",
      }),
    });

    return new Response(await resp.text(), { status: resp.status });
  } catch (e) {
    return new Response("Error: " + e.message, { status: 500 });
  }
});
