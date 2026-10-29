---
name: dock-app
description: Turn a local file, config or folder on the user's Mac into a one-click app in the Dock - a small Bun server bound to localhost, a single HTML page that reads and writes the files, and a .app launcher that starts the server on demand. Use when the user wants a UI, dashboard, toggle panel or control page for something on their own machine (settings, dotfiles, config, local data, notes, scripts) that a web artifact cannot reach, or asks to "make this an app", "put it on my Dock" or "one click to open".
---

# Dock app

A web artifact cannot touch the user's disk. A dock app can: a local Bun server reads and writes the files, a plain HTML page is the UI, and a `.app` wrapper starts it all from the Dock or Spotlight. No Electron, no build step, nothing on the network.

```
Dock icon -> Name.app (AppleScript) -> open.sh -> server up? -> no: start bun server.ts in the background
                                                           -> open http://localhost:<port> in the default browser
```

macOS only. Needs [Bun](https://bun.sh).

## 1. Find the source of truth

Before writing UI, pin down exactly what the page changes:

- **Prefer the official setting** over moving files around. Look for a supported config key first: docs, `--help`, the tool's settings schema, or `strings <binary> | grep <guess>`. A setting is reversible and survives updates; renaming or deleting files is neither.
- Read the real files. Note every format variant (quoted values, multi-line YAML, symlinks, folders that are not entries, names that differ from folder names).
- Decide which file is written, and that only one is.

## 2. Build it

Make a folder for the tool outside any repo, for example `~/.<tool>/<app-name>/` or `~/.local/share/<app-name>/`. Start from this skill's `assets/`:

- `server.ts`: `Bun.serve` on `127.0.0.1` only. `GET` returns state, `POST` applies a patch, `/` serves `index.html`, and there is a cheap health route.
  - On every write, read the file fresh, change only the keys sent, and write it back. Keep every other key.
  - Delete a key when it returns to its default, so the file stays minimal.
  - Validate input against the allowed values and return 400 with the reason.
- `index.html`: one self-contained file, no CDN, no framework. Color tokens on `:root` with a `prefers-color-scheme: dark` override, a page width that works at 375px, and `white-space: nowrap` on short control labels. Save on each change and show a short "Saved" toast; use `confirm()` before bulk changes. Show what each change costs or does, not just its name.
- `open.sh`: set the port and health route. It finds bun by absolute path because Dock-launched apps get a bare `PATH`, starts the server with `nohup` so it outlives the launcher, waits for it, then opens the page.

Pick an unused port: `lsof -iTCP:<port> -sTCP:LISTEN` prints nothing.

Before the first write to a file the user cares about, back it up once next to the original (`<file>.bak-<app-name>`).

## 3. Wrap it in an app

Ask the user whether to pin it to the Dock first: pinning restarts the Dock, so the icons flicker once.

```bash
chmod +x <folder>/open.sh
sh <this skill's folder>/scripts/make-app.sh "<App Name>" <folder>/open.sh --dock
```

The script builds `/Applications/<App Name>.app` (`~/Applications` when `/Applications` is not writable), indexes it for Spotlight, and with `--dock` pins it unless it is already pinned. Leave off `--dock` to skip pinning.

## 4. Verify end to end

Do every step. Do not report it working until each passes:

1. **API**: `curl` the GET route and check the data matches the files on disk.
2. **Round trip**: change one value through the API or the page, confirm the file changed and other keys did not, change it back, and `diff` against the backup.
3. **Cold start**: kill the server (`lsof -t -iTCP:<port> -sTCP:LISTEN | xargs kill`), `open "/Applications/<App Name>.app"`, and confirm the server answers and its parent PID is 1, so it is detached.
4. **Look at it**: in a browser pane if available, check light, dark and 375px wide. Fix wrapping controls, labels that break mid-phrase, and toolbars that leave one button alone on a line.

## Pitfalls

- `~/Applications` is not the `/Applications` folder people browse in Finder. Build into `/Applications` and say where it is.
- A server started from your own shell dies with the session. Start it through `open.sh` (`nohup`, `&`) so it survives.
- After changing server files, kill the running server or the app keeps serving the old ones.
- Never bind `0.0.0.0`. The page can write files on the user's machine.
- Changes to tool settings usually apply to new sessions or restarts only. Tell the user.

## Tell the user

Where the app and its files are, what file it writes and where the backup is, that the server stays running in the background and starts again on the first open after a reboot, and how to remove it:

```bash
lsof -t -iTCP:<port> -sTCP:LISTEN | xargs kill; rm -rf "/Applications/<App Name>.app" <folder>
```

For a worked example, see the `skill-manager` skill, which follows this pattern.
