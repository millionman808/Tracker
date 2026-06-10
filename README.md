# 🌱 Nibble — Sprout Snacks

A supportive calorie tracker where you care for a cute companion (a **Sprout**)
by **logging your meals**. The reward loop is built around consistency and
self-care — never restriction or guilt.

> **Core design choice:** the Sprout is **never** sad or punished when you eat
> "too much" or go over a goal. Companion moods derive from *logging activity
> and time of day*, never from calorie counts, and currency is *never* earned
> for eating less. That single decision keeps Nibble supportive, not
> shame-driven.

## This repo

| Path | What it is |
| --- | --- |
| **[`ios/Nibble`](ios/Nibble)** | The **native iOS app** (SwiftUI). The product. On a Mac: `./ios/run-simulator.sh` builds and launches it in the iOS Simulator, or open `ios/Nibble/Nibble.xcodeproj` in Xcode 15+ and press ⌘R. |
| **[`web-prototype`](web-prototype)** | The original self-contained web prototype (vanilla HTML/CSS/JS). Kept as a runnable design reference. |

The native iOS app is a full SwiftUI rewrite of the prototype — same supportive
philosophy and core loop, rebuilt with `@Observable` state, on-device JSON
persistence, opt-in local reminders, and a Sprout companion drawn entirely with
SwiftUI shapes. See **[`ios/Nibble/README.md`](ios/Nibble/README.md)** for build
instructions and architecture.

## Core loop

Log a meal → your Sprout reacts happily → you earn **Dewdrops** 💧 → you build
daily **streaks** → you spend Dewdrops on **decorations & Sprout skins** → your
Sprout's home grows over time.

## Screens

🏡 Home · ➕ Log · 📋 Today · 🛍️ Shop · 📈 Stats · ⚙️ Settings

## Gamification

- **Dewdrops** — earned for logging, hydration and consistency. Never for eating
  less.
- **Streaks** — consecutive logging days, with a forgiving **streak-freeze** so
  one missed day is never catastrophic.
- **Decorations & rooms**, **companion moods** (tied to logging + time of day),
  and gentle **milestone** celebrations.

---

*No accounts, no ads, no shame — just a small green friend cheering you on for
showing up.*
