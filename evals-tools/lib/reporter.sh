#!/usr/bin/env bash
# reporter.sh — Generates summary from eval results
# Sourced by runner.sh to provide generate_summary function
#
# Also usable standalone:
#   source lib/reporter.sh
#   generate_summary results/run_id/results.json results/run_id/summary.md

generate_summary() {
  local results_file="$1"
  local output_file="$2"

  local suite model trials_per_task run_id timestamp
  suite=$(jq -r '.suite' "$results_file")
  model=$(jq -r '.model' "$results_file")
  trials_per_task=$(jq -r '.trials_per_task' "$results_file")
  run_id=$(jq -r '.run_id' "$results_file")
  timestamp=$(jq -r '.timestamp' "$results_file")

  # Get unique task IDs
  local task_ids
  task_ids=$(jq -r '[.results[].task_id] | unique | .[]' "$results_file")

  local total_tasks=0
  local total_passed=0
  local task_rows=""

  for task_id in $task_ids; do
    total_tasks=$((total_tasks + 1))

    # Count trials and passes for this task
    local task_trials task_passes
    task_trials=$(jq "[.results[] | select(.task_id == \"$task_id\")] | length" "$results_file")
    task_passes=$(jq "[.results[] | select(.task_id == \"$task_id\" and .passed == true)] | length" "$results_file")

    # Calculate pass rates
    local pass_rate
    if [[ "$task_trials" -gt 0 ]]; then
      pass_rate=$(echo "scale=2; $task_passes / $task_trials * 100" | bc)
    else
      pass_rate="0"
    fi

    # pass@1: probability of at least 1 pass in 1 trial = per-trial pass rate
    local pass_at_1="$pass_rate"

    # pass@k: probability of at least 1 pass in k trials = 1 - (1 - p)^k
    local pass_at_k
    if [[ "$task_trials" -gt 0 ]]; then
      local fail_rate
      fail_rate=$(echo "scale=6; 1 - ($task_passes / $task_trials)" | bc)
      pass_at_k=$(echo "scale=2; (1 - ($fail_rate ^ $task_trials)) * 100" | bc)
    else
      pass_at_k="0"
    fi

    # pass^k: probability all k trials pass = p^k
    local pass_pow_k
    if [[ "$task_trials" -gt 0 ]]; then
      local p
      p=$(echo "scale=6; $task_passes / $task_trials" | bc)
      pass_pow_k=$(printf "%.2f" "$(echo "scale=6; ($p ^ $task_trials) * 100" | bc)")
    else
      pass_pow_k="0"
    fi

    # Average duration
    local avg_duration
    avg_duration=$(jq "[.results[] | select(.task_id == \"$task_id\") | .duration_s] | add / length | floor" "$results_file")

    # Determine status icon
    local status="FAIL"
    if [[ "$task_passes" -eq "$task_trials" ]]; then
      status="PASS"
    elif [[ "$task_passes" -gt 0 ]]; then
      status="PARTIAL"
    fi

    task_rows+="| $task_id | $status | $task_passes/$task_trials | ${pass_at_1}% | ${pass_at_k}% | ${pass_pow_k}% | ${avg_duration}s |"$'\n'

    if [[ "$task_passes" -eq "$task_trials" ]]; then
      total_passed=$((total_passed + 1))
    fi
  done

  # Get grader breakdown per task
  local grader_details=""
  for task_id in $task_ids; do
    grader_details+="### $task_id"$'\n\n'

    # Get grader names from first trial
    local grader_names
    grader_names=$(jq -r "[.results[] | select(.task_id == \"$task_id\")][0].graders[].name" "$results_file" 2>/dev/null)

    if [[ -n "$grader_names" ]]; then
      for gname in $grader_names; do
        local g_passes g_total g_type
        g_total=$(jq "[.results[] | select(.task_id == \"$task_id\")] | length" "$results_file")
        g_passes=$(jq "[.results[] | select(.task_id == \"$task_id\") | .graders[] | select(.name == \"$gname\" and .passed == true)] | length" "$results_file")
        g_type=$(jq -r "[.results[] | select(.task_id == \"$task_id\")][0].graders[] | select(.name == \"$gname\") | .type" "$results_file")

        grader_details+="- **$gname** ($g_type): $g_passes/$g_total passed"$'\n'
      done
    fi
    grader_details+=$'\n'
  done

  # Write summary
  cat > "$output_file" << EOF
# Eval Results: $suite

| | |
|---|---|
| **Run ID** | $run_id |
| **Model** | $model |
| **Trials/Task** | $trials_per_task |
| **Timestamp** | $timestamp |
| **Tasks Passed** | $total_passed / $total_tasks |

## Results

| Task | Status | Pass/Total | pass@1 | pass@k | pass^k | Avg Duration |
|------|--------|------------|--------|--------|--------|--------------|
${task_rows}
## Metrics

- **pass@1**: Probability of passing on a single attempt
- **pass@k**: Probability of at least one pass in k trials (higher = easier)
- **pass^k**: Probability of all k trials passing (higher = more consistent)

## Grader Breakdown

${grader_details}
## Transcripts

Full transcripts are in \`transcripts/\` directory.
EOF

  echo "Summary written to $output_file"
}
