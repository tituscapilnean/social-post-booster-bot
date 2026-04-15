# evals-tools

A portable, language-agnostic eval framework for validating LLM prompts and agent behavior. Drop it into any repo to systematically test and improve your prompts.

Built on the principles from Anthropic's [Demystifying Evals for AI Agents](https://www.anthropic.com/engineering/demystifying-evals-for-ai-agents) guide.

## Quick start

```bash
# 1. Clone into your project
git clone <this-repo-url> evals-tools

# 2. Install dependencies
brew install yq jq  # macOS

# 3. Run the example suite
bash evals-tools/lib/runner.sh evals-tools/examples/prompt-quality/suite.yaml
```

You'll see output like:

```
============================================
  Eval Suite: prompt-quality
  Model: sonnet
  Trials per task: 3
  Run ID: 20260407_141254_prompt-quality
============================================

Found 2 task(s)

--- Task: tone_check_1 ---
  Response to a frustrated customer should be professional, empathetic, and actionable
  Trial 1/3...
    ✓ contains_apology (deterministic)
    ✓ contains_next_steps (deterministic)
    ✓ tone_and_quality (llm_judge)
  Trial 2/3...
    ...
```

Results are written to `results/<run-id>/summary.md`.

## How it works

1. You define **eval suites** in YAML — each suite has a set of **tasks**
2. Each task has a **prompt** and one or more **graders** that score the output
3. The runner sends each prompt to Claude via the `claude` CLI, then runs all graders
4. Each task runs multiple **trials** to measure consistency
5. Results are aggregated into a JSON file and a markdown summary

## Writing your first eval

### 1. Create a suite

```yaml
# evals/suite.yaml
name: "my-prompts"
description: "Validate my app's LLM prompts"
model: "sonnet"
trials_per_task: 3
tasks_dir: "./tasks"
```

### 2. Create a task

```yaml
# evals/tasks/summarize.yaml
id: "summarize_1"
description: "Summary should capture key points in 2-3 sentences"

prompt: |
  Summarize this article in 2-3 sentences:
  "The Federal Reserve held interest rates steady on Wednesday,
  signaling it expects to cut rates later this year as inflation
  continues to cool. Chair Powell noted the economy remains strong
  but acknowledged risks from global trade uncertainty."

graders:
  - type: deterministic
    name: "is_concise"
    command: |
      WORDS=$(echo "$OUTPUT" | wc -w)
      [ "$WORDS" -lt 80 ]
    expect_exit: 0

  - type: deterministic
    name: "mentions_fed"
    command: "echo \"$OUTPUT\" | grep -qiE '(federal reserve|fed|interest rate)'"
    expect_exit: 0

  - type: llm_judge
    name: "summary_quality"
    rubric: |
      Score 1-5 on each dimension:
      1. Accuracy: Does it capture the key facts?
      2. Conciseness: Is it 2-3 sentences without filler?
      3. Completeness: Does it mention rates, inflation, and outlook?

      Return JSON: {"scores": {"accuracy": N, "conciseness": N, "completeness": N}, "reasoning": "...", "pass": true/false}
      Pass if all scores >= 4.
```

### 3. Run it

```bash
bash evals-tools/lib/runner.sh evals/suite.yaml
```

## Grader types

### Deterministic

Runs a shell command. Passes if the exit code matches `expect_exit`. The model's output is available as `$OUTPUT`.

```yaml
- type: deterministic
  name: "contains_json"
  command: "echo \"$OUTPUT\" | jq . >/dev/null 2>&1"
  expect_exit: 0
```

Good for: keyword checks, format validation, length constraints, regex matching.

### LLM-as-judge

Sends the output to Claude with a rubric. Claude returns a JSON verdict.

```yaml
- type: llm_judge
  name: "tone_check"
  rubric: |
    Score 1-5: Is the tone professional and empathetic?
    Return JSON: {"score": N, "reasoning": "...", "pass": true/false}
    Pass if score >= 4.
```

Good for: tone, quality, reasoning, nuanced criteria that can't be captured by string matching.

### State check

Verifies the file system or environment after a task runs.

