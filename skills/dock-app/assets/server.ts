// Starter server for a local dock app. One JSON file is the state; the page
// reads it with GET /api/state and changes it with POST /api/state.
// Replace FILE, PORT and the patch logic with the tool's own.

import { existsSync, readFileSync, writeFileSync } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";

const PORT = Number(process.env.PORT ?? 4480);
const FILE = join(homedir(), ".example", "config.json");

const read = (): Record<string, unknown> =>
  existsSync(FILE) ? JSON.parse(readFileSync(FILE, "utf8")) : {};

// Read the file fresh on every write and change only the keys the page sent,
// so edits made by other programs in between are kept.
const write = (patch: Record<string, unknown>) => {
  const next = { ...read() };
  for (const [key, value] of Object.entries(patch)) {
    if (value === null) delete next[key];
    else next[key] = value;
  }
  writeFileSync(FILE, `${JSON.stringify(next, null, 2)}\n`);
};

Bun.serve({
  async fetch(req) {
    const url = new URL(req.url);
    if (url.pathname === "/api/health") return new Response("ok");
    if (url.pathname === "/api/state" && req.method === "GET") {
      return Response.json(read());
    }
    if (url.pathname === "/api/state" && req.method === "POST") {
      try {
        write(await req.json());
        return Response.json(read());
      } catch (error) {
        return Response.json({ error: String(error) }, { status: 400 });
      }
    }
    if (url.pathname === "/") {
      return new Response(Bun.file(join(import.meta.dir, "index.html")));
    }
    return new Response("Not found", { status: 404 });
  },
  // Local only: never listen on the network.
  hostname: "127.0.0.1",
  port: PORT,
});

console.log(`Listening on http://localhost:${PORT}`);
