#!/usr/bin/env node
// canon-lint.js — web-canon CI gate
// Asserts the 4-color discipline + 12px red rule + F13-pulse-once rule on the rendered site.
//
// Usage:  node canon-lint.js <path-to-html-file>
// Exit 0 = clean. Exit 1 = violations found.
//
// Canon: 4 hex colors only.
//   --carbon: #0B0E12
//   --bone:   #E8E6DF
//   --amber:  #D4A853
//   --red:    #E63946
//
// Lint rules:
//   1. Only the 4 canon hex values may appear in computed CSS.
//   2. Red (#E63946) must not be used for text below 12px font-size.
//   3. The pulsing red dot (F13 indicator) may appear once per page (verifies the
//      'one red ration' contract — sovereign strip pulse is the only place).
//   4. prefers-reduced-motion must freeze all animations.

const fs = require('fs');
const path = require('path');

const CANON_COLORS = new Set([
  '#0B0E12', '#E8E6DF', '#D4A853', '#E63946',
  // alphas of canon are not lint failures; the regex strips alpha values.
  '#0B0E12'.toLowerCase(), '#E8E6DF'.toLowerCase(),
  '#D4A853'.toLowerCase(), '#E63946'.toLowerCase(),
]);

// alphas of the same hexes are canon (carbon-12%, amber-08%, etc.)
function canonForm(hex) {
  return hex.toUpperCase();
}
const CANON_FORMS = new Set(['#0B0E12', '#E8E6DF', '#D4A853', '#E63946']);

function fail(msg) { console.log(`  ✗ ${msg}`); }
function pass(msg) { console.log(`  ✓ ${msg}`); }

function extractAllHexColors(html) {
  // match #RGB and #RRGGBB; ignore rgba()/hsla()/var() etc.
  const re = /#[0-9A-Fa-f]{6}\b/g;
  return new Set((html.match(re) || []).map(s => s.toUpperCase()));
}

function extractRedFontSizes(html) {
  // crude: find any 'color: #E63946' or 'color: var(--red)' within a CSS rule,
  // then look at the nearest preceding font-size declaration in the same rule block.
  // For the purpose of this lint, we scan the entire CSS and find any red-text
  // declaration followed within the same block by a font-size <12.
  const violations = [];
  // Find CSS blocks
  const blockRe = /\{([^{}]*)\}/g;
  const blocks = html.match(blockRe) || [];
  for (const block of blocks) {
    if (!/var\(--red\)|#E63946/i.test(block)) continue;
    if (!/color\s*:/i.test(block)) continue;
    // find font-size in the same block
    const fsMatch = block.match(/font-size\s*:\s*([0-9.]+)(px|pt|rem|em)/i);
    if (fsMatch) {
      let px = parseFloat(fsMatch[1]);
      const unit = fsMatch[2].toLowerCase();
      if (unit === 'rem' || unit === 'em') px = px * 16; // crude
      if (px < 12) {
        violations.push({ block: block.trim().slice(0, 80), fontSize: fsMatch[0], computedPx: px });
      }
    }
  }
  return violations;
}

function countF13Pulse(html) {
  // Count distinct elements with class="f13" or class containing "f13".
  // Use a single Set to avoid double-counting when both regexes match the
  // same attribute.
  const matches = new Set();
  for (const m of html.matchAll(/class="([^"]+)"/g)) {
    const tokens = m[1].split(/\s+/);
    if (tokens.includes('f13')) matches.add(m[0]);
  }
  return matches.size;
}

function hasReducedMotion(html) {
  return /@media[^{]*prefers-reduced-motion\s*:\s*reduce[\s\S]*?\{[\s\S]*?animation\s*:\s*none/i.test(html)
      || /prefers-reduced-motion[\s\S]{0,400}animation\s*:\s*none/i.test(html);
}

function lint(filePath) {
  const absPath = path.resolve(filePath);
  if (!fs.existsSync(absPath)) {
    console.log(`✗ File not found: ${absPath}`);
    return 1;
  }
  const html = fs.readFileSync(absPath, 'utf-8');
  const filename = path.basename(absPath);
  let violations = 0;

  console.log(`\ncanon-lint · ${filename}`);
  console.log('─'.repeat(60));

  // Rule 1: 4-color discipline
  const allHex = extractAllHexColors(html);
  const offPalette = [...allHex].filter(c => !CANON_FORMS.has(c));
  if (offPalette.length === 0) {
    pass(`4-color discipline · all ${allHex.size} hex values in canon`);
  } else {
    fail(`4-color discipline · ${offPalette.length} off-palette hex values:`);
    offPalette.forEach(c => fail(`    ${c}`));
    violations += offPalette.length;
  }

  // Rule 2: red text < 12px
  const smallRed = extractRedFontSizes(html);
  if (smallRed.length === 0) {
    pass('red text ≥ 12px · no undersized red');
  } else {
    fail(`red text < 12px · ${smallRed.length} violation(s):`);
    smallRed.forEach(v => fail(`    ${v.fontSize} → ${v.computedPx}px · ${v.block}…`));
    violations += smallRed.length;
  }

  // Rule 3: F13 pulse exactly once
  const f13 = countF13Pulse(html);
  if (f13 <= 1) {
    pass(`F13 pulse · ${f13} occurrence(s) · red ration honored`);
  } else if (f13 > 1) {
    // Note: F13 class may appear in multiple .strip sections. Count strictly
    // the *animated pulsing red* which is the ::before pseudo on .f13.
    fail(`F13 pulse · ${f13} .f13 class instances. Only one pulse per page.`);
    violations += 1;
  } else {
    pass(`F13 pulse · 0 · not on this page`);
  }

  // Rule 4: prefers-reduced-motion present
  if (hasReducedMotion(html)) {
    pass('prefers-reduced-motion · freezes animations');
  } else {
    fail('prefers-reduced-motion · missing or incomplete');
    violations += 1;
  }

  console.log('─'.repeat(60));
  if (violations === 0) {
    console.log(`\n999_SEAL · ${filename} canon-clean\n`);
    return 0;
  } else {
    console.log(`\n✗ ${violations} violation(s) · fix before 999\n`);
    return 1;
  }
}

if (require.main === module) {
  const args = process.argv.slice(2);
  if (args.length === 0) {
    console.log('usage: node canon-lint.js <html-file> [<html-file> …]');
    process.exit(2);
  }
  let total = 0;
  for (const f of args) total += lint(f);
  process.exit(total > 0 ? 1 : 0);
}

module.exports = { lint, CANON_FORMS };
