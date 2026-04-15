#!/usr/bin/env bash
# runner.sh — Orchestrates eval runs via Claude Code CLI
# Usage: ./lib/runner.sh <suite.yaml>
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# --- Dependencies check ---
for cmd in yq jq claude; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "ERROR: '$cmd' is required but not found. Please install it." >&2
    exit 1
  fi
done

# --- macOS compatibility: timeout command ---
TIMEOUT_CMD="timeout"
if ! command -v timeout &>/dev/null; then
  if command -v gtimeout &>/dev/null; then
    TIMEOUT_CMD="gtimeout"
  else
    # Fallback: define a timeout function using perl (available on macOS)
    TIMEOUT_CMD=""
  fi
fi

# --- Args ---
SUITE_FILE="${1:?Usage: runner.sh <suite.yaml> [--task <task_id>]}"
FILTER_TASK=""
shift
while [[ $# -gt 0 ]]; do
  case "$1" in
    --task) FILTER_TASK="$2"; shift 2 ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

if [[ ! -f "$SUITE_FILE" ]]; then
  echo "ERROR: Suite file not found: $SUITE_FILE" >&2
  exit 1
fi

SUITE_DIR="$(cd "$(dirname "$SUITE_FILE")" && pwd)"

# --- Parse suite config ---
SUITE_NAME=$(yq -r '.name' "$SUITE_FILE")
SUITE_MODEL=$(yq -r '.model // "sonnet"' "$SUITE_FILE")
TRIALS=$(yq -r '.trials_per_task // 3' "$SUITE_FILE")
TASKS_DIR=$(yq -r '.tasks_dir // "./tasks"' "$SUITE_FILE")
GLOBAL_TIMEOUT=$(yq -r '.timeout // 120' "$SUITE_FILE")
CLAUDE_FLAGS=$(yq -r '.claude_flags // ""' "$SUITE_FILE")

# Resolve tasks dir relative to suite file
if [[ ! "$TASKS_DIR" = /* ]]; then
  TASKS_DIR="$SUITE_DIR/$TASKS_DIR"
fi

# --- Setup results directory ---
RUN_ID="$(date +%Y%m%d_%H%M%S)_${SUITE_NAME}"
RESULTS_DIR="$ROOT_DIR/results/$RUN_ID"
TRANSCRIPTS_DIR="$RESULTS_DIR/transcripts"
mkdir -p "$TRANSCRIPTS_DIR"

echo "============================================"
echo "  Eval Suite: $SUITE_NAME"
echo "  Model: $SUITE_MODEL"
echo "  Trials per task: $TRIALS"
echo "  Run ID: $RUN_ID"
echo "============================================"
echo ""

# --- Discover tasks ---
TASK_FILES=()
while IFS= read -r f; do
  TASK_FILES+=("$f")
done < <(find "$TASKS_DIR" -name "*.yaml" -o -name "*.yml" | sort)

if [[ ${#TASK_FILES[@]} -eq 0 ]]; then
  echo "ERROR: No task files found in $TASKS_DIR" >&2
  exit 1
fi

echo "Found ${#TASK_FILES[@]} task(s)"
echo ""

# --- Initialize results array ---
ALL_RESULTS="[]"

# --- Run each task ---
for TASK_FILE in "${TASK_FILES[@]}"; do
  TASK_ID=$(yq -r '.id' "$TASK_FILE")

  # Skip tasks that don't match the filter
  if [[ -n "$FILTER_TASK" && "$TASK_ID" != "$FILTER_TASK" ]]; then
    continue
  fi
  TASK_DESC=$(yq -r '.description' "$TASK_FILE")
  TASK_PROMPT=$(yq -r '.prompt' "$TASK_FILE")
  TASK_TIMEOUT=$(yq -r ".timeout // $GLOBAL_TIMEOUT" "$TASK_FILE")
  TASK_WORKDIR=$(yq -r '.workdir // "."' "$TASK_FILE")

  # Resolve workdir relative to repo root
  if [[ ! "$TASK_WORKDIR" = /* ]]; then
    TASK_WORKDIR="$(pwd)/$TASK_WORKDIR"
  fi

  # Read context files and prepend to prompt
  CONTEXT=""
  CONTEXT_COUNT=$(yq -r '.context_files | length' "$TASK_FILE")
  if [[ "$CONTEXT_COUNT" -gt 0 ]]; then
    for i in $(seq 0 $((CONTEXT_COUNT - 1))); do
      CTX_PATH=$(yq -r ".context_files[$i]" "$TASK_FILE")
      if [[ -f "$CTX_PATH" ]]; then
        CONTEXT+="--- Context from $CTX_PATH ---"$'\n'
        CONTEXT+="$(cat "$CTX_PATH")"$'\n\n'
      else
        echo "  WARNING: Context file not found: $CTX_PATH"
      fi
    done
  fi

  FULL_PROMPT="${CONTEXT}${TASK_PROMPT}"

  # Build tool flags
  TOOL_FLAGS=""
  TOOL_COUNT=$(yq -r '.tools | length' "$TASK_FILE")
  if [[ "$TOOL_COUNT" -gt 0 ]]; then
    TOOLS_LIST=$(yq -r '.tools[]' "$TASK_FILE" | paste -sd ',' -)
    TOOL_FLAGS="--allowedTools $TOOLS_LIST"
  fi

  echo "--- Task: $TASK_ID ---"
  echo "  $TASK_DESC"

  TASK_RESULTS="[]"

  for TRIAL_NUM in $(seq 1 "$TRIALS"); do
    echo "  Trial $TRIAL_NUM/$TRIALS..."

    TRIAL_START=$(date +%s)

    # Run claude CLI and capture output
    TRANSCRIPT_FILE="$TRANSCRIPTS_DIR/${TASK_ID}_trial${TRIAL_NUM}.txt"
    OUTPUT=""
    CLAUDE_EXIT=0

    # Pipe prompt via stdin to avoid CLI misinterpreting leading dashes as options
    if [[ -n "$TIMEOUT_CMD" ]]; then
      OUTPUT=$(echo "$FULL_PROMPT" | $TIMEOUT_CMD "$TASK_TIMEOUT" claude --print --model "$SUITE_MODEL" \
        $TOOL_FLAGS $CLAUDE_FLAGS \
        --output-format text \
        -p - 2>"$TRANSCRIPT_FILE.stderr") || CLAUDE_EXIT=$?
    else
      OUTPUT=$(echo "$FULL_PROMPT" | claude --print --model "$SUITE_MODEL" \
        $TOOL_FLAGS $CLAUDE_FLAGS \
        --output-format text \
        -p - 2>"$TRANSCRIPT_FILE.stderr") || CLAUDE_EXIT=$?
    fi

    TRIAL_END=$(date +%s)
    TRIAL_DURATION=$((TRIAL_END - TRIAL_START))

    # Save transcript
    echo "$OUTPUT" > "$TRANSCRIPT_FILE"

    # Handle timeout
    if [[ $CLAUDE_EXIT -eq 124 ]]; then
      echo "    TIMEOUT after ${TASK_TIMEOUT}s"
      TRIAL_RESULT=$(jq -n \
        --arg task_id "$TASK_ID" \
        --argjson trial "$TRIAL_NUM" \
        --argjson duration "$TRIAL_DURATION" \
        '{task_id: $task_id, trial: $trial, duration_s: $duration, timed_out: true, graders: [], passed: false}')
      TASK_RESULTS=$(echo "$TASK_RESULTS" | jq --argjson r "$TRIAL_RESULT" '. + [$r]')
      continue
    fi

    # --- Run graders ---
    GRADER_RESULTS="[]"
    GRADER_COUNT=$(yq -r '.graders | length' "$TASK_FILE")
    ALL_GRADERS_PASSED=true

    for gi in $(seq 0 $((GRADER_COUNT - 1))); do
      GRADER_TYPE=$(yq -r ".graders[$gi].type" "$TASK_FILE")
      GRADER_NAME=$(yq -r ".graders[$gi].name // \"grader_$gi\"" "$TASK_FILE")

      GRADER_PASSED=false
      GRADER_DETAIL=""

      case "$GRADER_TYPE" in
        deterministic)
          GRADER_CMD=$(yq -r ".graders[$gi].command" "$TASK_FILE")
          EXPECTED_EXIT=$(yq -r ".graders[$gi].expect_exit // 0" "$TASK_FILE")

          # Run grader command with OUTPUT available
          ACTUAL_EXIT=0
          export OUTPUT
          GRADER_DETAIL=$(eval "$GRADER_CMD" 2>&1) || ACTUAL_EXIT=$?

          if [[ "$ACTUAL_EXIT" -eq "$EXPECTED_EXIT" ]]; then
            GRADER_PASSED=true
          fi
          GRADER_DETAIL="exit=$ACTUAL_EXIT expected=$EXPECTED_EXIT"
          ;;

        llm_judge)
          RUBRIC=$(yq -r ".graders[$gi].rubric" "$TASK_FILE")
          # Call claude to judge the output
          JUDGE_PROMPT="You are an eval grader. Grade this LLM output against the rubric.

TASK: $TASK_DESC

RUBRIC:
$RUBRIC

OUTPUT TO GRADE:
$OUTPUT

Respond with ONLY valid JSON: {\"scores\": {...}, \"reasoning\": \"...\", \"pass\": true/false}"

          JUDGE_RESULT=$(claude --print --model sonnet \
            --output-format text \
            -p "$JUDGE_PROMPT" 2>/dev/null) || true

          # Extract pass/fail from judge response
          if echo "$JUDGE_RESULT" | jq -e '.pass' &>/dev/null; then
            PASS_VAL=$(echo "$JUDGE_RESULT" | jq -r '.pass')
            if [[ "$PASS_VAL" == "true" ]]; then
              GRADER_PASSED=true
            fi
            GRADER_DETAIL="$JUDGE_RESULT"
          else
            # Try to extract JSON from markdown code blocks
            JSON_BLOCK=$(echo "$JUDGE_RESULT" | sed -n '/```json/,/```/p' | sed '1d;$d')
            if [[ -n "$JSON_BLOCK" ]] && echo "$JSON_BLOCK" | jq -e '.pass' &>/dev/null; then
              PASS_VAL=$(echo "$JSON_BLOCK" | jq -r '.pass')
              if [[ "$PASS_VAL" == "true" ]]; then
                GRADER_PASSED=true
              fi
              GRADER_DETAIL="$JSON_BLOCK"
            else
              # Fallback: check if output contains "pass": true anywhere
              if echo "$JUDGE_RESULT" | grep -qi '"pass"[[:space:]]*:[[:space:]]*true'; then
                GRADER_PASSED=true
              fi
              GRADER_DETAIL="$JUDGE_RESULT"
            fi
          fi
          ;;

        state_check)
          source "$SCRIPT_DIR/graders/state_check.sh"
          run_state_check "$TASK_FILE" "$gi"
          ;;

        *)
          echo "    WARNING: Unknown grader type: $GRADER_TYPE"
          GRADER_DETAIL="unknown grader type"
          ;;
      esac

      if [[ "$GRADER_PASSED" != "true" ]]; then
        ALL_GRADERS_PASSED=false
      fi

      STATUS_ICON="✓"
      if [[ "$GRADER_PASSED" != "true" ]]; then STATUS_ICON="✗"; fi
      echo "    $STATUS_ICON $GRADER_NAME ($GRADER_TYPE)"

      # Escape detail for JSON
      ESCAPED_DETAIL=$(echo "$GRADER_DETAIL" | jq -Rs '.')

      GRADER_RESULT=$(jq -n \
        --arg name "$GRADER_NAME" \
        --arg type "$GRADER_TYPE" \
        --argjson passed "$GRADER_PASSED" \
        --argjson detail "$ESCAPED_DETAIL" \
        '{name: $name, type: $type, passed: $passed, detail: $detail}')

      GRADER_RESULTS=$(echo "$GRADER_RESULTS" | jq --argjson r "$GRADER_RESULT" '. + [$r]')
    done

    TRIAL_RESULT=$(jq -n \
      --arg task_id "$TASK_ID" \
      --argjson trial "$TRIAL_NUM" \
      --argjson duration "$TRIAL_DURATION" \
      --argjson graders "$GRADER_RESULTS" \
      --argjson passed "$ALL_GRADERS_PASSED" \
      '{task_id: $task_id, trial: $trial, duration_s: $duration, timed_out: false, graders: $graders, passed: $passed}')

    TASK_RESULTS=$(echo "$TASK_RESULTS" | jq --argjson r "$TRIAL_RESULT" '. + [$r]')
  done

  ALL_RESULTS=$(echo "$ALL_RESULTS" | jq --argjson r "$TASK_RESULTS" '. + $r')
  echo ""
done

# --- Write results ---
RESULTS_JSON=$(jq -n \
  --arg suite "$SUITE_NAME" \
  --arg model "$SUITE_MODEL" \
  --argjson trials "$TRIALS" \
  --arg run_id "$RUN_ID" \
  --arg timestamp "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  --argjson results "$ALL_RESULTS" \
  '{suite: $suite, model: $model, trials_per_task: $trials, run_id: $run_id, timestamp: $timestamp, results: $results}')

echo "$RESULTS_JSON" | jq '.' > "$RESULTS_DIR/results.json"

# --- Generate summary ---
source "$SCRIPT_DIR/reporter.sh"
generate_summary "$RESULTS_DIR/results.json" "$RESULTS_DIR/summary.md"

echo "============================================"
echo "  Results: $RESULTS_DIR/results.json"
echo "  Summary: $RESULTS_DIR/summary.md"
echo "============================================"
