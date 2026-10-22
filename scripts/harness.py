#!/usr/bin/env python3
"""Small, offline, standard-library harness checks and opt-in tool-call guard.

This is defense in depth, NOT proof of user approval and NOT a command sandbox.
"""
import json
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SKILLS = ("adopt-project", "bootstrap", "dev", "init-project", "orchestrate",
          "roadmap", "spec", "task", "tweak")

def block_reason(event):
    """Recognize a deliberately small set of dangerous direct shell commands."""
    if not isinstance(event, dict) or event.get("tool_name") not in ("Bash", "exec_command", "shell_command"):
        return None
    tool_input = event.get("tool_input", {})
    if not isinstance(tool_input, dict):
        return "Invalid shell tool payload"
    command = tool_input.get("command", tool_input.get("cmd", ""))
    if isinstance(command, list):
        command = " ".join(str(part) for part in command)
    if not isinstance(command, str):
        return "Invalid shell command input"
    # Deliberately narrow. Wrappers, scripts, tools and aliases can bypass patterns.
    if re.search(r"\bgh\s+pr\s+merge\b", command):
        return "PR merge must use the separately authorized review path"
    if re.search(r"\bgit\s+push\b", command) and (
        re.search(r"(?<!\S)(?:--force(?:-with-lease)?|-f)(?!\S)", command)
        or re.search(r"\bgit\s+push\s+(?:origin\s+)?(?:main|master)\b", command)
    ):
        return "Protected branch or force push denied by local guard"
    if re.search(r"\brm\s+-(?:[A-Za-z]*r[A-Za-z]*f|[A-Za-z]*f[A-Za-z]*r)\b", command):
        return "Recursive forced deletion denied by local guard"
    return None

def validate():
    errors = []
    def ensure(condition, message):
        if not condition:
            errors.append(message)
    for skill in SKILLS:
        source = ROOT / ".agents" / "skills" / skill / "SKILL.md"
        adapter = ROOT / ".claude" / "skills" / skill / "SKILL.md"
        ensure(source.is_file(), f"Missing canonical skill {skill}")
        ensure(adapter.is_file(), f"Missing Claude adapter {skill}")
        if adapter.is_file():
            text = adapter.read_text(encoding="utf-8")
            ensure(text.startswith(f"---\nname: {skill}\ndescription: "), f"Invalid Claude manifest {skill}")
            ensure(f".agents/skills/{skill}/SKILL.md" in text, f"Claude adapter not wired to canonical skill {skill}")
    for path in ("CLAUDE.md", "specs/methodology/approvals.md",
                 "docs/HARNESS.md", ".codex/hooks.json", ".claude/settings.json",
                 "evals/harness-cases.json", ".github/workflows/validate.yml"):
        ensure((ROOT / path).is_file(), f"Missing harness file {path}")
    claude = ROOT / "CLAUDE.md"
    if claude.is_file():
        text = claude.read_text(encoding="utf-8")
        ensure("AGENTS.md" in text and "specs/methodology/approvals.md" in text,
               "Claude entry point missing canonical policy links")
    for path in (".codex/hooks.json", ".claude/settings.json"):
        file = ROOT / path
        if file.is_file():
            try:
                cfg = json.loads(file.read_text(encoding="utf-8"))
                entries = cfg["hooks"]["PreToolUse"]
                ensure(any(e.get("matcher") == "Bash" and any(
                    re.search(r"scripts/harness\\.py[\\\"\x27]?\\s+guard", h.get("command", ""))
                    for h in e.get("hooks", [])) for e in entries),
                    f"Hook is not wired to Bash guard: {path}")
            except (ValueError, KeyError, TypeError) as exc:
                errors.append(f"Invalid hook configuration {path}: {exc}")
    ci = ROOT / ".github/workflows/validate.yml"
    if ci.is_file():
        text = ci.read_text(encoding="utf-8")
        ensure("python3 scripts/harness.py validate" in text, "Harness validation missing from CI")
        ensure("python3 scripts/harness.py eval" in text, "Harness evals missing from CI")
    return errors

def run_evals():
    path = ROOT / "evals/harness-cases.json"
    cases = json.loads(path.read_text(encoding="utf-8"))["cases"]
    errors = []
    for case in cases:
        actual = "deny" if block_reason(case["event"]) else "allow"
        if actual != case["expected"]:
            errors.append(f'{case["id"]}: expected {case["expected"]}, observed {actual}')
        # Check real hook output/exit status, not only Python classifier return.
        proc = subprocess.run([sys.executable, __file__, "guard"],
                              input=json.dumps(case["event"]), text=True,
                              capture_output=True, timeout=5)
        expected_code = 2 if case["expected"] == "deny" else 0
        if proc.returncode != expected_code:
            errors.append(f'{case["id"]}: hook returned {proc.returncode}, expected {expected_code}')
    return errors, len(cases)

def main():
    action = sys.argv[1] if len(sys.argv) == 2 else None
    if action == "guard":
        try:
            reason = block_reason(json.load(sys.stdin))
        except (ValueError, UnicodeError):
            print("Invalid hook JSON; refusing unverified tool call", file=sys.stderr)
            return 2
        if reason:
            print(reason, file=sys.stderr)
            return 2  # Both Claude and Codex block PreToolUse on exit 2.
        return 0
    if action == "validate":
        errors = validate()
        for error in errors:
            print(error, file=sys.stderr)
        if errors:
            return 1
        print(f"Harness structure validated: {len(SKILLS)} Claude skill adapters and both hook configs")
        return 0
    if action == "eval":
        errors, total = run_evals()
        for error in errors:
            print(error, file=sys.stderr)
        print(f"Deterministic harness cases: {total - len(errors)}/{total} passing")
        return 1 if errors else 0
    print("Usage: python3 scripts/harness.py {guard|validate|eval}", file=sys.stderr)
    return 2

if __name__ == "__main__":
    sys.exit(main())
