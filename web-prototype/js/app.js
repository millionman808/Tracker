/* =========================================================================
   Nibble — app controller. Renders screens, wires events, runs the core loop.
   Plain DOM, no framework, no build. window.Store holds all state.
   ========================================================================= */
(function () {
  'use strict';

  const D = window.NIBBLE_DATA;
  const Store = window.Store;
  const Sprout = window.Sprout;

  const screenEl = document.getElementById('screen');
  const tabbar = document.getElementById('tabbar');
  const toastEl = document.getElementById('toast');
  const modalRoot = document.getElementById('modal-root');

  let current = 'home';
  let logTab = 'recent'; // sub-tab on the Log screen

  Store.load();

  // ---- helpers ---------------------------------------------------------
  const esc = (s) => String(s).replace(/[&<>"']/g, c => (
    { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]
  ));
  const $ = (sel, root) => (root || document).querySelector(sel);
  const $$ = (sel, root) => Array.from((root || document).querySelectorAll(sel));

  function mealLabel(id) {
    const m = D.MEALS.find(x => x.id === id);
    return m ? m.label : id;
  }
  function mealIcon(id) {
    const m = D.MEALS.find(x => x.id === id);
    return m ? m.icon : '🍴';
  }
  function fmtTime(ts) {
    return new Date(ts).toLocaleTimeString([], { hour: 'numeric', minute: '2-digit' });
  }

  let toastTimer = null;
  function toast(msg, kind) {
    toastEl.textContent = msg;
    toastEl.className = 'toast toast--show' + (kind ? ' toast--' + kind : '');
    clearTimeout(toastTimer);
    toastTimer = setTimeout(() => { toastEl.className = 'toast'; }, 2600);
  }

  function celebrate(milestones) {
    if (!milestones || !milestones.length) return;
    const m = milestones[0];
    showModal(`
      <div class="celebrate">
        <div class="celebrate__icon">${m.icon}</div>
        <h2>Milestone!</h2>
        <p class="celebrate__name">${esc(m.label)}</p>
        <p class="celebrate__desc">${esc(m.desc)}</p>
        <p class="celebrate__reward">+${D.REWARDS.milestone} 💧 Dewdrops</p>
        <button class="btn btn--primary" data-close>Yay!</button>
      </div>
    `);
  }

  // ---- modal -----------------------------------------------------------
  function showModal(innerHTML) {
    modalRoot.innerHTML = `<div class="modal-backdrop" data-backdrop>
      <div class="modal" role="dialog" aria-modal="true">${innerHTML}</div>
    </div>`;
    const close = () => { modalRoot.innerHTML = ''; };
    $('[data-backdrop]', modalRoot).addEventListener('click', (e) => {
      if (e.target.matches('[data-backdrop]') || e.target.matches('[data-close]')) close();
    });
    return close;
  }

  // =====================================================================
  //  SCREENS
  // =====================================================================

  function topBar() {
    const s = Store.get();
    return `
      <header class="topbar">
        <div class="topbar__streak" title="Logging streak">
          <span class="topbar__flame">🔥</span>
          <span>${s.streak.current}</span>
        </div>
        <div class="topbar__title">Nibble</div>
        <div class="topbar__drops" title="Dewdrops">
          <span>💧</span><span>${s.dewdrops}</span>
        </div>
      </header>`;
  }

  // ---- HOME ------------------------------------------------------------
  function renderHome() {
    const s = Store.get();
    const total = Store.totalForDay();
    const mood = Store.currentMood();
    const wall = s.activeWall ? (D.SHOP.find(x => x.id === s.activeWall) || {}).color : null;

    // progress: watering-can fill toward goal (or a neutral "grown" state if goal-free)
    let progressBlock;
    if (s.goal) {
      const pct = Math.min(100, Math.round((total / s.goal) * 100));
      const over = total > s.goal;
      progressBlock = `
        <div class="goalcard">
          <div class="goalcard__row">
            <span class="goalcard__total">${total}</span>
            <span class="goalcard__of">of ${s.goal} kcal</span>
          </div>
          <div class="watercan" aria-label="Progress toward goal">
            <div class="watercan__fill" style="height:${pct}%"></div>
          </div>
          <p class="goalcard__note">${over
            ? 'You’ve passed your goal — and that’s completely okay. 🌿'
            : 'Filling up nicely. No pressure, just logging.'}</p>
        </div>`;
    } else {
      progressBlock = `
        <div class="goalcard goalcard--free">
          <div class="goalcard__row">
            <span class="goalcard__total">${total}</span>
            <span class="goalcard__of">kcal today</span>
          </div>
          <p class="goalcard__note">Goal-free mode. You’re tracking for awareness, not limits. 🌱</p>
        </div>`;
    }

    // decorations placed in the room by slot
    const decorBySlot = {};
    s.owned.forEach(id => {
      const item = D.SHOP.find(x => x.id === id);
      if (item && item.type === 'decor') decorBySlot[item.slot] = item;
    });
    const slot = (name) => decorBySlot[name]
      ? `<span class="room__decor room__decor--${name}" title="${esc(decorBySlot[name].name)}">${decorBySlot[name].emoji}</span>`
      : '';

    screenEl.innerHTML = `
      ${topBar()}
      <div class="home">
        <div class="room" style="${wall ? `--wall:${wall}` : ''}">
          ${slot('shelf')}
          ${slot('floor-left')}
          ${slot('floor-right')}
          ${slot('rug')}
          <div class="room__sprout" id="sprout-host">
            ${Sprout.render({ skin: s.activeSkin, mood, size: 170 })}
          </div>
          <div class="room__nameplate">${esc(s.sproutName)} · <span class="room__mood">${moodWord(mood)}</span></div>
        </div>

        ${progressBlock}

        <button class="btn btn--primary btn--big" id="home-quickadd">＋ Log food</button>

        <div class="home__water">
          <div class="home__water-label">💧 Water · ${Store.dayRecord().water}/${s.water.goal} cups</div>
          <button class="btn btn--ghost btn--sm" id="home-water">Add a cup</button>
        </div>
      </div>`;

    $('#home-quickadd').addEventListener('click', () => go('log'));
    $('#home-water').addEventListener('click', () => {
      const r = Store.addWater(1);
      pulseSprout();
      toast(`Sip! +${r.earned} 💧`);
      celebrate(r.newMilestones);
      renderHome();
    });
  }

  function moodWord(m) {
    return { happy: 'happy', neutral: 'content', sleepy: 'sleepy', eating: 'nibbling', celebrating: 'thrilled' }[m] || m;
  }

  function pulseSprout(mood) {
    const host = $('#sprout-host');
    if (!host) return;
    const s = Store.get();
    host.innerHTML = Sprout.render({ skin: s.activeSkin, mood: mood || 'eating', size: 170 });
    host.classList.add('sprout-pop');
    setTimeout(() => {
      host.classList.remove('sprout-pop');
      host.innerHTML = Sprout.render({ skin: s.activeSkin, mood: Store.currentMood(), size: 170 });
    }, 1100);
  }

  // ---- LOG / ADD FOOD --------------------------------------------------
  function renderLog() {
    const s = Store.get();
    const list = logTab === 'favorites' ? s.favorites : s.recent;

    const listHTML = list.length ? list.map(f => `
      <li class="foodrow" data-food='${esc(JSON.stringify(f))}'>
        <button class="foodrow__main" data-quick>
          <span class="foodrow__icon">${mealIcon(f.meal)}</span>
          <span class="foodrow__text">
            <span class="foodrow__name">${esc(f.name)}</span>
            <span class="foodrow__cal">${f.cal} kcal${s.settings.showMacros ? ` · ${f.p|0}p ${f.c|0}c ${f.f|0}f` : ''}</span>
          </span>
        </button>
        <button class="foodrow__fav ${Store.isFavorite(f.name) ? 'is-fav' : ''}" data-fav aria-label="Toggle favorite">★</button>
      </li>`).join('')
      : `<li class="empty">${logTab === 'favorites' ? 'No favorites yet — tap ★ on any food.' : 'Nothing logged yet. Add something below!'}</li>`;

    screenEl.innerHTML = `
      ${topBar()}
      <div class="log">
        <h1 class="screen__title">Log food</h1>

        <form id="add-form" class="addform">
          <div class="addform__rowtop">
            <input class="input addform__name" id="f-name" type="text" placeholder="Food name" autocomplete="off" required />
            <input class="input addform__cal" id="f-cal" type="number" inputmode="numeric" placeholder="kcal" min="0" required />
          </div>

          <div class="mealpick" role="group" aria-label="Meal category">
            ${D.MEALS.map((m, i) => `
              <label class="mealpick__opt">
                <input type="radio" name="meal" value="${m.id}" ${i === defaultMealIndex() ? 'checked' : ''}/>
                <span>${m.icon} ${m.label}</span>
              </label>`).join('')}
          </div>

          <div class="addform__serv">
            <label>Servings
              <input class="input input--serv" id="f-serv" type="number" inputmode="decimal" value="1" min="0.25" step="0.25"/>
            </label>
          </div>

          ${s.settings.showMacros ? `
          <div class="macros">
            <label>Protein<input class="input input--macro" id="f-p" type="number" min="0" placeholder="g"/></label>
            <label>Carbs<input class="input input--macro" id="f-c" type="number" min="0" placeholder="g"/></label>
            <label>Fat<input class="input input--macro" id="f-f" type="number" min="0" placeholder="g"/></label>
          </div>` : ''}

          <button class="btn btn--primary btn--big" type="submit">Log it 🌱</button>
        </form>

        <div class="subtabs">
          <button class="subtab ${logTab === 'recent' ? 'is-active' : ''}" data-subtab="recent">Recent</button>
          <button class="subtab ${logTab === 'favorites' ? 'is-active' : ''}" data-subtab="favorites">Favorites ★</button>
        </div>
        <ul class="foodlist">${listHTML}</ul>
      </div>`;

    $('#add-form').addEventListener('submit', onAddSubmit);
    $$('.subtab').forEach(b => b.addEventListener('click', () => {
      logTab = b.dataset.subtab; renderLog();
    }));
    $$('.foodrow').forEach(row => {
      const food = JSON.parse(row.dataset.food);
      $('[data-quick]', row).addEventListener('click', () => quickLog(food));
      $('[data-fav]', row).addEventListener('click', () => {
        Store.toggleFavorite(food); renderLog();
      });
    });
  }

  function defaultMealIndex() {
    const h = new Date().getHours();
    if (h < 11) return 0;       // breakfast
    if (h < 15) return 1;       // lunch
    if (h < 21) return 2;       // dinner
    return 3;                   // snack
  }

  function onAddSubmit(e) {
    e.preventDefault();
    const name = $('#f-name').value.trim();
    const calRaw = parseFloat($('#f-cal').value);
    const serv = parseFloat($('#f-serv').value) || 1;
    if (!name || isNaN(calRaw)) { toast('Add a name and calories 🙂'); return; }
    const mealEl = $('input[name="meal"]:checked');
    const food = {
      name,
      cal: calRaw * serv,
      meal: mealEl ? mealEl.value : 'snack',
      p: (parseFloat($('#f-p') ? $('#f-p').value : 0) || 0) * serv,
      c: (parseFloat($('#f-c') ? $('#f-c').value : 0) || 0) * serv,
      f: (parseFloat($('#f-f') ? $('#f-f').value : 0) || 0) * serv
    };
    doLog(food);
    e.target.reset();
    $('#f-serv').value = 1;
  }

  function quickLog(food) {
    doLog({ ...food });
  }

  function doLog(food) {
    const res = Store.addEntry(food);
    const kind = D.KIND_WORDS[Math.floor(Math.random() * D.KIND_WORDS.length)];
    toast(`${kind} +${res.earned} 💧`);
    celebrate(res.newMilestones);
    // bounce to home so the user sees the Sprout react
    go('home');
    pulseSprout('happy');
  }

  // ---- TODAY -----------------------------------------------------------
  function renderToday() {
    const s = Store.get();
    const rec = Store.dayRecord();
    const total = Store.totalForDay();
    const macros = Store.macrosForDay();

    // group entries by meal
    const groups = {};
    D.MEALS.forEach(m => groups[m.id] = []);
    rec.entries.slice().sort((a, b) => a.at - b.at).forEach(e => {
      (groups[e.meal] || (groups[e.meal] = [])).push(e);
    });

    const groupsHTML = D.MEALS.map(m => {
      const items = groups[m.id] || [];
      if (!items.length) return '';
      const sub = items.reduce((t, e) => t + e.cal, 0);
      return `
        <section class="mealgroup">
          <h3 class="mealgroup__head">${m.icon} ${m.label} <span class="mealgroup__sub">${sub} kcal</span></h3>
          <ul>
            ${items.map(e => `
              <li class="entry" data-id="${e.id}">
                <span class="entry__time">${fmtTime(e.at)}</span>
                <span class="entry__name">${esc(e.name)}</span>
                <span class="entry__cal">${e.cal}</span>
                <button class="entry__del" data-del aria-label="Delete">✕</button>
              </li>`).join('')}
          </ul>
        </section>`;
    }).join('');

    const waterCups = Array.from({ length: s.water.goal }).map((_, i) =>
      `<button class="cup ${i < rec.water ? 'cup--full' : ''}" data-cup="${i}" aria-label="Cup ${i + 1}">${i < rec.water ? '💧' : '○'}</button>`
    ).join('');
    const extraWater = rec.water > s.water.goal ? ` <span class="water__extra">+${rec.water - s.water.goal} extra 🌟</span>` : '';

    screenEl.innerHTML = `
      ${topBar()}
      <div class="today">
        <h1 class="screen__title">Today</h1>
        <div class="today__summary">
          <div class="today__total"><strong>${total}</strong> kcal${s.goal ? ` <span class="today__goal">/ ${s.goal}</span>` : ''}</div>
          ${s.settings.showMacros ? `<div class="today__macros">${Math.round(macros.p)}g P · ${Math.round(macros.c)}g C · ${Math.round(macros.f)}g F</div>` : ''}
        </div>

        ${groupsHTML || '<p class="empty">No entries yet today. Tap ＋ to log your first meal.</p>'}

        <section class="watercard">
          <h3 class="watercard__head">💧 Water <span class="watercard__count">${rec.water}/${s.water.goal} cups${extraWater}</span></h3>
          <div class="cups">${waterCups}</div>
          <button class="btn btn--ghost btn--sm" id="water-plus">＋ Add a cup</button>
        </section>
      </div>`;

    $$('.entry').forEach(row => {
      $('[data-del]', row).addEventListener('click', () => {
        Store.removeEntry(row.dataset.id);
        renderToday();
        toast('Entry removed.');
      });
    });
    // tapping a cup sets the water level to that cup (fill or unfill)
    $$('.cup').forEach(c => c.addEventListener('click', () => {
      const idx = parseInt(c.dataset.cup, 10);
      const target = idx + 1;
      const delta = target > rec.water ? (target - rec.water) : -(rec.water - target);
      const r = Store.addWater(delta);
      if (r.earned > 0) toast(`+${r.earned} 💧`);
      celebrate(r.newMilestones);
      renderToday();
    }));
    $('#water-plus').addEventListener('click', () => {
      const r = Store.addWater(1);
      if (r.earned > 0) toast(`Sip! +${r.earned} 💧`);
      celebrate(r.newMilestones);
      renderToday();
    });
  }

  // ---- SHOP ------------------------------------------------------------
  let shopTheme = 'skins';
  function renderShop() {
    const s = Store.get();
    const items = D.SHOP.filter(x => x.theme === shopTheme);

    const cards = items.map(item => {
      const owned = Store.owns(item.id);
      const equipped = (item.type === 'skin' && s.activeSkin === item.id) ||
                       (item.type === 'wallpaper' && s.activeWall === item.id);
      const locked = item.pro && !s.pro;
      let action;
      if (equipped) action = `<span class="shopcard__equipped">Equipped ✓</span>`;
      else if (owned && (item.type === 'skin' || item.type === 'wallpaper'))
        action = `<button class="btn btn--sm btn--primary" data-equip="${item.id}">Equip</button>`;
      else if (owned) action = `<span class="shopcard__owned">Owned ✓</span>`;
      else if (locked) action = `<button class="btn btn--sm btn--pro" data-pro>🔒 Pro</button>`;
      else action = `<button class="btn btn--sm ${s.dewdrops >= item.price ? 'btn--primary' : 'btn--disabled'}" data-buy="${item.id}">💧 ${item.price}</button>`;

      const preview = item.type === 'wallpaper'
        ? `<span class="shopcard__swatch" style="background:${item.color}"></span>`
        : `<span class="shopcard__emoji">${item.type === 'skin' ? Sprout.skinEmoji(item.id) : item.emoji}</span>`;

      return `
        <div class="shopcard ${equipped ? 'is-equipped' : ''}">
          <div class="shopcard__preview" ${item.type === 'skin' ? `data-preview="${item.id}"` : ''}>${preview}</div>
          <div class="shopcard__name">${esc(item.name)}${item.pro ? ' <span class="tag-pro">PRO</span>' : ''}</div>
          <div class="shopcard__desc">${esc(item.desc)}</div>
          <div class="shopcard__action">${action}</div>
        </div>`;
    }).join('');

    screenEl.innerHTML = `
      ${topBar()}
      <div class="shop">
        <h1 class="screen__title">Shop & Decorate</h1>
        <div class="subtabs subtabs--scroll">
          ${D.SHOP_THEMES.map(t => `<button class="subtab ${t.id === shopTheme ? 'is-active' : ''}" data-theme="${t.id}">${esc(t.label)}</button>`).join('')}
        </div>
        <div class="shopgrid">${cards}</div>
        ${!s.pro ? `<button class="btn btn--pro btn--big" id="get-pro">✨ Unlock Pro (demo)</button>` : `<p class="pro-active">✨ Pro is active — enjoy your perks!</p>`}
      </div>`;

    $$('.subtab[data-theme]').forEach(b => b.addEventListener('click', () => { shopTheme = b.dataset.theme; renderShop(); }));
    $$('[data-buy]').forEach(b => b.addEventListener('click', () => {
      const r = Store.buy(b.dataset.buy);
      if (!r.ok) {
        if (r.reason === 'funds') toast('Not enough Dewdrops yet — keep logging! 💧');
        else if (r.reason === 'pro') toast('That’s a Pro item ✨');
        return;
      }
      toast(`Got it: ${r.item.name}!`);
      celebrate(r.newMilestones);
      renderShop();
    }));
    $$('[data-equip]').forEach(b => b.addEventListener('click', () => {
      const id = b.dataset.equip;
      const item = D.SHOP.find(x => x.id === id);
      if (item.type === 'skin') Store.equipSkin(id);
      else Store.equipWall(id);
      toast('Equipped!');
      renderShop();
    }));
    $$('[data-preview]').forEach(p => p.addEventListener('click', () => previewSkin(p.dataset.preview)));
    const proBtn = $('#get-pro');
    if (proBtn) proBtn.addEventListener('click', () => {
      Store.setPro(true);
      toast('✨ Pro unlocked (demo mode)');
      renderShop();
    });
  }

  function previewSkin(skinId) {
    const owned = Store.owns(skinId);
    const item = D.SHOP.find(x => x.id === skinId);
    showModal(`
      <div class="preview">
        <h2>Preview · ${esc(item.name)}</h2>
        <div class="preview__stage">${Sprout.render({ skin: skinId, mood: 'happy', size: 160 })}</div>
        <p class="preview__desc">${esc(item.desc)}</p>
        <div class="preview__actions">
          ${owned
            ? `<button class="btn btn--primary" data-equip-now="${skinId}">Equip</button>`
            : (item.pro && !Store.get().pro
                ? `<button class="btn btn--pro" data-close>🔒 Pro item</button>`
                : `<button class="btn btn--primary" data-buy-now="${skinId}">Buy · 💧 ${item.price}</button>`)}
          <button class="btn btn--ghost" data-close>Close</button>
        </div>
      </div>`);
    const eq = $('[data-equip-now]', modalRoot);
    if (eq) eq.addEventListener('click', () => { Store.equipSkin(skinId); modalRoot.innerHTML = ''; toast('Equipped!'); renderShop(); });
    const by = $('[data-buy-now]', modalRoot);
    if (by) by.addEventListener('click', () => {
      const r = Store.buy(skinId);
      modalRoot.innerHTML = '';
      if (!r.ok) { toast(r.reason === 'funds' ? 'Not enough Dewdrops yet 💧' : 'Can’t buy that right now'); return; }
      Store.equipSkin(skinId);
      toast(`Got ${r.item.name}!`);
      celebrate(r.newMilestones);
      renderShop();
    });
  }

  // ---- STATS -----------------------------------------------------------
  function renderStats() {
    const s = Store.get();
    // last 7 days of totals
    const days = [];
    for (let i = 6; i >= 0; i--) {
      const d = new Date();
      d.setDate(d.getDate() - i);
      const key = Store.todayKey(d);
      days.push({ key, label: d.toLocaleDateString([], { weekday: 'short' }), total: Store.totalForDay(key),
                  logged: (s.days[key] || { entries: [] }).entries.length > 0 });
    }
    const maxTotal = Math.max(1, ...days.map(d => d.total));
    const avg = Math.round(days.reduce((t, d) => t + d.total, 0) / 7);

    const bars = days.map(d => {
      const h = Math.round((d.total / maxTotal) * 100);
      return `<div class="bar">
        <div class="bar__col"><div class="bar__fill ${d.logged ? '' : 'bar__fill--empty'}" style="height:${d.total ? Math.max(6, h) : 2}%"></div></div>
        <div class="bar__label">${d.label[0]}</div>
      </div>`;
    }).join('');

    const badges = D.MILESTONES.map(m => {
      const earned = s.earnedMilestones.includes(m.id);
      return `<div class="badge ${earned ? 'badge--earned' : 'badge--locked'}" title="${esc(m.desc)}">
        <span class="badge__icon">${earned ? m.icon : '🔒'}</span>
        <span class="badge__label">${esc(m.label)}</span>
      </div>`;
    }).join('');

    screenEl.innerHTML = `
      ${topBar()}
      <div class="stats">
        <h1 class="screen__title">Progress</h1>

        <div class="stat-hero">
          <div class="stat-hero__big">${s.streak.current}<span>🔥</span></div>
          <div class="stat-hero__cap">day logging streak</div>
          <div class="stat-hero__sub">Best: ${s.streak.best} · Streak freezes left: ${s.streak.freezes}</div>
        </div>

        <section class="card">
          <h3 class="card__head">Last 7 days <span class="card__hint">avg ${avg} kcal</span></h3>
          <div class="chart">${bars}</div>
          <p class="card__foot">We celebrate the habit, not a number on a scale. 🌿</p>
        </section>

        <section class="card">
          <h3 class="card__head">Lifetime</h3>
          <div class="statgrid">
            <div><strong>${s.stats.totalFoodsLogged}</strong><span>foods logged</span></div>
            <div><strong>${Object.keys(s.stats.uniqueFoods || {}).length}</strong><span>unique foods</span></div>
            <div><strong>${s.stats.waterGoalsHit}</strong><span>water goals hit</span></div>
            <div><strong>${s.owned.length}</strong><span>things owned</span></div>
          </div>
        </section>

        <section class="card">
          <h3 class="card__head">Badges</h3>
          <div class="badges">${badges}</div>
        </section>

        <button class="btn btn--ghost btn--big" id="open-settings">⚙️ Settings</button>
      </div>`;

    $('#open-settings').addEventListener('click', renderSettings);
  }

  // ---- SETTINGS --------------------------------------------------------
  function renderSettings() {
    const s = Store.get();
    screenEl.innerHTML = `
      ${topBar()}
      <div class="settings">
        <h1 class="screen__title">Settings</h1>

        <section class="card">
          <h3 class="card__head">Your Sprout</h3>
          <label class="field">Name
            <input class="input" id="set-name" type="text" maxlength="16" value="${esc(s.sproutName)}"/>
          </label>
        </section>

        <section class="card">
          <h3 class="card__head">Daily goal</h3>
          <label class="field">Calorie goal (leave blank for goal-free mode)
            <input class="input" id="set-goal" type="number" inputmode="numeric" min="0" placeholder="e.g. 2000" value="${s.goal ?? ''}"/>
          </label>
          <p class="field-note">Going over your goal never upsets your Sprout. Logging is the win. 🌱</p>
          <label class="field">Daily water goal (cups)
            <input class="input" id="set-water" type="number" inputmode="numeric" min="1" value="${s.water.goal}"/>
          </label>
        </section>

        <section class="card">
          <h3 class="card__head">Preferences</h3>
          <label class="toggle">
            <input type="checkbox" id="set-macros" ${s.settings.showMacros ? 'checked' : ''}/>
            <span>Track macros (protein / carbs / fat)</span>
          </label>
          <label class="toggle">
            <input type="checkbox" id="set-rem" ${s.settings.remindersOn ? 'checked' : ''}/>
            <span>Meal reminders <span class="muted">(demo — shows a sample)</span></span>
          </label>
        </section>

        <section class="card">
          <h3 class="card__head">Backup & transfer</h3>
          <div class="btnrow">
            <button class="btn btn--ghost btn--sm" id="set-export">Export save</button>
            <button class="btn btn--ghost btn--sm" id="set-import">Import save</button>
          </div>
          <p class="field-note">Your data is stored only on this device, in your browser. Nothing is uploaded.</p>
        </section>

        <section class="card card--danger">
          <h3 class="card__head">Reset</h3>
          <button class="btn btn--danger btn--sm" id="set-reset">Erase all progress</button>
        </section>

        <p class="about">Nibble — Sprout Snacks · supportive calorie logging. A working concept, no accounts, no ads, no shame.</p>
        <button class="btn btn--ghost btn--big" id="back-stats">← Back</button>
      </div>`;

    $('#set-name').addEventListener('change', e => { Store.setName(e.target.value); toast('Saved'); });
    $('#set-goal').addEventListener('change', e => { Store.setGoal(e.target.value); toast(e.target.value ? 'Goal set' : 'Goal-free mode on 🌿'); });
    $('#set-water').addEventListener('change', e => { Store.setWaterGoal(e.target.value); toast('Saved'); });
    $('#set-macros').addEventListener('change', e => { Store.setSetting('showMacros', e.target.checked); toast(e.target.checked ? 'Macros on' : 'Macros off'); });
    $('#set-rem').addEventListener('change', e => {
      Store.setSetting('remindersOn', e.target.checked);
      if (e.target.checked) toast('🔔 “Time to log lunch?” (sample reminder)');
    });
    $('#set-export').addEventListener('click', () => {
      const data = Store.exportSave();
      showModal(`<div class="io"><h2>Export save</h2><p>Copy this and keep it safe:</p>
        <textarea class="io__area" readonly>${esc(data)}</textarea>
        <button class="btn btn--primary" id="io-copy">Copy</button>
        <button class="btn btn--ghost" data-close>Close</button></div>`);
      $('#io-copy', modalRoot).addEventListener('click', () => {
        const ta = $('.io__area', modalRoot); ta.select();
        try { navigator.clipboard.writeText(data); } catch (e) { document.execCommand('copy'); }
        toast('Copied to clipboard');
      });
    });
    $('#set-import').addEventListener('click', () => {
      showModal(`<div class="io"><h2>Import save</h2><p>Paste a previously exported save:</p>
        <textarea class="io__area" id="io-in" placeholder="Paste JSON here"></textarea>
        <button class="btn btn--primary" id="io-load">Load</button>
        <button class="btn btn--ghost" data-close>Cancel</button></div>`);
      $('#io-load', modalRoot).addEventListener('click', () => {
        try {
          Store.importSave($('#io-in', modalRoot).value);
          modalRoot.innerHTML = '';
          toast('Save imported!');
          go('home');
        } catch (e) { toast('That didn’t look like a valid save.'); }
      });
    });
    $('#set-reset').addEventListener('click', () => {
      showModal(`<div class="confirm"><h2>Erase everything?</h2>
        <p>This permanently clears your Sprout, streak, Dewdrops and decorations on this device.</p>
        <button class="btn btn--danger" id="confirm-reset">Yes, erase</button>
        <button class="btn btn--ghost" data-close>Cancel</button></div>`);
      $('#confirm-reset', modalRoot).addEventListener('click', () => {
        Store.resetAll();
        modalRoot.innerHTML = '';
        toast('Fresh start. 🌱');
        go('home');
      });
    });
    $('#back-stats').addEventListener('click', () => go('stats'));
  }

  // =====================================================================
  //  ROUTER
  // =====================================================================
  const SCREENS = {
    home: renderHome,
    log: renderLog,
    today: renderToday,
    shop: renderShop,
    stats: renderStats,
    settings: renderSettings
  };

  function go(name) {
    current = name;
    (SCREENS[name] || renderHome)();
    screenEl.scrollTop = 0;
    // sync tab highlight (settings maps to stats tab)
    const tabName = name === 'settings' ? 'stats' : name;
    $$('.tab', tabbar).forEach(t => t.classList.toggle('is-active', t.dataset.screen === tabName));
  }

  tabbar.addEventListener('click', (e) => {
    const tab = e.target.closest('.tab');
    if (tab) go(tab.dataset.screen);
  });

  // keyboard: Escape closes modal
  document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape' && modalRoot.innerHTML) modalRoot.innerHTML = '';
  });

  // First paint
  go('home');

  // Re-derive mood if the app is left open across the sleepy/awake boundary.
  setInterval(() => {
    if (current === 'home') {
      const host = $('#sprout-host');
      if (host && !host.classList.contains('sprout-pop')) {
        const s = Store.get();
        host.innerHTML = Sprout.render({ skin: s.activeSkin, mood: Store.currentMood(), size: 170 });
      }
    }
  }, 60000);

  // expose for debugging
  window.Nibble = { go, Store };
})();
