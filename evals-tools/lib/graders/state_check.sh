#!/usr/bin/env bash
# state_check.sh — Verify file system or environment state
# Sourced by runner.sh to provide run_state_check function
#
# Supports these check types:
#   file_exists  — verify a file exists at the given path
#   file_contains — verify a file matches a regex pattern
#   command      — run a command and check its exit code

# run_state_check <task_file> <grader_index>
# Sets GRADER_PASSED and GRADER_DETAIL in the caller's scope
run_state_check() {
  local task_file="$1"
  local gi="$2"

  local check_type
  check_type=$(yq -r ".graders[$gi].check" "$task_file")

  case "$check_type" in
    file_exists)
      local check_path
      check_path=$(yq -r ".graders[$gi].path" "$task_file")
      if [[ -f "$check_path" ]]; then
        GRADER_PASSED=true
        GRADER_DETAIL="File exists: $check_path"
      else
        GRADER_PASSED=false
        GRADER_DETAIL="File not found: $check_path"
      fi
      ;;

    file_contains)
      local check_path check_pattern
      check_path=$(yq -r ".graders[$gi].path" "$task_file")
      check_pattern=$(yq -r ".graders[$gi].pattern" "$task_file")
      if [[ -f "$check_path" ]] && grep -qE "$check_pattern" "$check_path"; then
        GRADER_PASSED=true
        GRADER_DETAIL="File $check_path matches pattern: $check_pattern"
      else
        GRADER_PASSED=false
        if [[ ! -f "$check_path" ]]; then
          GRADER_DETAIL="File not found: $check_path"
        else
          GRADER_DETAIL="File $check_path does not match pattern: $check_pattern"
        fi
      fi
      ;;

    command)
      local check_cmd expected_exit actual_exit
      check_cmd=$(yq -r ".graders[$gi].command" "$task_file")
      expected_exit=$(yq -r ".graders[$gi].expect_exit // 0" "$task_file")
      actual_exit=0
      GRADER_DETAIL=$(eval "$check_cmd" 2>&1) || actual_exit=$?
      if [[ "$actual_exit" -eq "$expected_exit" ]]; then
        GRADER_PASSED=true
      else
        GRADER_PASSED=false
        GRADER_DETAIL="Command exited $actual_exit (expected $expected_exit): $GRADER_DETAIL"
      fi
      ;;

    *)
      GRADER_PASSED=false
      GRADER_DETAIL="Unknown state_check type: $check_type"
      ;;
  esac
}
