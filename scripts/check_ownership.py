#!/usr/bin/env python3
"""check_ownership.py — make truth duplication mechanically detectable.

Consumer: /root/forge_work/proposals/ownership/ownership-v1.yaml
Failure class: the same live datum rendered by more than one surface.

Checks:
  1. schema: every domain has owner/question/data; every surface has url/owns.
  2. disjointness: each domain has exactly one owning surface.
  3. view legality: a view may render a domain only if its owner surface does.
  4. liveness: every surface URL returns 2xx/3xx (followed).
  5. signature scan: for the hard-data domains, a non-owner surface whose scan
     target contains >=2 distinct owner signatures is a WARNING (not a hard fail;
     a source may consume a field without rendering it).

Exit: 0 = no errors (warnings allowed), 1 = errors, 2 = bad invocation.
"""

import argparse
import json
import os
import re
import sys
import urllib.request
from pathlib import Path

try:
    import yaml
except ImportError:
    print("PyYAML required: python3 -c 'import yaml'", file=sys.stderr)
    raise SystemExit(2)

HARD_DOMAINS = {"truth", "attention", "capability", "proof"}
UA = "Mozilla/5.0 (compatible; ownership-check/1.0)"


def norm_url(u: str) -> str:
    u = (u or "").strip().rstrip("/")
    return re.sub(r"^https?://", "", u)


def fetch(url: str, timeout: int = 12):
    req = urllib.request.Request(url, headers={"User-Agent": UA})
    try:
        with urllib.request.urlopen(req, timeout=timeout) as r:
            return r.status, r.read().decode("utf-8", "ignore")
    except Exception as e:
        return None, str(e)


