#!/bin/bash
# Hermes P0 — discovery probe v3 (final). Isolated. No model calls, no agent runs.
set -u
ORIG="$1"; ROOT="$2"
FIX="$ROOT/fixture/agent-project-template"
export HERMES_HOME="$ROOT/home"
REALHOME="$HOME/.hermes"
PY=$(ls -d "$HOME"/.hermes/tools/python-3.14*/bin/python3 | head -1)
DEPS=$(ls -d "$HOME"/.hermes/cache/uv/archive-v0/*/ | tr '\n' ':')
export PYTHONPATH="$REALHOME/hermes-agent:$DEPS"

say() { printf '\n===== %s =====\n' "$1"; }
run() { printf '\n$ %s\n' "$*"; "$@" 2>&1; printf '[exit=%s]\n' "$?"; }
hashes() { ( cd "$ORIG" && shasum -a 256 AGENTS.md specs/methodology/approvals.md \
  specs/methodology/dynamic-agents.md .agents/skills/*/SKILL.md ) | sed "s|$ORIG/||"; }

say "0. environment"
printf 'date_local=%s\ndate_utc=%s\n' "$(date +%Y-%m-%dT%H:%M:%S%z)" "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
printf 'os=%s (%s)\n' "$(sw_vers -productVersion)" "$(uname -m)"
printf 'hermes_binary=%s\n' "$(command -v hermes)"
printf 'hermes_version=%s\n' "$(hermes --version 2>&1 | head -1)"
printf 'hermes_install=%s\n' "$(hermes --version 2>&1 | sed -n 's/^Install directory: //p')"
printf 'python=%s\n' "$($PY -V 2>&1)"
printf 'HERMES_HOME=%s\n' "$HERMES_HOME"

say "1. origin + real profile BEFORE"
printf 'origin_head=%s\n' "$(cd "$ORIG" && git rev-parse HEAD)"
printf 'origin_status=%s\n' "$(cd "$ORIG" && git status --porcelain | tr '\n' ';')"
printf 'real_config_sha256=%s\n' "$(shasum -a 256 "$REALHOME/config.yaml" | awk '{print $1}')"
printf 'real_trusted_dirs=%s\n' "$(env -u HERMES_HOME hermes config get skills.trusted_project_dirs | tr '\n' ' ')"
env -u HERMES_HOME hermes skills list 2>&1 | awk -F'│' 'NF>2{gsub(/^ +| +$/,"",$2); print $2}' | sort -u > "$ROOT/real-names-before.txt"
printf 'real_installed_skill_names=%s\n' "$(wc -l < "$ROOT/real-names-before.txt" | tr -d ' ')"
hashes > "$ROOT/hashes-before.txt"; printf 'origin_sha256_of_15_files=%s\n' "$(wc -l < "$ROOT/hashes-before.txt" | tr -d ' ')"

say "2. disposable clone"
mkdir -p "$ROOT/fixture"
run git clone --quiet --no-hardlinks "$ORIG" "$FIX"
printf 'fixture_head=%s\n' "$(cd "$FIX" && git rev-parse HEAD)"
printf 'fixture_skill_md_total=%s\n' "$(find "$FIX" -name SKILL.md -not -path '*/.git/*' | wc -l | tr -d ' ')"
printf 'fixture_.agents_skills=%s fixture_.claude_skills=%s\n' \
  "$(find "$FIX/.agents/skills" -name SKILL.md | wc -l | tr -d ' ')" \
  "$(find "$FIX/.claude/skills" -name SKILL.md | wc -l | tr -d ' ')"

say "3. fresh HERMES_HOME, BEFORE trust"
mkdir -p "$HERMES_HOME"
printf 'temp_home_config_existed=%s\n' "$(test -f "$HERMES_HOME/config.yaml" && echo yes || echo no)"
cd "$FIX" || exit 1
env HERMES_HOME="$HERMES_HOME" TERMINAL_CWD="$FIX" "$PY" - <<'PYEOF'
from agent.runtime_cwd import resolve_agent_cwd
from agent.skill_utils import (find_project_root, get_project_skills_dirs,
                               get_untrusted_project_skills_root)
