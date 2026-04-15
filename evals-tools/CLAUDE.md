# evals-tools

A portable, language-agnostic eval framework for validating LLM prompts and agent behavior. Designed as a Claude Code skill you can drop into any repo.

## How it works

1. Define eval suites in YAML (see `templates/` for schema)
2. Run `/eval <suite.yaml>` from Claude Code
3. The runner executes each task via `claude` CLI, grades results, and produces a summary

## Structure

- `commands/eval.md` — Claude Code slash command entry point
- `lib/runner.sh` — Orchestrates eval runs
- `lib/graders/` — Deterministic, LLM-as-judge, and state check graders
- `lib/reporter.sh` — Aggregates results into JSON + markdown
- `templates/` — YAML schema templates for suites and tasks
- `examples/` — Working example eval suites
- `results/` — Generated output (gitignored)

## Adding to another repo

```bash
# Option 1: Git submodule
git submodule add <this-repo-url> evals-tools

# Option 2: Clone directly
git clone <this-repo-url> evals-tools
```

Then symlink or copy the slash command into your project:
```bash
mkdir -p .claude/commands
ln -s ../../evals-tools/commands/eval.md .claude/commands/eval.md
```

## Dependencies

- `claude` CLI (Claude Code)
- `yq` for YAML parsing (install via `brew install yq` or `pip install yq`)
- `jq` for JSON processing
- Standard POSIX shell utilities

## Writing evals

See `templates/suite.yaml` and `templates/task.yaml` for the full schema. Key concepts:

- **Suite**: Collection of tasks with shared config (model, trial count)
- **Task**: Single test case with a prompt, optional context, and graders
- **Graders**: How to score the output — deterministic (shell commands), llm_judge (rubric-based), or state_check (file/env verification)
- **Trials**: Each task runs N times to measure consistency (pass@k, pass^k)
