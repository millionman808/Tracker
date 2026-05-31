/* =========================================================================
   Nibble — the Sprout companion, drawn as inline SVG so it animates with CSS.
   Moods: idle/neutral, happy, eating, sleepy, celebrating.
   Skins recolor the body and add a small topper. The Sprout is NEVER sad —
   by design there is no distress state tied to eating.
   ========================================================================= */
(function () {
  'use strict';

  // Palette per skin id.
  const SKINS = {
    skin_sprout:    { body: '#7bc47f', cheek: '#f4a6b8', topper: 'leaf' },
    skin_cactus:    { body: '#5fa86a', cheek: '#f0b3a0', topper: 'flower' },
    skin_mushroom:  { body: '#e8d9c5', cheek: '#f4a6b8', topper: 'cap' },
    skin_sunflower: { body: '#f4c542', cheek: '#e89b6c', topper: 'petals' },
    skin_cherry:    { body: '#e06377', cheek: '#ffd1dc', topper: 'stem' }
  };

  function topperMarkup(kind) {
    switch (kind) {
      case 'leaf':
        return '<path class="sprout-topper" d="M50 18 C50 6 62 4 64 12 C66 20 56 22 50 18 Z" fill="#4f9d57"/>' +
               '<path d="M50 18 C50 8 40 6 37 13 C34 21 44 23 50 18 Z" fill="#5fb368"/>';
      case 'flower':
        return '<g class="sprout-topper">' +
               '<circle cx="50" cy="12" r="4" fill="#f7c9d6"/><circle cx="44" cy="15" r="4" fill="#f7c9d6"/>' +
               '<circle cx="56" cy="15" r="4" fill="#f7c9d6"/><circle cx="50" cy="14" r="3" fill="#ffe08a"/></g>';
      case 'cap':
        return '<path class="sprout-topper" d="M28 30 Q50 4 72 30 Z" fill="#c0594f"/>' +
               '<circle cx="42" cy="24" r="2.4" fill="#fff"/><circle cx="58" cy="25" r="2" fill="#fff"/><circle cx="50" cy="18" r="2.2" fill="#fff"/>';
      case 'petals':
        return '<g class="sprout-topper">' +
               Array.from({ length: 8 }).map((_, i) => {
                 const a = (i / 8) * Math.PI * 2;
                 const x = 50 + Math.cos(a) * 13, y = 18 + Math.sin(a) * 13;
                 return `<ellipse cx="${x.toFixed(1)}" cy="${y.toFixed(1)}" rx="5" ry="3" fill="#f4c542" transform="rotate(${(a * 180 / Math.PI).toFixed(0)} ${x.toFixed(1)} ${y.toFixed(1)})"/>`;
               }).join('') +
               '<circle cx="50" cy="18" r="7" fill="#7a4a25"/></g>';
      case 'stem':
        return '<path class="sprout-topper" d="M50 20 C52 10 60 8 58 4" stroke="#4f9d57" stroke-width="3" fill="none" stroke-linecap="round"/>' +
               '<path d="M58 8 C64 6 66 12 60 13 Z" fill="#5fb368"/>';
      default:
        return '';
    }
  }

  /**
   * Render the Sprout SVG.
   * @param {Object} opts { skin, mood, size }
   * @returns {string} svg markup
   */
  function render(opts) {
    const o = opts || {};
    const skin = SKINS[o.skin] || SKINS.skin_sprout;
    const mood = o.mood || 'neutral';
    const size = o.size || 180;

    // Eyes & mouth per mood.
    let eyes, mouth, extra = '';
    switch (mood) {
      case 'sleepy':
        eyes = '<path d="M38 56 q5 4 10 0" stroke="#3a3a3a" stroke-width="2.5" fill="none" stroke-linecap="round"/>' +
               '<path d="M52 56 q5 4 10 0" stroke="#3a3a3a" stroke-width="2.5" fill="none" stroke-linecap="round"/>';
        mouth = '<circle cx="50" cy="68" r="3" fill="#3a3a3a"/>';
        extra = '<text x="70" y="40" class="sprout-zzz" font-size="12" fill="#9aa">z</text>' +
                '<text x="76" y="30" class="sprout-zzz sprout-zzz--2" font-size="16" fill="#9aa">z</text>';
        break;
      case 'happy':
        eyes = '<path d="M37 54 q5 -5 10 0" stroke="#3a3a3a" stroke-width="3" fill="none" stroke-linecap="round"/>' +
               '<path d="M53 54 q5 -5 10 0" stroke="#3a3a3a" stroke-width="3" fill="none" stroke-linecap="round"/>';
        mouth = '<path d="M42 64 q8 9 16 0" stroke="#3a3a3a" stroke-width="2.5" fill="#fff" stroke-linecap="round"/>';
        break;
      case 'eating':
        eyes = '<circle cx="42" cy="54" r="3.2" fill="#3a3a3a"/><circle cx="58" cy="54" r="3.2" fill="#3a3a3a"/>';
        mouth = '<ellipse cx="50" cy="66" rx="6" ry="5" fill="#7a3b3b"/>';
        extra = '<text x="62" y="60" class="sprout-nom" font-size="14">🍃</text>';
        break;
      case 'celebrating':
        eyes = '<path d="M37 54 q5 -6 10 0" stroke="#3a3a3a" stroke-width="3" fill="none" stroke-linecap="round"/>' +
               '<path d="M53 54 q5 -6 10 0" stroke="#3a3a3a" stroke-width="3" fill="none" stroke-linecap="round"/>';
        mouth = '<path d="M41 62 q9 12 18 0 z" fill="#7a3b3b"/>';
        extra = '<text x="20" y="34" class="sprout-spark s1">✨</text>' +
                '<text x="72" y="40" class="sprout-spark s2">✨</text>' +
                '<text x="50" y="22" class="sprout-spark s3">⭐</text>';
        break;
      default: // neutral
        eyes = '<circle cx="42" cy="54" r="3.4" fill="#3a3a3a"/><circle cx="58" cy="54" r="3.4" fill="#3a3a3a"/>';
        mouth = '<path d="M44 65 q6 4 12 0" stroke="#3a3a3a" stroke-width="2.5" fill="none" stroke-linecap="round"/>';
    }

    return `
      <svg class="sprout sprout--${mood}" viewBox="0 0 100 110" width="${size}" height="${size * 1.1}"
           role="img" aria-label="Sprout companion, ${mood}">
        <ellipse class="sprout-shadow" cx="50" cy="102" rx="26" ry="6" fill="rgba(0,0,0,.12)"/>
        ${topperMarkup(skin.topper)}
        <g class="sprout-body-group">
          <path class="sprout-body" d="M50 28
            C72 28 80 46 80 64
            C80 86 66 98 50 98
            C34 98 20 86 20 64
            C20 46 28 28 50 28 Z" fill="${skin.body}"/>
          <ellipse cx="50" cy="60" rx="26" ry="27" fill="rgba(255,255,255,.14)"/>
          <circle cx="34" cy="62" r="5" fill="${skin.cheek}" opacity=".8"/>
          <circle cx="66" cy="62" r="5" fill="${skin.cheek}" opacity=".8"/>
          ${eyes}
          ${mouth}
          <path class="sprout-arm sprout-arm--l" d="M22 70 q-8 4 -10 12" stroke="${skin.body}" stroke-width="6" fill="none" stroke-linecap="round"/>
          <path class="sprout-arm sprout-arm--r" d="M78 70 q8 4 10 12" stroke="${skin.body}" stroke-width="6" fill="none" stroke-linecap="round"/>
        </g>
        ${extra}
      </svg>`;
  }

  function skinEmoji(skinId) {
    const map = { skin_sprout: '🌱', skin_cactus: '🌵', skin_mushroom: '🍄', skin_sunflower: '🌻', skin_cherry: '🍒' };
    return map[skinId] || '🌱';
  }

  window.Sprout = { render, skinEmoji, SKINS };
})();
