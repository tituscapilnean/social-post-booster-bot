#!/usr/bin/env bash
# deterministic.sh — Run a shell command grader
# Sourced by runner.sh. Expects $OUTPUT to be set.
#
# Usage (standalone):
#   export OUTPUT="the model response text"
#   ./deterministic.sh "echo \"\$OUTPUT\" | grep -qi 'hello'" 0
#
# Args:
#   $1 — command to run (with $OUTPUT available)
#   $2 — expected exit code (default: 0)
#
# Returns: exit 0 if grader passed, exit 1 if failed
# Prints: JSON with pass/fail and detail

set -uo pipefail

COMMAND="${1:?Usage: deterministic.sh <command> [expected_exit]}"
EXPECTED_EXIT="${2:-0}"

ACTUAL_EXIT=0
DETAIL=$(eval "$COMMAND" 2>&1) || ACTUAL_EXIT=$?

PASSED=false
if [[ "$ACTUAL_EXIT" -eq "$EXPECTED_EXIT" ]]; then
  PASSED=true
fi

jq -n \
  --argjson passed "$PASSED" \
  --argjson actual_exit "$ACTUAL_EXIT" \
  --argjson expected_exit "$EXPECTED_EXIT" \
  --arg detail "$DETAIL" \
  '{passed: $passed, actual_exit: $actual_exit, expected_exit: $expected_exit, detail: $detail}'
