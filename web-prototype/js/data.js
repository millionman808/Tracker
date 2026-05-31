/* =========================================================================
   Nibble — static data: starter foods, shop catalog, milestones, copy.
   Kept as a plain global (window.NIBBLE_DATA) so the app runs with zero build
   tooling — just open index.html.
   ========================================================================= */
(function () {
  'use strict';

  // A small starter library so "recent / favorites" feels alive on day one.
  // Calories are per single serving as described.
  const STARTER_FOODS = [
    { name: 'Oatmeal with berries', cal: 290, p: 8,  c: 54, f: 5,  meal: 'breakfast' },
    { name: 'Greek yogurt',         cal: 120, p: 17, c: 9,  f: 1,  meal: 'breakfast' },
    { name: 'Scrambled eggs (2)',   cal: 180, p: 12, c: 2,  f: 13, meal: 'breakfast' },
    { name: 'Banana',               cal: 105, p: 1,  c: 27, f: 0,  meal: 'snack' },
    { name: 'Apple',                cal: 95,  p: 0,  c: 25, f: 0,  meal: 'snack' },
    { name: 'Chicken salad',        cal: 350, p: 30, c: 12, f: 18, meal: 'lunch' },
    { name: 'Turkey sandwich',      cal: 320, p: 22, c: 38, f: 9,  meal: 'lunch' },
    { name: 'Veggie stir-fry',      cal: 400, p: 14, c: 52, f: 15, meal: 'dinner' },
    { name: 'Salmon & rice',        cal: 520, p: 34, c: 45, f: 22, meal: 'dinner' },
    { name: 'Mixed nuts (handful)', cal: 170, p: 6,  c: 6,  f: 15, meal: 'snack' },
    { name: 'Latte',                cal: 130, p: 8,  c: 13, f: 5,  meal: 'snack' },
    { name: 'Dark chocolate (2 sq)',cal: 110, p: 1,  c: 11, f: 8,  meal: 'snack' }
  ];

  const MEALS = [
    { id: 'breakfast', label: 'Breakfast', icon: '🌅' },
    { id: 'lunch',     label: 'Lunch',     icon: '🥪' },
    { id: 'dinner',    label: 'Dinner',    icon: '🍽️' },
    { id: 'snack',     label: 'Snack',     icon: '🍎' }
  ];

  // Shop catalog. Each item belongs to a themed room (or is a skin/wallpaper).
  // `pro: true` items are gated behind the (mock) Pro subscription.
  const SHOP = [
    // --- Sprout skins ---
    { id: 'skin_sprout',  type: 'skin', name: 'Classic Sprout',  price: 0,   theme: 'skins', desc: 'The original little sprout.', emoji: '🌱' },
    { id: 'skin_cactus',  type: 'skin', name: 'Cactus Sprout',   price: 120, theme: 'skins', desc: 'Prickly but lovable.',        emoji: '🌵' },
    { id: 'skin_mushroom',type: 'skin', name: 'Mushroom Sprout', price: 150, theme: 'skins', desc: 'A cosy little fungi friend.',  emoji: '🍄' },
    { id: 'skin_sunflower',type:'skin', name: 'Sunflower Sprout',price: 200, theme: 'skins', desc: 'Always facing the light.',     emoji: '🌻' },
    { id: 'skin_cherry',  type: 'skin', name: 'Cherry Sprout',   price: 350, theme: 'skins', desc: 'Sweet and round.', pro: true,  emoji: '🍒' },

    // --- Wallpapers / floors ---
    { id: 'wall_mint',    type: 'wallpaper', name: 'Mint Walls',    price: 60,  theme: 'walls', desc: 'Fresh and calm.',   color: '#d6f5e3' },
    { id: 'wall_peach',   type: 'wallpaper', name: 'Peach Walls',   price: 60,  theme: 'walls', desc: 'Warm and soft.',    color: '#ffe3d3' },
    { id: 'wall_sky',     type: 'wallpaper', name: 'Sky Walls',     price: 90,  theme: 'walls', desc: 'Open and breezy.',  color: '#dceeff' },
    { id: 'wall_lavender',type: 'wallpaper', name: 'Lavender Walls', price: 120, theme: 'walls', desc: 'Dreamy dusk tones.', pro: true, color: '#ece1ff' },

    // --- Kitchen ---
    { id: 'kit_stove',    type: 'decor', name: 'Tiny Stove',     price: 80,  theme: 'kitchen', desc: 'For imaginary soup.', emoji: '🍲', slot: 'floor-left' },
    { id: 'kit_fridge',   type: 'decor', name: 'Mini Fridge',    price: 110, theme: 'kitchen', desc: 'Stocked with snacks.', emoji: '🧊', slot: 'floor-right' },
    { id: 'kit_kettle',   type: 'decor', name: 'Whistle Kettle', price: 70,  theme: 'kitchen', desc: 'Always a brew on.',   emoji: '🫖', slot: 'shelf' },

    // --- Garden ---
    { id: 'gar_planter',  type: 'decor', name: 'Window Planter', price: 90,  theme: 'garden', desc: 'A row of herbs.',     emoji: '🪴', slot: 'shelf' },
    { id: 'gar_tree',     type: 'decor', name: 'Potted Tree',    price: 160, theme: 'garden', desc: 'Shade for naps.',     emoji: '🌳', slot: 'floor-left' },
    { id: 'gar_flowers',  type: 'decor', name: 'Flower Bunch',   price: 75,  theme: 'garden', desc: 'Fresh cut blooms.',   emoji: '💐', slot: 'floor-right' },

    // --- Cozy nook ---
    { id: 'coz_lamp',     type: 'decor', name: 'Warm Lamp',      price: 85,  theme: 'cozy', desc: 'Soft evening glow.',   emoji: '💡', slot: 'floor-right' },
    { id: 'coz_rug',      type: 'decor', name: 'Round Rug',      price: 100, theme: 'cozy', desc: 'Toes love it.',        emoji: '🟫', slot: 'rug' },
    { id: 'coz_books',    type: 'decor', name: 'Book Stack',     price: 95,  theme: 'cozy', desc: 'Bedtime stories.',     emoji: '📚', slot: 'floor-left' },
    { id: 'coz_frame',    type: 'decor', name: 'Art Frame',      price: 130, theme: 'cozy', desc: 'A little masterpiece.', pro: true, emoji: '🖼️', slot: 'shelf' }
  ];

  const SHOP_THEMES = [
    { id: 'skins',   label: 'Sprout Skins' },
    { id: 'walls',   label: 'Walls' },
    { id: 'kitchen', label: 'Kitchen' },
    { id: 'garden',  label: 'Garden' },
    { id: 'cozy',    label: 'Cozy Nook' }
  ];

  // Milestones / badges. `check` receives the full state and returns boolean.
  const MILESTONES = [
    { id: 'first_log',   label: 'First Bite',      icon: '🌱', desc: 'Logged your very first meal.',
      check: (s) => s.stats.totalFoodsLogged >= 1 },
    { id: 'week_streak', label: 'Seven Sprouts',   icon: '🔥', desc: 'Logged 7 days in a row.',
      check: (s) => s.streak.best >= 7 },
    { id: 'month_streak',label: 'Steady Gardener', icon: '🏆', desc: 'Logged 30 days in a row.',
      check: (s) => s.streak.best >= 30 },
    { id: 'hundred',     label: 'Century Snacks',  icon: '💯', desc: 'Logged 100 foods total.',
      check: (s) => s.stats.totalFoodsLogged >= 100 },
    { id: 'water_day',   label: 'Well Watered',    icon: '💧', desc: 'Hit your water goal in a day.',
      check: (s) => s.stats.waterGoalsHit >= 1 },
    { id: 'explorer',    label: 'Curious Palate',  icon: '🧭', desc: 'Tried 15 different foods.',
      check: (s) => Object.keys(s.stats.uniqueFoods || {}).length >= 15 },
    { id: 'decorator',   label: 'Home Maker',      icon: '🛋️', desc: 'Bought your first decoration.',
      check: (s) => s.owned.filter(id => (SHOP.find(x => x.id === id) || {}).type === 'decor').length >= 1 }
  ];

  // Rotating gentle encouragements shown after logging.
  const KIND_WORDS = [
    'Nice — your Sprout did a happy wiggle.',
    'Logged! Taking care of yourself counts.',
    'Your Sprout nibbled along with you. 🌱',
    'Every log is a little act of self-care.',
    'Sprout is content. So are we.',
    'That’s the habit growing stronger.',
    'Well done showing up today.'
  ];

  window.NIBBLE_DATA = {
    STARTER_FOODS,
    MEALS,
    SHOP,
    SHOP_THEMES,
    MILESTONES,
    KIND_WORDS,
    // Economy tuning
    REWARDS: {
      logMeal: 5,        // per meal logged
      waterCup: 1,       // per cup of water
      waterGoalBonus: 8, // bonus when daily water goal met
      streakDay: 3,      // small daily streak bonus
      milestone: 50      // one-time per milestone
    },
    WATER_GOAL_DEFAULT: 8 // cups
  };
})();
