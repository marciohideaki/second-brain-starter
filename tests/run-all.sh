#!/bin/bash
# tests/run-all.sh — runs every smoke test in order. Exits non-zero if any fail.

set -u

HERE="$(cd "$(dirname "$0")" && pwd)"
PASSED=0
FAILED=0
FAILED_TESTS=()

run_test() {
  local name="$1"
  local script="$2"

  printf "▸ %-40s" "$name"
  if bash "$HERE/$script" >/dev/null 2>&1; then
    echo "PASS"
    PASSED=$((PASSED + 1))
  else
    echo "FAIL"
    FAILED=$((FAILED + 1))
    FAILED_TESTS+=("$name")
  fi
}

echo "======================================================"
echo "  second-brain-starter — smoke test suite"
echo "======================================================"
echo ""

run_test "shell syntax (all .sh parse cleanly)" "test-shell-syntax.sh"
run_test "directory structure"                  "test-structure.sh"
run_test "skills frontmatter"                   "test-skills-frontmatter.sh"
run_test "install.sh argument handling"         "test-install.sh"
run_test "cursor adapter (isolated)"            "test-cursor-adapter.sh"
run_test "codex adapter (isolated)"             "test-codex-adapter.sh"
run_test "gemini/antigravity adapters"          "test-gemini-antigravity-adapters.sh"
run_test "no proprietary terms in public files" "test-no-proprietary-terms.sh"

echo ""
echo "======================================================"
echo "  Passed: $PASSED"
echo "  Failed: $FAILED"
echo "======================================================"

if [ "$FAILED" -gt 0 ]; then
  echo ""
  echo "Failed tests:"
  for t in "${FAILED_TESTS[@]}"; do echo "  - $t"; done
  echo ""
  echo "Re-run individually for details:"
  echo "  bash tests/<script-name>.sh"
  exit 1
fi

exit 0
