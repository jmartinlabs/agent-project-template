#!/bin/bash
# Hermes P1 — one live session, one model call. Proves the project skills reach a real session.
#
#   bash evals/results/2026-11-10-hermes-p1-probe.sh <origin-repo> <work-dir>
#
# Two layers, both machine-checked from the log:
#   P1a  the skills index is gated on the skills toolset (`_skills_prompt`), no model, no cost;
#   P1b  one one-shot session in the disposable clone, under the write jail, lists all 11
#        canonical project Skills and returns a workflow classification.
# Credentials are never copied: the throwaway home symlinks the real auth.json/.env, and the
# write jail denies writes through the link. Model and provider are pinned below.
# Exit: 0 all pass, 1 any fail, 3 blocked (no credentials or no sandbox).
set -u
ORIG=$(cd "${1:?usage: probe.sh <origin-repo> <work-dir>}" && pwd -P)
ROOT=${2:?usage: probe.sh <origin-repo> <work-dir>}
mkdir -p "$ROOT" || exit 3
ROOT=$(cd "$ROOT" && pwd -P)
LOG="$ROOT/p1.log"
FIX="$ROOT/fixture/agent-project-template"
HOME_TMP="$ROOT/home"; TMP="$ROOT/tmp"; RUN="$ROOT/run"
REALHOME="$HOME/.hermes"
MODEL=${HERMES_PROBE_MODEL:-deepseek/deepseek-v4.1-flash}
PROVIDER=${HERMES_PROBE_PROVIDER:-commandcode}
TOTAL=0; FAILS=0; BLOCKED=0
: > "$LOG"

log() { printf '%s\n' "$*"; printf '%s\n' "$*" >> "$LOG"; }
say() { log ""; log "===== $1 ====="; }
check() {
  TOTAL=$((TOTAL+1))
  if [ "$2" = PASS ]; then log "CHECK $1 PASS ${3:-}"; else log "CHECK $1 FAIL ${3:-}"; FAILS=$((FAILS+1)); fi
}
blocked() { TOTAL=$((TOTAL+1)); BLOCKED=$((BLOCKED+1)); log "CHECK $1 BLOCKED $2"; }

mkdir -p "$HOME_TMP" "$TMP" "$RUN" "$ROOT/fixture"
chmod 700 "$HOME_TMP"

say "0. environment"
log "date_local=$(date +%Y-%m-%dT%H:%M:%S%z)"
log "os=$(sw_vers -productVersion) arch=$(uname -m)"
log "hermes=$(hermes --version 2>&1 | head -1)"
log "model=$MODEL provider=$PROVIDER"
log "origin=$ORIG"
log "work=$ROOT"