```yaml
# Check a file exists
- type: state_check
  name: "created_output"
  check: "file_exists"
  path: "./output/result.txt"

# Check file contents match a pattern
- type: state_check
  name: "correct_output"
  check: "file_contains"
  path: "./output/result.txt"
  pattern: "expected.*regex"

# Check a command succeeds
- type: state_check
  name: "tests_pass"
  check: "command"
  command: "npm test"
  expect_exit: 0
```

Good for: agent tasks that modify files, run commands, or change state.

## Metrics

Each task runs multiple trials. The summary reports three key metrics:

| Metric | What it measures | Use when |
|--------|-----------------|----------|
| **pass@1** | Success rate on a single attempt | Default quality signal |
| **pass@k** | Probability of at least 1 pass in k trials | Capability ceiling — "can it do this at all?" |
| **pass^k** | Probability of all k trials passing | Consistency — "can I rely on this in production?" |

At 1 trial, all three are identical. With more trials, pass@k goes up (easier) and pass^k goes down (harder).

## Task YAML reference

```yaml
id: "unique_task_id"          # Required. Unique within the suite.
description: "What this tests" # Required. Shown in output.
prompt: "The prompt text"      # Required. Sent to the model.
context_files:                 # Optional. Prepended to prompt.
  - "path/to/file.md"
tools:                         # Optional. Passed as --allowedTools.
  - "Read"
  - "Edit"
workdir: "."                   # Optional. Working directory for agent.
timeout: 120                   # Optional. Overrides suite default.
graders:                       # Required. At least one.
  - type: deterministic|llm_judge|state_check
    name: "grader_name"
    # ... type-specific fields
```

## Suite YAML reference

```yaml
name: "suite-name"             # Required.
description: "What this tests" # Required.
model: "sonnet"                # Required. sonnet, opus, or haiku.
trials_per_task: 3             # Optional. Default: 3.
tasks_dir: "./tasks"           # Required. Relative to suite file.
timeout: 120                   # Optional. Default: 120s.
claude_flags: ""               # Optional. Extra CLI flags.
```

## Adding to a repo

**Option A: Git submodule**
```bash
git submodule add <this-repo-url> evals-tools
```

**Option B: Clone directly**
```bash
git clone <this-repo-url> evals-tools
echo "evals-tools/" >> .gitignore
```

**Option C: Use the Claude Code slash command**
```bash
mkdir -p .claude/commands
ln -s ../../evals-tools/commands/eval.md .claude/commands/eval.md
# Now you can run /eval from Claude Code
```

## Project structure

```
evals-tools/
├── commands/
│   └── eval.md              # /eval slash command for Claude Code
├── lib/
│   ├── runner.sh            # Main eval orchestrator
│   ├── reporter.sh          # Results aggregation
│   └── graders/
│       ├── deterministic.sh # Shell command grader
│       ├── llm_judge.md     # LLM judge prompt reference
│       └── state_check.sh   # File/state verification grader
├── templates/
│   ├── suite.yaml           # Suite template — copy to start
│   └── task.yaml            # Task template — copy to start
├── examples/
│   └── prompt-quality/      # Working example suite
│       ├── suite.yaml
│       └── tasks/
│           ├── tone_check.yaml
│           └── tool_selection.yaml
└── results/                 # Generated output (gitignored)
```

## Dependencies

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) (`claude` CLI)
- [`yq`](https://github.com/mikefarah/yq) — YAML processing (`brew install yq`)
- [`jq`](https://jqlang.github.io/jq/) — JSON processing (`brew install jq`)

## Tips

- **Start small**: Begin with 5-10 tasks covering your most important prompts
- **Deterministic first**: Use string matching and regex before reaching for LLM judges — they're faster, cheaper, and more reproducible
- **Grade outcomes, not paths**: Don't penalize valid alternative approaches. Check *what* the model produced, not *how* it got there
- **Calibrate LLM judges**: Periodically read transcripts to verify the judge agrees with your own assessment
- **Graduate saturated evals**: When a task hits 100% pass rate, move it to a regression suite and add harder tasks
