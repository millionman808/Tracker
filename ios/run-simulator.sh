#!/usr/bin/env bash
# Build Nibble (Swift/SwiftUI) and launch it in the Xcode iOS Simulator.
# Run this on a Mac with Xcode installed:   ./ios/run-simulator.sh
# Optionally pass a simulator name:         ./ios/run-simulator.sh "iPhone 16 Pro"
set -euo pipefail
cd "$(dirname "$0")/Nibble"

if ! command -v xcodebuild >/dev/null 2>&1; then
  echo "❌ Xcode is required. Install it from the Mac App Store, then run:"
  echo "   sudo xcode-select -s /Applications/Xcode.app/Contents/Developer"
  exit 1
fi

# Pick a simulator: use the argument, or the newest available iPhone.
NAME="${1:-}"
if [ -n "$NAME" ]; then
  LINE=$(xcrun simctl list devices available | grep -F "$NAME (" | tail -1 || true)
else
  LINE=$(xcrun simctl list devices available | grep -E '^\s*iPhone' | tail -1 || true)
fi
if [ -z "$LINE" ]; then
  echo "❌ No available iPhone simulator found. Open Xcode once to install one"
  echo "   (Xcode → Settings → Components), or list devices with:"
  echo "   xcrun simctl list devices available"
  exit 1
fi
UDID=$(echo "$LINE" | grep -Eo '[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}')
echo "📱 Using simulator: $(echo "$LINE" | sed -E 's/^ *//; s/ \(.*//') ($UDID)"

# Build for the simulator.
DERIVED="$(mktemp -d)/DerivedData"
echo "🔨 Building Nibble…"
xcodebuild -project Nibble.xcodeproj -scheme Nibble -configuration Debug \
  -destination "id=$UDID" \
  -derivedDataPath "$DERIVED" \
  CODE_SIGNING_ALLOWED=NO build | tail -3

APP="$DERIVED/Build/Products/Debug-iphonesimulator/Nibble.app"
[ -d "$APP" ] || { echo "❌ Build product not found at $APP"; exit 1; }

# Boot, install, launch.
xcrun simctl boot "$UDID" 2>/dev/null || true   # ok if already booted
open -a Simulator
xcrun simctl install "$UDID" "$APP"
xcrun simctl launch "$UDID" com.nibble.sproutsnacks
echo "🌱 Nibble is running in the simulator. Enjoy your Sprout!"