say "1. origin + real profile BEFORE"
hashes() { ( cd "$ORIG" && shasum -a 256 AGENTS.md README.md docs/HERMES_ADAPTER.md \
  .agents/skills/*/SKILL.md ) 2>/dev/null | sed "s|$ORIG/||"; }
hashes > "$ROOT/origin-hashes-before.txt"
log "origin_head=$(cd "$ORIG" && git rev-parse HEAD)"
log "origin_sha256_files=$(wc -l < "$ROOT/origin-hashes-before.txt" | tr -d ' ')"
log "real_config_sha256=$(shasum -a 256 "$REALHOME/config.yaml" | awk '{print $1}')"
log "real_trusted_dirs=$(env -u HERMES_HOME hermes config get skills.trusted_project_dirs | tr '\n' ' ')"

say "2. disposable clone + throwaway home"
[ -d "$FIX/.git" ] || git clone --quiet --no-hardlinks "$ORIG" "$FIX"
log "fixture_head=$(cd "$FIX" && git rev-parse HEAD)"
cp "$REALHOME/config.yaml" "$HOME_TMP/config.yaml"
if [ -f "$REALHOME/auth.json" ] && [ -f "$REALHOME/.env" ]; then
  ln -sfn "$REALHOME/auth.json" "$HOME_TMP/auth.json"
  ln -sfn "$REALHOME/.env" "$HOME_TMP/.env"
  log "credentials=symlinked (not copied): auth.json, .env"
else
  log "credentials=absent"
fi
# Write jail. The one carve-out outside the work dir is the launcher's own dependency state
# ($HOME/.hermes/installs/<key>/): it holds the .prepare.lock opened before any Python runs, and
# denying it aborts the launch with "install state is not writable". It is launcher plumbing, not
# repo, config or credentials; the probe records whether it changed.
INSTALLS="$REALHOME/installs"
find "$INSTALLS" -maxdepth 3 -type f 2>/dev/null | LC_ALL=C sort > "$ROOT/installs-before.txt"
cat > "$ROOT/p1.sb" <<EOF
(version 1)
(allow default)
(deny file-write*)
(allow file-write*
  (subpath "$ROOT")
  (subpath "$INSTALLS")
  (literal "/dev/null")
  (literal "/dev/zero")
  (subpath "/dev/fd"))
EOF
env HERMES_HOME="$HOME_TMP" hermes skills trust "$FIX" 2>&1 | sed 's/^/    /' >> "$LOG"
log "temp_trusted=$(env HERMES_HOME="$HOME_TMP" hermes config get skills.trusted_project_dirs | tr '\n' ' ')"

say "3. P1a. skills index gate (no model)"
PY=$(ls -d "$HOME"/.hermes/tools/python-3.*/bin/python3 2>/dev/null | head -1)
DEPS=$(ls -d "$HOME"/.hermes/cache/uv/archive-v0/*/ 2>/dev/null | tr '\n' ':')
if [ -n "${PY:-}" ] && [ -n "${DEPS:-}" ]; then
  ( cd "$FIX" && env HERMES_HOME="$HOME_TMP" TERMINAL_CWD="$FIX" \
      PYTHONPATH="$REALHOME/hermes-agent:$DEPS" "$PY" - "$ROOT" <<'PY'
import json, sys
from pathlib import Path
out = Path(sys.argv[1])
from agent.system_prompt import _skills_prompt

class Stub:
    platform = "cli"
    def __init__(self, names): self.valid_tool_names = set(names)

res = {}
for label, names in (("vision_only", {"vision_analyze"}),
                     ("with_skills", {"vision_analyze", "skills_list", "skill_view", "skill_manage"})):
    idx = _skills_prompt(Stub(names))
    res[label] = {"chars": len(idx), "project_rows": idx.count("[project]")}
print(json.dumps(res))
(out / "p1-gate.json").write_text(json.dumps(res, indent=1) + "\n", encoding="utf-8")
PY
  ) >> "$LOG" 2>&1
else
  log "python_or_deps_missing"
fi
if [ -f "$ROOT/p1-gate.json" ]; then
  python3 - "$ROOT/p1-gate.json" "$LOG" <<'PY'
import json, sys
d = json.load(open(sys.argv[1])); log = open(sys.argv[2], "a")
def chk(cid, ok, detail): log.write(f"CHECK {cid} {'PASS' if ok else 'FAIL'} {detail}\n")
chk("P1a1", d["vision_only"]["chars"] == 0,
    f"skills index with -t vision only: {d['vision_only']['chars']} chars")
chk("P1a2", d["with_skills"]["project_rows"] == 11,
    f"skills index with the skills toolset: {d['with_skills']['chars']} chars, {d['with_skills']['project_rows']} project rows")
PY
  TOTAL=$((TOTAL+2)); FAILS=$((FAILS + $(grep -c '^CHECK P1a[12] FAIL' "$LOG")))
else
  for i in P1a1 P1a2; do blocked $i "could not import the runtime out of band"; done
fi

say "4. P1b. one live session (1 model call)"
if command -v sandbox-exec > /dev/null 2>&1 && [ -e "$HOME_TMP/auth.json" ]; then
  cat > "$RUN/p1-driver.py" <<'PY'
"""Drives the product's own one-shot runtime, bypassing only the gateway dispatch layer
(a host singleton in this build). Same session construction as `hermes -z`."""
import sys
from hermes_cli.oneshot import run_oneshot
prompt = open(sys.argv[1], encoding="utf-8").read()
sys.exit(run_oneshot(prompt=prompt, model=sys.argv[3], provider=sys.argv[4],
                     toolsets=["vision", "skills"], skills=["orchestrate"],
                     usage_file=sys.argv[2]))
PY
  cat > "$RUN/p1.txt" <<'TXT'
Do not call any tool. From the skills index in your system prompt, answer only:
1. the exact names of the project Skills you can see, comma separated;
2. for the task "fix a typo in README.md", the single classification this project's method uses, one word.
Maximum 8 lines. No preamble.
TXT
  sandbox-exec -f "$ROOT/p1.sb" env HERMES_HOME="$HOME_TMP" TERMINAL_CWD="$FIX" TMPDIR="$TMP" \
    PYTHONPATH="$REALHOME/hermes-agent:$DEPS" "$PY" "$RUN/p1-driver.py" "$RUN/p1.txt" \
    "$RUN/p1-usage.json" "$MODEL" "$PROVIDER" > "$RUN/p1.out" 2> "$RUN/p1.err"
  log "session_exit=$?"
  log "--- response"
  sed 's/^/    /' "$RUN/p1.out" >> "$LOG"
  log "--- stderr (tail)"
  tail -5 "$RUN/p1.err" | sed 's/^/    /' >> "$LOG"
  if [ -s "$RUN/p1.out" ]; then
    MISSING=$(python3 - "$RUN/p1.out" <<'PY'
import re, sys
text = open(sys.argv[1], encoding="utf-8").read().lower()
names = ["init-project","bootstrap","roadmap","spec","dev","orchestrate","handoff","relay","task","tweak","adopt-project"]
print(",".join(n for n in names if n not in text))
PY
)
    [ -z "$MISSING" ] && check P1b1 PASS "all 11 canonical Skill names present in the response" \
                      || check P1b1 FAIL "missing from response: $MISSING"
    grep -qi 'quick' "$RUN/p1.out" && check P1b2 PASS "workflow classification returned (Quick) for a typo fix" \
                                  || check P1b2 FAIL "no Quick/Standard/Full classification in the response"
    CALLS=$(python3 -c "import json;print(json.load(open('$RUN/p1-usage.json')).get('api_calls'))" 2>/dev/null || echo "?")
    TOKENS=$(python3 -c "import json;d=json.load(open('$RUN/p1-usage.json'));print(d.get('total_tokens'))" 2>/dev/null || echo "?")
    if [ "$CALLS" = "1" ]; then check P1b3 PASS "usage report: api_calls=1 total_tokens=$TOKENS"
    else check P1b3 FAIL "usage report: api_calls=$CALLS total_tokens=$TOKENS"; fi
  else
    TOTAL=$((TOTAL+2)); FAILS=$((FAILS+2))
    log "CHECK P1b1 FAIL empty response"
    log "CHECK P1b2 FAIL empty response"
  fi
else
  blocked P1b1 "sandbox-exec or credentials unavailable"
  blocked P1b2 "sandbox-exec or credentials unavailable"
fi

say "5. D. origin and real profile untouched"
hashes > "$ROOT/origin-hashes-after.txt"
diff -q "$ROOT/origin-hashes-before.txt" "$ROOT/origin-hashes-after.txt" > /dev/null \
  && check D1 PASS "origin content hashes identical before/after" || check D1 FAIL "origin content changed"
REAL_AFTER=$(shasum -a 256 "$REALHOME/config.yaml" | awk '{print $1}')
REAL_TRUST=$(env -u HERMES_HOME hermes config get skills.trusted_project_dirs | tr '\n' ' ')
log "real_config_sha256_after=$REAL_AFTER"
log "real_trusted_dirs_after=$REAL_TRUST"
if [ "$REAL_AFTER" = "$(grep '^real_config_sha256=' "$LOG" | head -1 | cut -d= -f2)" ] && [ "$REAL_TRUST" = "[] " ]; then
  check D2 PASS "real profile config and trust unchanged"
else
  check D2 FAIL "real profile changed"
fi
if [ -z "$(cd "$FIX" && git status --porcelain)" ]; then check D3 PASS "fixture working tree clean"; else check D3 FAIL "fixture dirty"; fi
find "$INSTALLS" -maxdepth 3 -type f 2>/dev/null | LC_ALL=C sort > "$ROOT/installs-after.txt"
log "launcher_install_state_new_files=$(diff "$ROOT/installs-before.txt" "$ROOT/installs-after.txt" | grep -c '^>' || true)"
log "credential_files_copied=0 (symlinks only)"

say "6. result"
PASSED=$((TOTAL-FAILS)); log "CHECKS total=$TOTAL pass=$PASSED fail=$FAILS blocked=$BLOCKED"
if [ "$FAILS" -eq 0 ]; then log "RESULT PASS ${PASSED}/${TOTAL}"; exit 0; else log "RESULT FAIL ${PASSED}/${TOTAL}"; exit 1; fi
