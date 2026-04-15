# LLM-as-Judge Grader Prompt Template

This file documents the prompt structure used by the runner when invoking the LLM judge grader. The runner constructs this dynamically — this file is a reference.

## Prompt Structure

```
You are an eval grader. Grade this LLM output against the rubric.

TASK: {task_description}

RUBRIC:
{rubric_from_task_yaml}

OUTPUT TO GRADE:
{model_output}

Respond with ONLY valid JSON: {"scores": {...}, "reasoning": "...", "pass": true/false}
```

## Writing Good Rubrics

In your task YAML `graders[].rubric` field:

1. **Be specific about dimensions**: Name each scoring dimension explicitly
2. **Define the scale**: e.g., "Score 1-5 where 1=poor, 5=excellent"
3. **Set the pass threshold**: e.g., "Pass if all scores >= 4"
4. **Include examples** of passing vs failing responses when helpful
5. **Grade outcomes, not paths**: Don't penalize valid alternative approaches

## Example Rubrics

### Output Quality
```yaml
rubric: |
  Score 1-5 on each dimension:
  - Accuracy: Are all claims factually correct?
  - Completeness: Are all requested elements present?
  - Clarity: Is the response well-organized and clear?
  Pass if all scores >= 4.
```

### Tone & Style
```yaml
rubric: |
  Score 1-5 on each dimension:
  - Professionalism: Appropriate tone for business context?
  - Empathy: Does it acknowledge the user's situation?
  - Actionability: Are next steps clear?
  Pass if average score >= 4.
```

### Tool Selection
```yaml
rubric: |
  Evaluate whether the agent selected appropriate tools:
  - Did it use the minimum necessary tools? (1-5)
  - Were tool parameters correct? (1-5)
  - Was the tool sequence logical? (1-5)
  Pass if all scores >= 4.
```
