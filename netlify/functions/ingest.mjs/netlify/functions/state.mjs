import { getStore } from "@netlify/blobs";
export default async (req) => {
  if (req.method !== "POST") return new Response("POST only", { status: 405 });
  const key = new URL(req.url).searchParams.get("key") || req.headers.get("x-key");
  if (!process.env.GOLD_KEY || key !== process.env.GOLD_KEY) return new Response("unauthorized", { status: 401 });
  let b; try { b = await req.json(); } catch { return new Response("bad json", { status: 400 }); }
  if (!Array.isArray(b.ltf) || b.ltf.length < 20) return new Response("need ltf candles", { status: 400 });
  await getStore("gold").setJSON("state", { ts: Date.now(), htf: b.htf || [], ltf: b.ltf });
  return new Response("ok");
};
export const config = { path: "/api/ingest" };
