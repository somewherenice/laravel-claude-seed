#!/usr/bin/env bash
# PostToolUse hook: auto-format edited .php files with Laravel Pint.
# Receives the tool event JSON on stdin. Formats only the changed file;
# non-.php and Blade files are skipped. Never blocks the agent flow.
# Portable across projects: resolves the project root via $CLAUDE_PROJECT_DIR
# (set by Claude Code) with a fallback to the current working directory.
set -u

input="$(cat)"

file_path="$(printf '%s' "$input" | python3 -c 'import sys,json
try:
    d=json.load(sys.stdin)
    print(d.get("tool_input",{}).get("file_path","") or "")
except Exception:
    print("")
')"

# Skip empty, non-.php, and Blade files
case "$file_path" in
  *.blade.php) exit 0 ;;
  *.php) ;;
  *) exit 0 ;;
esac

# Resolve project root and format the single file; swallow output, never fail
cd "${CLAUDE_PROJECT_DIR:-.}" 2>/dev/null || exit 0
vendor/bin/pint "$file_path" >/dev/null 2>&1
exit 0
