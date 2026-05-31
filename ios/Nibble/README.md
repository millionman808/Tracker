# 🌱 Nibble — Sprout Snacks (native iOS app)

A fully native **SwiftUI** rewrite of Nibble: a supportive calorie tracker where
you care for a cute **Sprout** by logging your meals. The reward loop is built
around consistency and self-care — never restriction or guilt.

> **Core design choice:** the Sprout is **never** sad or punished for eating
> "too much" or going over a goal. Companion moods derive from *logging activity
> and time of day*, never from calorie counts. Dewdrops are *never* earned for
> eating less. That keeps the app supportive rather than shame-driven.

## Requirements

- **macOS with Xcode 15 or newer** (Xcode 16 recommended)
- iOS 17.0+ deployment target (iPhone & iPad)

> Note: this project was authored in a Linux environment that has no Swift /
> Xcode toolchain, so it has **not been compiled here**. The code is written to
> standard SwiftUI for iOS 17 and the Xcode project is ready to open — but the
> build/run/submit step happens on your Mac.

## Open & run

```bash
open ios/Nibble/Nibble.xcodeproj
```

1. Select an iPhone simulator (or your device).
2. Press ⌘R.

That's it — there are no third-party dependencies (no CocoaPods / SPM packages).
The project uses Xcode's **synchronized folder** feature, so every file under
`Nibble/` is part of the target automatically; just add files to the folder.

### Optional: regenerate the project with XcodeGen

If you ever want to regenerate `Nibble.xcodeproj` from scratch:

```bash
brew install xcodegen
cd ios/Nibble
xcodegen generate
```

(`project.yml` is the spec. You normally don't need this — the committed
`.xcodeproj` opens directly.)

## Architecture

Plain SwiftUI + the **Observation** framework (`@Observable`). State is a single
`SaveState` value persisted as JSON to Application Support. Everything stays
on-device; nothing is uploaded.

```
Nibble/
├── NibbleApp.swift              @main — creates AppStore, injects environment
├── Models/
│   ├── Models.swift             Codable types: Food, FoodEntry, DayRecord, SaveState…
│   └── GameData.swift           Starter foods, shop catalog, milestones, reward tuning
├── Store/
│   ├── AppStore.swift           @Observable single source of truth + domain actions
│   ├── Persistence.swift        JSON save/load + export/import
│   └── NotificationManager.swift  Opt-in local meal reminders
├── Theme/
│   └── Theme.swift              Palette, button styles, Card, Toast
├── Views/
│   ├── RootView.swift           Shell: top bar, custom tab bar, toast, celebrations
│   ├── HomeView.swift           The Sprout's room + watering-can goal
│   ├── LogView.swift            Add food, recents & favorites, meal picker, macros
│   ├── TodayView.swift          Grouped log + tap-to-fill water
│   ├── ShopView.swift           Skins, wallpapers, decorations, preview-before-buy
│   ├── StatsView.swift          Streak hero, 7-day chart, badges
│   ├── SettingsView.swift       Goal / goal-free, reminders, backup, reset
│   └── SproutView.swift         The companion drawn with SwiftUI Shapes (moods + skins)
└── Assets.xcassets/            App icon + accent color
```

## Screens & features

- 🏡 **Home** — the animated Sprout in its decorated room; today's total as a
  gentle watering-can fill toward an *optional* goal (or goal-free mode).
- ➕ **Log** — manual add by name + calories, one-tap re-log from recents &
  favorites, meal categories, a servings stepper, optional macros.
- 📋 **Today** — entries grouped by meal, running total, delete, and a
  satisfying tap-to-fill water tracker that earns Dewdrops.
- 🛍️ **Shop** — spend Dewdrops on Sprout skins, wallpapers and themed
  decorations; live Sprout preview before buying. A mock **Pro** unlock gates a
  few cosmetics (never any tracking).
- 📈 **Stats** — the logging streak is the hero; calm 7-day chart, lifetime
  totals, consistency badges. Deliberately not weight-focused.
- ⚙️ **Settings** — set/clear daily goal, water goal, macros & reminder toggles,
  JSON export/import backup, privacy note, reset.

## The Sprout

Drawn entirely with SwiftUI `Shape`s and `Canvas`-free composition, animated per
mood (idle, happy, eating, sleepy, celebrating) with five recolourable skins —
so the concept is fully playable with **no external art**. Swap in production
illustrations later without touching the game loop.

---

*No accounts, no ads, no shame — just a small green friend cheering you on for
showing up.*
