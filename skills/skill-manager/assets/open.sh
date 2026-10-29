#!/bin/sh
# Starts the skill manager server if it is not running, then opens the page.
# Apps launched from the Dock get a bare PATH, so look for bun in the usual places.
dir=$(cd "$(dirname "$0")" && pwd)
url=http://localhost:${PORT:-4477}
for candidate in "$HOME/.bun/bin/bun" /opt/homebrew/bin/bun /usr/local/bin/bun; do
  [ -x "$candidate" ] && bun=$candidate && break
done
if ! curl -s -o /dev/null "$url/api/skills"; then
  nohup "$bun" "$dir/server.ts" > "$dir/server.log" 2>&1 &
  i=0
  until curl -s -o /dev/null "$url/api/skills" || [ $i -ge 50 ]; do sleep 0.1; i=$((i + 1)); done
fi
open "$url"
