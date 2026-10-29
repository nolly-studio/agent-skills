#!/bin/sh
# Installs the skill manager: copies the server and page to ~/.claude/skill-manager,
# builds "Skill Manager.app", and with --dock pins it to the Dock.
# Usage: sh install.sh [--dock]
set -e

skill_dir=$(cd "$(dirname "$0")/.." && pwd)
target="$HOME/.claude/skill-manager"
app_name="Skill Manager"

[ "$(uname)" = "Darwin" ] || { echo "macOS only." >&2; exit 1; }
bun=""
for candidate in "$HOME/.bun/bin/bun" /opt/homebrew/bin/bun /usr/local/bin/bun; do
  [ -x "$candidate" ] && bun=$candidate && break
done
[ -n "$bun" ] || { echo "bun not found. Install it from https://bun.sh first." >&2; exit 1; }

mkdir -p "$target"
cp "$skill_dir/assets/server.ts" "$skill_dir/assets/index.html" "$skill_dir/assets/open.sh" "$target/"
chmod +x "$target/open.sh"

settings="$HOME/.claude/settings.json"
if [ -f "$settings" ] && [ ! -f "$settings.bak-skill-manager" ]; then
  cp "$settings" "$settings.bak-skill-manager"
  echo "Backed up settings to $settings.bak-skill-manager"
fi

# /Applications is where people look; fall back to ~/Applications if it is not writable.
apps=/Applications
[ -w "$apps" ] || { apps="$HOME/Applications"; mkdir -p "$apps"; }
app="$apps/$app_name.app"
rm -rf "$app"
osacompile -o "$app" -e "do shell script \"\$HOME/.claude/skill-manager/open.sh > /dev/null 2>&1\""
mdimport "$app" 2>/dev/null || true
echo "Built $app"

# Restart a running server so it serves the files just copied.
pid=$(lsof -t -iTCP:4477 -sTCP:LISTEN 2>/dev/null || true)
[ -n "$pid" ] && kill "$pid"

if [ "$1" = "--dock" ]; then
  encoded=$(printf '%s' "$app" | sed 's/ /%20/g')
  if defaults read com.apple.dock persistent-apps 2>/dev/null | grep -q "file://$encoded/"; then
    echo "Already in the Dock"
  else
    defaults write com.apple.dock persistent-apps -array-add \
      "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>file://$encoded/</string><key>_CFURLStringType</key><integer>15</integer></dict></dict></dict>"
    killall Dock
    echo "Pinned to the Dock"
  fi
fi
