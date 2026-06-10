# 📱 Nibble Simulator

A browser-based iPhone shell so you can try Nibble on any computer — no Mac, no
Xcode. It renders a realistic device frame (Dynamic Island, status bar, home
indicator, hardware buttons) around the real Nibble app.

> Honest note: this is a device-shell *simulator*, not an Apple emulator — it
> runs Nibble's web build, which mirrors the native SwiftUI app screen-for-
> screen. To run the actual native binary you still need Xcode's iOS Simulator
> on a Mac (`open ios/Nibble/Nibble.xcodeproj`, press ⌘R).

## Run it

From the **repo root**:

```bash
python3 -m http.server 8000
```

then open <http://localhost:8000/simulator/> in your browser.

(Or double-click `start-simulator.sh` on macOS/Linux, `start-simulator.bat` on
Windows — both do exactly that for you.)

Serving over http matters: it lets the app save your progress (localStorage)
and lets the Reset button work. Opening the file directly may run in a
restricted sandbox depending on your browser.

## Features

- **iPhone 15 Pro** frame (Dynamic Island, home indicator) and **iPhone SE**
  frame (home button) — switch at the top.
- Live status-bar clock.
- Auto-scales to fit your window.
- **Reset app data** — wipe the Sprout and start fresh.
- **Open app full-page** — run Nibble without the device chrome.

Everything you do in the simulator is the real app: log meals, earn Dewdrops,
buy skins, build streaks. Progress persists between visits on the same browser.