from agent.prompt_builder import build_skills_system_prompt
print("resolve_agent_cwd() =", resolve_agent_cwd())
print("find_project_root() =", find_project_root())
print("get_project_skills_dirs() =", [str(d) for d in get_project_skills_dirs()])
un = get_untrusted_project_skills_root()
print("untrusted_notice(root,count) =", (str(un[0]), un[1]) if un else None)
idx = build_skills_system_prompt()
print("index_chars =", len(idx), "project_rows =", idx.count("[project]"))
PYEOF

say "4. trust the clone only"
run env HERMES_HOME="$HERMES_HOME" hermes skills trust "$FIX"
printf 'temp_config_sha256_after_trust=%s\n' "$(shasum -a 256 "$HERMES_HOME/config.yaml" | awk '{print $1}')"
printf 'trusted_dirs_temp_home=%s\n' "$(env HERMES_HOME="$HERMES_HOME" hermes config get skills.trusted_project_dirs | tr '\n' ' ')"
printf 'trust_idempotent:\n'; run env HERMES_HOME="$HERMES_HOME" hermes skills trust "$FIX"

say "5. resolver + quarantine + rendered index (no model)"
env HERMES_HOME="$HERMES_HOME" TERMINAL_CWD="$FIX" "$PY" - "$FIX" "$ROOT" <<'PYEOF'
import json, sys
from pathlib import Path
repo = Path(sys.argv[1]).resolve(); out = Path(sys.argv[2])
from agent.skill_utils import (find_project_root, get_project_skills_dirs,
    _candidate_project_skills_dirs, iter_skill_index_files, iter_project_skill_files,
    is_quarantined_project_skill, resolve_skill_catalog)
from agent.prompt_builder import (build_skills_system_prompt, _parse_skill_file,
    _build_snapshot_entry, _entry_name)
from tools.skills_guard import scan_skill_cached
from hermes_constants import get_hermes_home

print("find_project_root() =", find_project_root())
print("get_project_skills_dirs() =", [str(d) for d in get_project_skills_dirs()])
cands = _candidate_project_skills_dirs(repo)
print("candidate_dirs =", [str(d) for d in cands])
print("claude_skills_dir_scanned =", any(".claude" in str(d) for d in cands))
all_md = sorted(p for d in cands for p in iter_skill_index_files(d, "SKILL.md"))
print("canonical_skill_files =", len(all_md))
cache_dir = get_hermes_home() / "cache" / "project_skill_scans"
rows = []
for p in all_md:
    q = is_quarantined_project_skill(p)
    try:
        res, _prov = scan_skill_cached(p.parent, source="project-local", cache_dir=cache_dir)
        verdict = getattr(res, "verdict", None); summary = str(getattr(res, "summary", ""))[:120]
    except Exception as e:  # noqa: BLE001
        verdict, summary = f"error:{type(e).__name__}", str(e)
    rows.append({"name": p.parent.name, "quarantined": q, "verdict": verdict, "summary": summary})
print(json.dumps(rows, indent=1))
print("quarantined =", [r["name"] for r in rows if r["quarantined"]])
print("verdicts =", sorted({str(r["verdict"]) for r in rows}))

root_dir = get_project_skills_dirs()
catalog = []
for r in root_dir:
    for p in iter_project_skill_files(r):
        ok, fm, desc = _parse_skill_file(p)
        e = _build_snapshot_entry(p, r, fm, desc)
        catalog.append({**e, "name": _entry_name(e), "path": r / e["rel"],
                        "visible": ok, "tier": "project", "root": r})
resolved = resolve_skill_catalog(catalog)
visible = [e for e in resolved if e["visible"] and e["status"] != "shadowed"]
print("catalog_entries =", len(catalog), "resolved =", len(resolved), "visible =", len(visible))
print("load_names =", sorted(e["load_name"] for e in visible))
print("shadowed =", [(e["load_name"], e["status"]) for e in resolved if e["status"] != "ok"])

