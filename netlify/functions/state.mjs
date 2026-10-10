import { getStore } from "@netlify/blobs";
export default async () => {
  const s = (await getStore("gold").get("state", { type: "json" })) || {};
  return new Response(JSON.stringify(s), { headers: { "content-type": "application/json", "cache-control": "no-store" } });
};
export const config = { path: "/api/state" };
