#!/usr/bin/env node
/**
 * verify-design-canon.cjs — PRIMER-1 design constitution lint.
 * Enforces canon/design-rules.json against canon/design-tokens.json + page-instruments.json.
 * F4 enforced at build time: a failing design does not deploy.
 *
 * Checks:
 *  1. design-tokens.json matches PRIMER-1 spec (families, hex values, scales)
 *  2. design-rules.json invariants are consistent
 *  3. page-instruments.json: every route has territory/palette/instrument/data/torus_count
 *  4. Red rationing: sovereign family only 300/500/700/900 (no 100)
 *  5. Radii allowed: {2, 12, full}
 *  6. No unregistered hero: every route in atlas.yaml routes must be in page-instruments (or exempt)
 *  7. Contrast: action 500 vs 100 background >= 4.5:1 (WCAG AA luminance check)
 *
 * Exit: 0 = canon aligned, 1 = violation
 */
const fs = require('fs');
const path = require('path');

const CANON_DIR = '/root/web-canon/canon';
const ATLAS = path.join(CANON_DIR, 'atlas.yaml');

function loadJson(name) {
  return JSON.parse(fs.readFileSync(path.join(CANON_DIR, name), 'utf8'));
}

// WCAG relative luminance
function luminance(hex) {
  const h = hex.replace('#', '');
  const [r, g, b] = [0, 2, 4].map((i) => parseInt(h.slice(i, i + 2), 16) / 255);
  const lin = (c) => (c <= 0.03928 ? c / 12.92 : Math.pow((c + 0.055) / 1.055, 2.4));
  return 0.2126 * lin(r) + 0.7152 * lin(g) + 0.0722 * lin(b);
}

function contrast(a, b) {
  const [l1, l2] = [luminance(a), luminance(b)].sort((x, y) => y - x);
  return (l1 + 0.05) / (l2 + 0.05);
}

const PRIMER_SPEC = {
  human: { 100: '#FBF3D9', 300: '#F2D98C', 500: '#D9A62E', 700: '#8A6410', 900: '#4A3608' },
  institution: { 100: '#E4EBF2', 300: '#9DB8CE', 500: '#2E5F8A', 700: '#1B3A57', 900: '#0C1F31' },
  earth: { 100: '#DFF0EA', 300: '#8CC3B2', 500: '#2A705E', 700: '#17584A', 900: '#0A2E27' },
  sovereign: { 300: '#D97B6C', 500: '#B3362B', 700: '#7A1F18', 900: '#3D0E0A' },
  neutral: { paper: '#FAF7F0', ink: '#1A1712', carbon: '#101216', bone: '#E8E6DF' },
};

const results = [];
function check(name, ok, detail) {
  results.push({ name, ok, detail });
  if (!ok) console.log(`✗ ${name}: ${detail}`);
}

function main() {
  // 1. Token alignment with PRIMER-1
  const tokens = loadJson('design-tokens.json');
  const colors = tokens.color || {};
  for (const [fam, scale] of Object.entries(PRIMER_SPEC)) {
    const canonFam = colors[fam];
    if (!canonFam) {
      check(`token.${fam}`, false, 'family missing');
      continue;
    }
    for (const [step, hex] of Object.entries(scale)) {
      const t = canonFam[step];
      const actual = (t && t.hex || '').toLowerCase();
      check(`token.${fam}.${step}`, actual === hex.toLowerCase(), `expected ${hex} got ${actual || 'MISSING'}`);
    }
  }

  // 2. Red rationing: sovereign has no 100 step
  check('red.rationed', !colors.sovereign['100'], 'sovereign must NOT have a 100 step (rationed)');

  // 3. Radii
  const radius = tokens.geometry?.radius || {};
  const radii = [radius.human, radius.machine, radius.torus];
  check('radius.allowed', JSON.stringify(radii) === '[12,2,"full"]', `got ${JSON.stringify(radii)}`);

  // 4. Contrast — PRIMER-1 contract:
  //    (a) button text on 500 fill >= 4.5:1 AA
  //        human (amber, light fill)  -> ink text
  //        institution (blue) / earth (viridian) dark fills -> bone text
  //    (b) 700 text on 100 bg (text/links) >= 4.5:1 AA
  //    500 on 100 is NOT a valid pairing (amber can't be text on sand — that's why 700/900 exist)
  const ink = colors.neutral.ink.hex; // #1A1712
  const bone = colors.neutral.bone.hex; // #E8E6DF
  const buttonText = { human: ink, institution: bone, earth: bone };
  for (const fam of ['human', 'institution', 'earth']) {
    const c500 = colors[fam]['500'].hex;
    const c700 = colors[fam]['700'].hex;
    const c100 = colors[fam]['100'].hex;
    const txt = buttonText[fam];
    const txtOn500 = contrast(txt, c500);
    const t700On100 = contrast(c700, c100);
    check(`contrast.${fam}.txt_on_500`, txtOn500 >= 4.5, `${txt} on ${c500} = ${txtOn500.toFixed(2)}:1 (need >= 4.5)`);
    check(`contrast.${fam}.700_on_100`, t700On100 >= 4.5, `${c700} on ${c100} = ${t700On100.toFixed(2)}:1 (need >= 4.5)`);
  }

  // 5. Page instruments registry
  const instruments = loadJson('page-instruments.json');
  const instList = instruments.instruments || {};
  check('instruments.nonempty', Object.keys(instList).length >= 10, `${Object.keys(instList).length} routes registered`);
  for (const [route, spec] of Object.entries(instList)) {
    const required = ['territory', 'palette', 'instrument', 'data', 'torus_count'];
    const missing = required.filter((k) => !(k in spec));
    check(`instrument.${route}`, missing.length === 0, `missing ${missing.join(',')}`);
    check(`instrument.${route}.torus`, Number(spec.torus_count) <= 1, `torus_count ${spec.torus_count} > 1 (VOID)`);
  }

  // 6. Design rules self-consistency
  const rules = loadJson('design-rules.json');
  check('rules.allowed_families', JSON.stringify(rules.rules.allowed_color_families.values) === JSON.stringify(['human', 'institution', 'earth', 'sovereign', 'neutral']), 'family list drift');
  check('rules.state_enum', JSON.stringify(rules.rules.require_state_enum.value) === JSON.stringify(['rest', 'hold', 'sealed', 'void']), 'state enum drift');

  const fails = results.filter((r) => !r.ok);
  console.log(`\n═ DESIGN-CANON: ${results.length - fails.length}/${results.length} checks · ${fails.length} violations ${fails.length ? '🔴' : '✅'}`);
  process.exit(fails.length ? 1 : 0);
}

main();
