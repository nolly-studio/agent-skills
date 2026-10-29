#!/bin/sh
# Starts the server if it is not running, then opens the page.
# Replace PORT and HEALTH with the tool's port and a cheap GET route.
# Apps launched from the Dock get a bare PATH, so look for bun in the usual places.
PORT=4480
HEALTH=/api/health
dir=$(cd "$(dirname "$0")" && pwd)
url=http://localhost:$PORT
for candidate in "$HOME/.bun/bin/bun" /opt/homebrew/bin/bun /usr/local/bin/bun; do
  [ -x "$candidate" ] && bun=$candidate && break
done
if ! curl -s -o /dev/null "$url$HEALTH"; then
  nohup "$bun" "$dir/server.ts" > "$dir/server.log" 2>&1 &
  i=0
  until curl -s -o /dev/null "$url$HEALTH" || [ $i -ge 50 ]; do sleep 0.1; i=$((i + 1)); done
fi
open "$url"
