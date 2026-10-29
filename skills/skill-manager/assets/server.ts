// Local page for turning personal skills on and off.
// Reads ~/.claude/skills and writes the `skillOverrides` setting in
// ~/.claude/settings.json, which Claude Code reads at session start.
// Run: bun ~/.claude/skill-manager/server.ts, then open http://localhost:4477

import { existsSync, readdirSync, readFileSync, writeFileSync } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";

const PORT = Number(process.env.PORT ?? 4477);
const SKILLS_DIR = join(homedir(), ".claude", "skills");
const SETTINGS = join(homedir(), ".claude", "settings.json");
const MODES = ["on", "name-only", "user-invocable-only", "off"] as const;
type Mode = (typeof MODES)[number];

const readSettings = (): Record<string, unknown> =>
  existsSync(SETTINGS) ? JSON.parse(readFileSync(SETTINGS, "utf8")) : {};

const field = (frontmatter: string, key: string): string => {
  const lines = frontmatter.split("\n");
  const i = lines.findIndex((l) => l.startsWith(`${key}:`));
  if (i === -1) return "";
  let value = lines[i].slice(key.length + 1).trim();
  if (value === "|" || value === ">" || value === ">-" || value === "|-") {
    const block: string[] = [];
    for (const line of lines.slice(i + 1)) {
      if (!/^\s+/.test(line)) break;
      block.push(line.trim());
    }
    value = block.join(" ");
  }
  return value.replace(/^(['"])(.*)\1$/, "$2");
};

const listSkills = () => {
  const overrides = (readSettings().skillOverrides ?? {}) as Record<string, Mode>;
  return readdirSync(SKILLS_DIR)
    .map((dir) => {
      const file = join(SKILLS_DIR, dir, "SKILL.md");
      if (!existsSync(file)) return null;
      const text = readFileSync(file, "utf8");
      const frontmatter = text.match(/^---\n([\s\S]*?)\n---/)?.[1] ?? "";
      const name = field(frontmatter, "name") || dir;
      const description = field(frontmatter, "description");
      return { description, mode: overrides[name] ?? "on", name };
    })
    .filter((s) => s !== null)
    .sort((a, b) => a.name.localeCompare(b.name));
};

const setModes = (changes: Record<string, Mode>) => {
  const settings = readSettings();
  const overrides = { ...(settings.skillOverrides as Record<string, Mode>) };
  for (const [name, mode] of Object.entries(changes)) {
    if (!MODES.includes(mode)) throw new Error(`Unknown mode: ${mode}`);
    if (mode === "on") delete overrides[name];
    else overrides[name] = mode;
  }
  if (Object.keys(overrides).length === 0) delete settings.skillOverrides;
  else settings.skillOverrides = overrides;
  writeFileSync(SETTINGS, `${JSON.stringify(settings, null, 2)}\n`);
};

Bun.serve({
  async fetch(req) {
    const url = new URL(req.url);
    if (url.pathname === "/api/skills" && req.method === "GET") {
      return Response.json(listSkills());
    }
    if (url.pathname === "/api/skills" && req.method === "POST") {
      try {
        setModes(await req.json());
        return Response.json(listSkills());
      } catch (error) {
        return Response.json({ error: String(error) }, { status: 400 });
      }
    }
    if (url.pathname === "/") {
      return new Response(Bun.file(join(import.meta.dir, "index.html")));
    }
    return new Response("Not found", { status: 404 });
  },
  hostname: "127.0.0.1",
  port: PORT,
});

console.log(`Skill manager on http://localhost:${PORT}`);
