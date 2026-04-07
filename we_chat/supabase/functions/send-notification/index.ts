// =======================
// 7. SUPABASE EDGE FUNCTION (DENO)
// =======================

// @ts-ignore
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

serve(async (req:Request) => {
  const { token, message } = await req.json();

  await fetch("https://fcm.googleapis.com/fcm/send", {
    method: "POST",
    headers: {
      "Authorization": "key=AIzaSyD_6Nvd8vDy0q8TTegjk3ExbIhIuAVylAE",
      "Content-Type": "application/json"
    },
    body: JSON.stringify({
      to: token,
      notification: {
        title: "New Message",
        body: message
      }
    })
  });

  return new Response(JSON.stringify({ success: true }));
});