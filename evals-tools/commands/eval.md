# /eval — Run an eval suite against your LLM prompts

Run this command to execute an eval suite and validate your prompts/agent behavior.

## Usage

```
/eval <path-to-suite.yaml>
/eval examples/prompt-quality/suite.yaml
```

## Instructions

When the user invokes `/eval`, follow these steps:

### 1. Locate the suite file

The argument is a path to a suite YAML file. If no argument is provided, look for `evals/suite.yaml` or `evals/**/suite.yaml` in the current repo.

### 2. Validate dependencies

Run this check before proceeding:
```bash
for cmd in yq jq; do command -v "$cmd" &>/dev/null || echo "Missing: $cmd"; done
```

If `yq` is missing, tell the user: `brew install yq` (macOS) or `pip install yq` (other).

### 3. Run the eval suite

Execute the runner:
```bash
bash <evals-tools-path>/lib/runner.sh <suite-file>
```

Where `<evals-tools-path>` is the directory containing this eval tool (the parent of the `commands/` directory).

### 4. Display results

After the runner completes:

1. Read the generated `summary.md` file and display it to the user
2. Highlight any **FAIL** or **PARTIAL** tasks
3. For failed tasks, read the relevant transcript files and provide a brief analysis of what went wrong
4. Suggest specific prompt improvements based on the failure patterns

### 5. Suggest next steps

Based on the results:
- If all tasks pass: "Your prompts look solid. Consider adding harder tasks or graduating these to regression tests."
- If some fail: Identify patterns in failures and suggest targeted prompt edits.
- If most fail: Suggest reviewing the task definitions for ambiguity before changing prompts.

## Creating new eval suites

If the user wants to create a new eval suite, help them by:
1. Copying `templates/suite.yaml` and `templates/task.yaml` from the evals-tools directory
2. Customizing the task prompts and graders for their use case
3. Running the suite to validate it works
