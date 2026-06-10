#!/usr/bin/env bash
# Launch the Nibble iPhone simulator in your browser.
cd "$(dirname "$0")"
PORT=8000
URL="http://localhost:$PORT/simulator/"
echo "Serving Nibble at $URL  (Ctrl+C to stop)"
( sleep 1
  if command -v open >/dev/null;        then open "$URL"        # macOS
  elif command -v xdg-open >/dev/null;  then xdg-open "$URL"    # Linux
  fi ) &
python3 -m http.server "$PORT"
