#!/bin/sh
# Wraps a launcher script in a double-clickable .app, and with --dock pins it to the Dock.
# Usage: sh make-app.sh "<App Name>" <absolute path to launcher> [--dock]
set -e

name=$1
launcher=$2
[ -n "$name" ] && [ -n "$launcher" ] || { echo "Usage: make-app.sh \"<App Name>\" <launcher> [--dock]" >&2; exit 1; }
[ "$(uname)" = "Darwin" ] || { echo "macOS only." >&2; exit 1; }
case "$launcher" in /*) ;; *) echo "Launcher path must be absolute." >&2; exit 1 ;; esac
[ -x "$launcher" ] || { echo "Launcher is missing or not executable: $launcher" >&2; exit 1; }

# /Applications is where people look; fall back to ~/Applications if it is not writable.
apps=/Applications
[ -w "$apps" ] || { apps="$HOME/Applications"; mkdir -p "$apps"; }
app="$apps/$name.app"
rm -rf "$app"
osacompile -o "$app" -e "do shell script \"'$launcher' > /dev/null 2>&1\""
mdimport "$app" 2>/dev/null || true
echo "Built $app"

if [ "$3" = "--dock" ]; then
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