idx = build_skills_system_prompt()
print("index_chars =", len(idx), "project_rows =", idx.count("[project]"))
print("index_project_rows:")
for line in idx.splitlines():
    if "[project]" in line:
        print("   ", line.strip()[:160])
Path(out / "index.txt").write_text(idx, encoding="utf-8")
Path(out / "skill-rows.json").write_text(json.dumps(rows, indent=1), encoding="utf-8")
Path(out / "load-names.json").write_text(json.dumps(sorted(e["load_name"] for e in visible), indent=1), encoding="utf-8")
PYEOF

say "6. conflicts"
env -u HERMES_HOME hermes skills list 2>&1 | awk -F'│' 'NF>2{gsub(/^ +| +$/,"",$2); print $2}' | sort -u > "$ROOT/real-names-after.txt"
find "$FIX/.agents/skills" -name SKILL.md -maxdepth 2 | xargs -n1 dirname | xargs -n1 basename | sort -u > "$ROOT/project-names.txt"
printf 'real_profile_names=%s project_names=%s\n' "$(wc -l < "$ROOT/real-names-after.txt" | tr -d ' ')" "$(wc -l < "$ROOT/project-names.txt" | tr -d ' ')"
printf 'intersection_with_installed_skills:\n'; comm -12 "$ROOT/real-names-after.txt" "$ROOT/project-names.txt"; echo "(end)"
printf 'real_profile_name_list_unchanged=%s\n' "$(diff -q "$ROOT/real-names-before.txt" "$ROOT/real-names-after.txt" >/dev/null && echo yes || echo NO)"
printf 'registry_collisions_untested=only `hermes skills inspect` was tried once in an earlier probe; see summary\n'

say "7. origin + real profile AFTER"
printf 'origin_head=%s\n' "$(cd "$ORIG" && git rev-parse HEAD)"
printf 'origin_status=%s\n' "$(cd "$ORIG" && git status --porcelain | tr '\n' ';')"
hashes > "$ROOT/hashes-after.txt"
printf 'origin_hashes_identical=%s\n' "$(diff -q "$ROOT/hashes-before.txt" "$ROOT/hashes-after.txt" >/dev/null && echo yes || echo NO)"
printf 'real_config_sha256=%s\n' "$(shasum -a 256 "$REALHOME/config.yaml" | awk '{print $1}')"
printf 'real_trusted_dirs=%s\n' "$(env -u HERMES_HOME hermes config get skills.trusted_project_dirs | tr '\n' ' ')"
printf 'real_profile_project_rows=%s\n' "$(env -u HERMES_HOME hermes skills list 2>&1 | grep -c 'project' || true)"
printf 'fixture_working_tree_clean=%s\n' "$(cd "$FIX" && test -z "$(git status --porcelain)" && echo yes || echo NO)"

say "8. isolation facts"
printf 'fixture_git_inode=%s origin_git_inode=%s\n' "$(stat -f %i "$FIX/.git")" "$(stat -f %i "$ORIG/.git")"
printf 'temp_home_under_scratch=%s\n' "$([[ "$HERMES_HOME" == "$HOME"/.hermes/cache/scratch/* ]] && echo yes || echo no)"
printf 'temp_home_auth_json=%s temp_home_dot_env=%s\n' "$(ls "$HERMES_HOME"/auth.json 2>/dev/null | wc -l | tr -d ' ')" "$(ls "$HERMES_HOME"/.env 2>/dev/null | wc -l | tr -d ' ')"
printf 'temp_home_scan_cache_files=%s\n' "$(find "$HERMES_HOME/cache/project_skill_scans" -type f 2>/dev/null | wc -l | tr -d ' ')"
printf 'trust_only_in_temp_config=%s\n' "$(grep -c "$FIX" "$HERMES_HOME/config.yaml")"
printf 'real_config_mentions_fixture=%s\n' "$(grep -c "$FIX" "$REALHOME/config.yaml" || true)"
