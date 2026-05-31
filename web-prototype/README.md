# 🌱 Nibble — Sprout Snacks

A supportive calorie tracker where you care for a cute companion (a **Sprout**) by
**logging your meals**. The reward loop is built around *consistency and self-care* —
never restriction or guilt.

> **Core design choice:** the Sprout is **never sad or punished** when you eat "too
> much" or go over a goal. Tying a pet's distress to eating behaviour reinforces
> unhealthy guilt around food. The celebrated action is *logging and taking care of
> yourself* — not eating less. That single decision keeps Nibble supportive rather
> than shame-driven.

## The core loop

Log a meal → your Sprout is fed and reacts happily → you earn **Dewdrops** 💧 →
you build daily **streaks** → you spend Dewdrops on **decorations** and **Sprout
skins** → your Sprout's home grows over time.

## Run it

No build step, no dependencies, no backend. It's a self-contained web app.

```bash
# from the repo root, any static server works, e.g.:
python3 -m http.server 8000
# then open http://localhost:8000
```

Or just open `index.html` directly in a browser. All progress is saved locally in
your browser via `localStorage` — nothing is uploaded.

## Screens

| Screen | What it does |
| --- | --- |
| 🏡 **Home** | The Sprout's decorated room (centerpiece). Today's total shown as a gentle watering-can fill toward an *optional* goal — no red "over limit" warnings. Quick-add, Dewdrop counter, streak. |
| ➕ **Log** | Quick add by name + calories. Recent foods & favorites for one-tap re-logging. Meal categories, servings adjuster, optional macros. |
| 📋 **Today** | Chronological log grouped by meal, running total, edit/delete, and a tap-to-fill water tracker that earns Dewdrops. |
| 🛍️ **Shop** | Spend Dewdrops on decorations across themed rooms (kitchen, garden, cozy nook), Sprout skins, and wallpapers. Preview-before-buy. |
| 📈 **Stats** | Logging streak (the celebrated metric), a calm 7-day chart, lifetime stats, and consistency badges. Deliberately *not* weight-focused. |
| ⚙️ **Settings** | Set/clear daily goal (goal-free mode allowed), water goal, toggle macros, reminders (demo), backup/transfer (export/import), privacy info, reset. |

## Gamification

- **Dewdrops** 💧 — earned for logging meals, hitting your water goal, and keeping
  streaks. *Never* for eating below a target.
- **Streaks** — consecutive logging days. Forgiving by design: a **streak-freeze**
  forgives one missed day so a slip never feels catastrophic.
- **Decorations & rooms** — unlock and furnish progressively.
- **Companion moods** — happy / content / sleepy, tied to *logging activity and
  time of day*, never to calorie counts.
- **Milestones** — gentle celebrations (first bite, 7-day streak, 100 foods…).

## Monetization (concept, matching the Focus Friend model)

- Free core app — no paywalls on tracking or any health functionality.
- A **Pro** tier (mocked with a demo unlock button) for extra themes, more skins,
  and advanced perks.
- One-off cosmetic skins.

## Project structure

```
index.html        # app shell + bottom tab bar
css/styles.css    # cozy, mobile-first styling + Sprout animations
js/data.js        # starter foods, shop catalog, milestones, copy, economy tuning
js/state.js       # state + localStorage persistence + all domain actions
js/sprout.js      # the Sprout companion drawn as animated inline SVG (mood + skins)
js/app.js         # screen rendering, routing, and event wiring
```

## Asset notes

The Sprout is drawn live as SVG with CSS-animated moods (idle, happy, eating,
sleepy, celebrating) and recolorable skins, so the concept is fully playable
without external art. Production art (richer skins, decoration sprites, an app
icon) can drop in later without changing the loop.

---

*A working concept. No accounts, no ads, no shame — just a small green friend
cheering you on for showing up.*