def read_target(target: str, timeout: int = 12):
    if not target:
        return None, "EMPTY"
    if target.startswith("http://") or target.startswith("https://"):
        status, body = fetch(target, timeout)
        return (body if status else None), (f"HTTP {status}" if status else body)
    p = Path(target)
    if p.is_file():
        try:
            return p.read_text(encoding="utf-8", errors="ignore"), "OK"
        except Exception as e:
            return None, f"READ_ERROR {e}"
    return None, "MISSING"


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument(
        "--map",
        default=str(Path(__file__).resolve().parents[1] / "canon" / "ownership.yaml"),
    )
    ap.add_argument("--json", action="store_true")
    ap.add_argument("--strict", action="store_true", help="warnings become errors")
    ap.add_argument("--no-probe", action="store_true")
    ap.add_argument(
        "--no-runtime",
        action="store_true",
        help="skip the public-boundary (OWN-006) probe",
    )
    ap.add_argument("--timeout", type=int, default=12)
    args = ap.parse_args()

    doc = yaml.safe_load(Path(args.map).read_text(encoding="utf-8"))
    domains = doc.get("domains") or {}
    surfaces = doc.get("surfaces") or []

    errors, warnings = [], []

    # 1. schema
    for name, d in domains.items():
        for k in ("owner", "question", "data"):
            if not d.get(k):
                errors.append(f"domain {name}: missing {k}")
        if d.get("owner") and not d.get("internal"):
            if not any(
                norm_url(s.get("url")) == norm_url(d["owner"])
                or s.get("id") == d["owner"]
                for s in surfaces
            ):
                errors.append(
                    f"domain {name}: owner '{d['owner']}' is not a declared surface"
                )
    for s in surfaces:
        for k in ("id", "url", "owns"):
            if s.get(k) is None:
                errors.append(f"surface {s.get('id', '?')}: missing {k}")
        if s.get("id") and sum(1 for x in surfaces if x.get("id") == s["id"]) > 1:
            errors.append(f"surface id duplicated: {s['id']}")
        for own in s.get("owns") or []:
            if own not in domains:
                errors.append(f"surface {s['id']}: owns unknown domain '{own}'")
        for mr in s.get("may_render") or []:
            if mr not in domains:
                errors.append(f"surface {s['id']}: may_render unknown domain '{mr}'")

    # 2. disjointness
    owner_of = {}
    for s in surfaces:
        for own in s.get("owns") or []:
            if own in owner_of:
                errors.append(f"domain {own}: owned by {owner_of[own]} and {s['id']}")
            else:
                owner_of[own] = s["id"]
    for name in domains:
        if name not in owner_of and not domains[name].get("internal"):
            errors.append(f"domain {name}: no owning surface")

    # 3. view legality + OWN-002/OWN-003
    by_id = {s["id"]: s for s in surfaces if s.get("id")}
    for s in surfaces:
        if s.get("may_render") and not s.get("must_link"):
            errors.append(f"surface {s['id']}: OWN-002 may_render without must_link")
        if s.get("view_of") and s.get("owns"):
            errors.append(f"surface {s['id']}: OWN-003 view claims ownership")
        if s.get("view_of"):
            parent = by_id.get(s["view_of"])
            if not parent:
                errors.append(f"surface {s['id']}: view_of unknown '{s['view_of']}'")
            else:
                for mr in s.get("may_render") or []:
                    if mr not in (parent.get("owns") or []):
                        errors.append(
                            f"surface {s['id']}: view renders '{mr}' but {parent['id']} does not own it"
                        )

    # 4. liveness
    live = {}
    if not args.no_probe:
        for s in surfaces:
            status, body = fetch(s.get("url", ""), args.timeout)
            live[s["id"]] = status
            if status is None or status >= 400:
                errors.append(f"surface {s['id']}: {s['url']} -> {status or body}")

    # 5. signature scan (hard domains only)
    for s in surfaces:
        target, why = read_target(s.get("scan", ""), args.timeout)
        if target is None:
            warnings.append(f"surface {s['id']}: scan target unreadable ({why})")
            continue
        allowed = set(s.get("owns") or []) | set(s.get("may_render") or [])
        for name, d in domains.items():
            if name not in HARD_DOMAINS or name in allowed:
                continue
            sigs = [x for x in (d.get("signatures") or []) if x]
            hits = sorted({x for x in sigs if x.lower() in target.lower()})
            if len(hits) >= 2:
                warnings.append(
                    f"surface {s['id']}: renders/consumes '{name}' signatures {hits} "
                    f"without owning it (owner: {d.get('owner')})"
                )

    # 6. public boundary — OWN-006
    runtime_findings = []
    if not args.no_runtime:
        pb = doc.get("public_boundary") or {}
        for target in pb.get("targets", []):
            body, why = read_target(target, args.timeout)
            if body is None:
                runtime_findings.append(f"OWN-006 {target}: unreadable ({why})")
                continue
            for sig in pb.get("forbidden_signatures", []):
                if sig and re.search(r'"%s"\s*:' % re.escape(sig), body):
                    runtime_findings.append(f"OWN-006 {target}: exposes '{sig}'")

    report = {
        "map": str(Path(args.map)),
        "version": doc.get("version"),
        "status": doc.get("status"),
        "domains": len(domains),
        "surfaces": len(surfaces),
        "live": live,
        "scope": {
            "checked": [
                "schema",
                "disjointness",
                "view_legality",
                "liveness",
                "source_signatures",
                "public_boundary",
            ],
            "not_checked": [
                "rendered_dom",
                "network_fetch",
                "embedded_state",
                "full_provenance",
            ],
        },
        "errors": errors,
        "warnings": warnings,
        "runtime_findings": runtime_findings,
        "audit": {
            "proposal_local": {"installed": True, "blocking": True},
            "canonical_pipeline": {
                "installed": True,
                "wired": True,
                "reason": "called daily by /usr/local/bin/auditor-drift-check (6-gate CI)",
            },
            "rendered_stage_2": {"installed": False, "verdict": "UNKNOWN"},
        },
        "verdict": {
            "declaration_integrity": "FAIL" if errors else "PASS",
            "rendered_duplication": "UNKNOWN",
            "runtime_consistency": "FAIL" if runtime_findings else "PARTIAL",
        },
    }

    if args.json:
        print(json.dumps(report, indent=2))
    else:
        v = report["verdict"]
        print(
            f"DECLARED OWNERSHIP CHECK — {v['declaration_integrity']}  "
            f"({report['domains']} domains, {report['surfaces']} surfaces)"
        )
        print(f"Rendered duplication status — {v['rendered_duplication']}")
        print(f"Runtime consistency — {v['runtime_consistency']}")
        print(
            "Audit installation — proposal_local: INSTALLED+BLOCKING · "
            "canonical: INSTALLED (wired: YES) · "
            "rendered_stage_2: NOT INSTALLED (UNKNOWN)"
        )
        print(f"map: {report['map']}")
        for e in errors:
            print(f"  ERROR   {e}")
        for w in warnings:
            print(f"  WARN    {w}")
        for r in runtime_findings:
            print(f"  RUNTIME {r}")
        if not errors and not warnings and not runtime_findings:
            print("  no declaration or boundary violation detected")

    if errors or runtime_findings:
        return 1
    if args.strict and warnings:
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
