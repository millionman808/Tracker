/* =========================================================================
   Nibble — state & persistence.
   All data lives in localStorage under a single key. No backend required.
   Exposes window.Store with load/save + domain actions.
   ========================================================================= */
(function () {
  'use strict';

  const KEY = 'nibble.save.v1';
  const D = window.NIBBLE_DATA;

  // ---- date helpers (local time, YYYY-MM-DD keys) ----------------------
  function todayKey(d) {
    const t = d || new Date();
    const y = t.getFullYear();
    const m = String(t.getMonth() + 1).padStart(2, '0');
    const day = String(t.getDate()).padStart(2, '0');
    return `${y}-${m}-${day}`;
  }
  function dayDiff(aKey, bKey) {
    // whole days between two YYYY-MM-DD keys (b - a)
    const a = new Date(aKey + 'T00:00:00');
    const b = new Date(bKey + 'T00:00:00');
    return Math.round((b - a) / 86400000);
  }

  function defaultState() {
    return {
      createdAt: Date.now(),
      dewdrops: 25, // a little starter pocket money
      goal: null,   // null = goal-free mode
      sproutName: 'Sprout',
      activeSkin: 'skin_sprout',
      activeWall: null,
      owned: ['skin_sprout'],
      pro: false,
      water: { goal: D.WATER_GOAL_DEFAULT },
      streak: { current: 0, best: 0, lastLogDay: null, freezes: 1 },
      settings: { remindersOn: false, showMacros: false },
      // days: { 'YYYY-MM-DD': { entries:[...], water: n, waterRewarded: bool } }
      days: {},
      // recent foods (most-recent-first, deduped by name)
      recent: [],
      favorites: [],
      earnedMilestones: [],
      stats: {
        totalFoodsLogged: 0,
        waterGoalsHit: 0,
        uniqueFoods: {} // name -> true
      }
    };
  }

  let state = null;

  function load() {
    try {
      const raw = localStorage.getItem(KEY);
      if (raw) {
        state = Object.assign(defaultState(), JSON.parse(raw));
        // deep-ish defaults for nested objects added in later versions
        state.stats = Object.assign(defaultState().stats, state.stats || {});
        state.streak = Object.assign(defaultState().streak, state.streak || {});
        state.settings = Object.assign(defaultState().settings, state.settings || {});
        state.water = Object.assign(defaultState().water, state.water || {});
      } else {
        state = defaultState();
        // seed recents with a few starters so day one isn't empty
        state.recent = D.STARTER_FOODS.slice(0, 6).map(f => ({ ...f }));
        save();
      }
    } catch (e) {
      console.warn('Nibble: failed to load, resetting.', e);
      state = defaultState();
    }
    return state;
  }

  function save() {
    try {
      localStorage.setItem(KEY, JSON.stringify(state));
    } catch (e) {
      console.warn('Nibble: save failed', e);
    }
  }

  function get() { return state; }

  function dayRecord(key) {
    const k = key || todayKey();
    if (!state.days[k]) {
      state.days[k] = { entries: [], water: 0, waterRewarded: false };
    }
    return state.days[k];
  }

  function totalForDay(key) {
    const rec = state.days[key || todayKey()];
    if (!rec) return 0;
    return rec.entries.reduce((sum, e) => sum + e.cal, 0);
  }

  function macrosForDay(key) {
    const rec = state.days[key || todayKey()];
    const out = { p: 0, c: 0, f: 0 };
    if (!rec) return out;
    rec.entries.forEach(e => {
      out.p += e.p || 0; out.c += e.c || 0; out.f += e.f || 0;
    });
    return out;
  }

  // ---- streak logic ----------------------------------------------------
  function touchStreak() {
    const today = todayKey();
    const s = state.streak;
    if (s.lastLogDay === today) return; // already counted today

    if (s.lastLogDay === null) {
      s.current = 1;
    } else {
      const gap = dayDiff(s.lastLogDay, today);
      if (gap === 1) {
        s.current += 1;
      } else if (gap === 2 && s.freezes > 0) {
        // a single missed day is forgiven by a freeze (rest day)
        s.freezes -= 1;
        s.current += 1;
      } else if (gap <= 0) {
        // clock weirdness; treat as same day
        return;
      } else {
        s.current = 1; // streak reset, but gently — no penalty, just restart
      }
    }
    s.lastLogDay = today;
    s.best = Math.max(s.best, s.current);
  }

  // ---- actions ---------------------------------------------------------
  function addEntry(food) {
    const rec = dayRecord();
    const entry = {
      id: 'e' + Date.now() + Math.floor(Math.random() * 999),
      name: food.name,
      cal: Math.round(food.cal),
      p: food.p || 0, c: food.c || 0, f: food.f || 0,
      meal: food.meal || 'snack',
      at: Date.now()
    };
    rec.entries.push(entry);

    // recents (dedupe by lowercased name, keep latest macros)
    state.recent = state.recent.filter(r => r.name.toLowerCase() !== food.name.toLowerCase());
    state.recent.unshift({ name: food.name, cal: entry.cal, p: entry.p, c: entry.c, f: entry.f, meal: entry.meal });
    state.recent = state.recent.slice(0, 20);

    // stats
    state.stats.totalFoodsLogged += 1;
    state.stats.uniqueFoods[food.name.toLowerCase()] = true;

    // streak + currency
    const wasNewDay = state.streak.lastLogDay !== todayKey();
    touchStreak();
    let earned = D.REWARDS.logMeal;
    if (wasNewDay) earned += D.REWARDS.streakDay;
    addDewdrops(earned);

    const newMilestones = checkMilestones();
    save();
    return { entry, earned, newMilestones };
  }

  function removeEntry(id) {
    const rec = dayRecord();
    rec.entries = rec.entries.filter(e => e.id !== id);
    save();
  }

  function updateEntry(id, patch) {
    const rec = dayRecord();
    const e = rec.entries.find(x => x.id === id);
    if (e) Object.assign(e, patch);
    save();
  }

  function addWater(cups) {
    const rec = dayRecord();
    rec.water = Math.max(0, rec.water + cups);
    let earned = 0;
    if (cups > 0) earned += D.REWARDS.waterCup * cups;
    // goal bonus, once per day
    if (!rec.waterRewarded && rec.water >= state.water.goal) {
      rec.waterRewarded = true;
      earned += D.REWARDS.waterGoalBonus;
      state.stats.waterGoalsHit += 1;
    }
    if (earned > 0) addDewdrops(earned);
    const newMilestones = checkMilestones();
    save();
    return { earned, water: rec.water, newMilestones };
  }

  function addDewdrops(n) {
    state.dewdrops = Math.max(0, state.dewdrops + n);
  }

  function toggleFavorite(food) {
    const i = state.favorites.findIndex(f => f.name.toLowerCase() === food.name.toLowerCase());
    if (i >= 0) state.favorites.splice(i, 1);
    else state.favorites.unshift({ name: food.name, cal: food.cal, p: food.p, c: food.c, f: food.f, meal: food.meal });
    save();
    return i < 0;
  }
  function isFavorite(name) {
    return state.favorites.some(f => f.name.toLowerCase() === name.toLowerCase());
  }

  // ---- shop ------------------------------------------------------------
  function buy(itemId) {
    const item = D.SHOP.find(x => x.id === itemId);
    if (!item) return { ok: false, reason: 'not found' };
    if (state.owned.includes(itemId)) return { ok: false, reason: 'owned' };
    if (item.pro && !state.pro) return { ok: false, reason: 'pro' };
    if (state.dewdrops < item.price) return { ok: false, reason: 'funds' };
    state.dewdrops -= item.price;
    state.owned.push(itemId);
    const newMilestones = checkMilestones();
    save();
    return { ok: true, item, newMilestones };
  }
  function owns(id) { return state.owned.includes(id); }

  function equipSkin(id) {
    if (!state.owned.includes(id)) return false;
    state.activeSkin = id;
    save();
    return true;
  }
  function equipWall(id) {
    if (id !== null && !state.owned.includes(id)) return false;
    state.activeWall = id;
    save();
    return true;
  }

  // ---- milestones ------------------------------------------------------
  function checkMilestones() {
    const fresh = [];
    D.MILESTONES.forEach(m => {
      if (!state.earnedMilestones.includes(m.id) && m.check(state)) {
        state.earnedMilestones.push(m.id);
        addDewdrops(D.REWARDS.milestone);
        fresh.push(m);
      }
    });
    return fresh;
  }

  // ---- settings --------------------------------------------------------
  function setGoal(val) { state.goal = (val == null || val === '') ? null : Math.max(0, Math.round(val)); save(); }
  function setName(n) { state.sproutName = (n || 'Sprout').slice(0, 16); save(); }
  function setWaterGoal(n) { state.water.goal = Math.max(1, Math.round(n)); save(); }
  function setSetting(k, v) { state.settings[k] = v; save(); }
  function setPro(v) { state.pro = !!v; save(); }

  function resetAll() {
    localStorage.removeItem(KEY);
    state = null;
    return load();
  }

  function exportSave() { return JSON.stringify(state, null, 2); }
  function importSave(json) {
    const parsed = JSON.parse(json);
    state = Object.assign(defaultState(), parsed);
    save();
    return state;
  }

  // ---- companion mood --------------------------------------------------
  // Mood is derived, never tied to calorie amount. Driven by logging + time.
  function currentMood() {
    const hour = new Date().getHours();
    const loggedToday = (state.days[todayKey()] || { entries: [] }).entries.length > 0;
    if (hour >= 22 || hour < 6) return 'sleepy';
    if (loggedToday) return 'happy';
    return 'neutral';
  }

  window.Store = {
    todayKey, dayDiff,
    load, save, get,
    dayRecord, totalForDay, macrosForDay,
    addEntry, removeEntry, updateEntry,
    addWater, addDewdrops,
    toggleFavorite, isFavorite,
    buy, owns, equipSkin, equipWall,
    checkMilestones,
    setGoal, setName, setWaterGoal, setSetting, setPro,
    resetAll, exportSave, importSave,
    currentMood
  };
})();
