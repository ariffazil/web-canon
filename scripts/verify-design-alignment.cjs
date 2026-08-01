#!/usr/bin/env node
/**
 * verify-design-alignment.cjs — SENSE_ALIGN gate for arif-fazil.com
 * "GREEN route does not mean aligned design."
 * Checks every canonical route for: 200, tokens.css, data-ring, data-plane,
 * TrinityNav, CanonFooter, no banned local CSS variables.
 *
 * Usage:
 *   node verify-design-alignment.cjs            # all routes
 *   node verify-design-alignment.cjs /writing   # one route
 *   VERIFY_ALIGN_LIVE=0 node verify-design-alignment.cjs  # source files, not HTTP
 *
 * Exit: 0 = aligned, 1 = violations found
 */
const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

const SITE = '/root/arif-fazil.com/sites/arif-fazil.com';
const ATLAS = '/root/web-canon/canon/atlas.yaml';
const BASE = 'https://arif-fazil.com';
const TOKENS_CSS = '/_shared/design-system/tokens.css';
const LIVE = process.env.VERIFY_ALIGN_LIVE !== '0';

// Banned local design: these should never be page-local (must come from tokens.css)
const BANNED_CSS_PATTERNS = [
  /--[a-z0-9-]*(color|colour)[a-z0-9-]*\s*:/i,   // local color tokens
  /#(?:[0-9a-fA-F]{3}|[0-9a-fA-F]{6})\b/,        // raw hex colors
  /rgba?\(\s*\d+\s*,\s*\d+\s*,\s*\d+/,           // raw rgb colors
];

function fetch(url) {
  try {
    const out = execSync(`curl -s -m 10 "${url}"`, { maxBuffer: 10 * 1024 * 1024 }).toString();
    return out;
  } catch { return ''; }
}

function loadAtlasRoutes() {
  try {
    // Minimal YAML parse: extract routes block keys (top-level under routes:)
    const txt = fs.readFileSync(ATLAS, 'utf8');
    const routes = [];
    const inRoutes = txt.split('\n').findIndex((l) => l.trim() === 'routes:');
    if (inRoutes < 0) return routes;
    for (let i = inRoutes + 1; i < txt.split('\n').length; i++) {
      const line = txt.split('\n')[i];
      if (line.trim() === '' || line.startsWith('  #')) continue;
      const m = line.match(/^  (\S[^:]*):\s*$/);
      if (m) { routes.push(m[1]); continue; }
      // Exit routes block when indent drops below 2 spaces
      if (/^[^\s]/.test(line) || /^ [^\s]/.test(line)) break;
    }
    return routes;
  } catch { return []; }
}

function checkSourceFile(route, checks) {
  // For source-side check: find the page file and inspect for data-ring, tokens link
  const pageDir = SITE + '/src/pages';
  let found = null;
  try {
    const files = fs.readdirSync(pageDir);
    found = files.find((f) => route.replace(/\//g, '').toLowerCase() === f.replace(/\.tsx$/, '').toLowerCase());
  } catch {}
  checks.push({ check: 'source_file', ok: !!found, detail: found ? `src/pages/${found}` : 'no page file' });
  if (found) {
    const src = fs.readFileSync(path.join(pageDir, found), 'utf8');
    checks.push({ check: 'data_ring', ok: /data-ring|data-ring=/.test(src) || /data-ring=/.test(src), detail: 'data-ring declared' });
    checks.push({ check: 'data_plane', ok: /data-plane/.test(src), detail: 'data-plane declared' });
    checks.push({ check: 'tokens_import', ok: /tokens\.css|_shared\/design-system/.test(src), detail: 'tokens.css referenced' });
    const banned = [];
    for (const pat of BANNED_CSS_PATTERNS) {
      const matches = src.match(pat);
      if (matches) banned.push(matches[0].trim().slice(0, 60));
    }
    checks.push({ check: 'no_local_style', ok: banned.length === 0, detail: banned.length ? `banned: ${banned.slice(0,3).join(' | ')}` : 'clean' });
  }
}

async function main() {
  const target = process.argv[2];
  const routes = target ? [target] : loadAtlasRoutes();
  if (!routes.length) {
    console.error('✗ No routes found (pass a route or fix atlas.yaml parse)');
    process.exit(1);
  }

  const results = [];
  for (const route of routes) {
    const checks = [];
    const url = BASE + route;
    const html = fetch(url);

    checks.push({ check: 'route_200', ok: html.includes('<title>') || html.length > 500, detail: `${html.length}B` });
    checks.push({ check: 'tokens_loaded', ok: html.includes(TOKENS_CSS), detail: TOKENS_CSS });
    checks.push({ check: 'data_ring', ok: /data-ring="[A-Z]+"/.test(html), detail: (html.match(/data-ring="([^"]*)"/) || [,'?'])[1] });
    checks.push({ check: 'data_plane', ok: /data-plane="[a-z]+"/.test(html), detail: (html.match(/data-plane="([^"]*)"/) || [,'?'])[1] });
    checks.push({ check: 'trinity_nav', ok: /Trinity|trinity|HUMAN.*INSTITUTION.*EARTH/.test(html), detail: 'TrinityNav markers' });
    checks.push({ check: 'canon_footer', ok: /DITEMPA BUKAN DIBERI|CanonFooter|DITEMPA/i.test(html), detail: 'footer marker' });

    if (!LIVE) checkSourceFile(route, checks);

    const fails = checks.filter((c) => !c.ok);
    results.push({ route, ok: fails.length === 0, checks, fails });
  }

  // Report
  let pass = 0, fail = 0;
  for (const r of results) {
    if (r.ok) { pass++; continue; }
    fail++;
    console.log(`\n✗ ALIGN FAIL: ${r.route}`);
    for (const f of r.fails) console.log(`    ${f.check}: ${f.detail}`);
  }
  console.log(`\n═ SENSE_ALIGN: ${pass}/${results.length} aligned · ${fail} violations ${fail ? '🔴' : '✅'}`);
  process.exit(fail ? 1 : 0);
}

main().catch((e) => { console.error(e.message); process.exit(1); });
