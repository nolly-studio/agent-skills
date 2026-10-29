---
name: skill-manager
description: Install a one-click Mac app for turning Claude Code skills on and off. It lists every skill in ~/.claude/skills with its description size and writes the skillOverrides setting (on, name-only, user-invocable-only, off). Use when the user wants to disable, hide or manage their global or personal skills, has too many skills installed, wants a smaller system prompt, or asks for a skill toggle UI.
---

# Skill manager

Installs a small local page, served by Bun on `127.0.0.1:4477`, plus a `Skill Manager.app` the user can open from the Dock or Spotlight. Each toggle writes `skillOverrides` in `~/.claude/settings.json`. New Claude Code sessions pick it up.

## The setting it writes

```json
{ "skillOverrides": { "<skill name>": "off" } }
```

| Value | Effect |
| --- | --- |
| absent (`on`) | Name and description listed; Claude can pick it on its own |
| `name-only` | Listed by name without the description. Cheaper, picked less reliably |
| `user-invocable-only` | Hidden from Claude; runs only when the user types `/name` |
| `off` | Not loaded |

The key is the `name:` in the skill's SKILL.md frontmatter, not always the folder name. The page drops a key when it is set back to `on`, so the file stays clean. If `skillOverrides` is not recognised, the user's Claude Code is too old: have them update. In an interactive `claude` terminal, `/skills` toggles the same setting.

## Install

Requirements: macOS and [Bun](https://bun.sh).

1. Ask whether to pin the app to the Dock. Pinning restarts the Dock, so the icons flicker once.
2. Run `sh <this skill's folder>/scripts/install.sh`, adding `--dock` if they said yes. The script:
   - copies `assets/` to `~/.claude/skill-manager/`
   - backs up `~/.claude/settings.json` once, to `settings.json.bak-skill-manager`
   - builds `/Applications/Skill Manager.app`, or `~/Applications` when `/Applications` is not writable
   - stops a running server so the next open serves the new files
3. Open it with `open "/Applications/Skill Manager.app"`. The app starts the server if it is down, waits for it, and opens the page in the default browser. The server keeps running in the background after that and starts again on the first open after a reboot.

## Verify

Do not report success without these:

1. `curl -s localhost:4477/api/skills | jq length` matches the number of skill folders with a SKILL.md.
2. Toggle one skill to `off` (in the page or with `curl -XPOST localhost:4477/api/skills -d '{"<name>":"off"}'`), check `jq .skillOverrides ~/.claude/settings.json`, then set it back to `on` and `diff` the settings file against the backup. Other keys must be unchanged.
3. Cold start: kill the server (`lsof -t -iTCP:4477 -sTCP:LISTEN | xargs kill`), open the app, and confirm the API answers again.
4. If a browser pane is available, look at the page in light, dark and at 375px wide.

## Tell the user

- Where the app is. Apps in `~/Applications` are not in the `/Applications` list people usually check in Finder.
- That changes apply to new sessions, not the current one.
- That `off` hides a skill from Claude Code but leaves it installed. Skills installed with the `skills` CLI are symlinks into `~/.agents/skills`; remove those with that CLI.
- Files: `~/.claude/skill-manager/` (`server.ts`, `index.html`, `open.sh`, `server.log`).

## Uninstall

```bash
lsof -t -iTCP:4477 -sTCP:LISTEN | xargs kill; rm -rf "/Applications/Skill Manager.app" ~/.claude/skill-manager
```

Then drag the icon off the Dock. The `skillOverrides` entries stay until removed from `~/.claude/settings.json`.
