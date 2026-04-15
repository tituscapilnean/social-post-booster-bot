# evals/

Eval suite for the social post booster bot. Validates that generated LinkedIn and X posts pass Titus's style, voice, pillar, and competitor rules.

## Run

```bash
bash evals-tools/lib/runner.sh evals/social-post-quality/suite.yaml
```

Or via the Claude Code slash command (after symlinking):

```
/eval evals/social-post-quality/suite.yaml
```

Filter to a single task:
```bash
bash evals-tools/lib/runner.sh evals/social-post-quality/suite.yaml --task linkedin_style
```

## What's tested

| Task | What it checks |
|------|----------------|
| `linkedin_style` | Word count 200-350, no hashtags, no bullet points, no em dashes, no banned openings, no negative-then-positive constructions |
| `x_style` | Char count 400-600, multi-line, no hashtags, has @handle when companies named, no banned openings |
| `voice_quality` | Op-ed voice, hook quality, system-thinking, operator credibility, forward-looking close — judged against `golden-examples.md` |
| `pillar_alignment` | Hits 1-2 of the 3 pillars; lands in agent-builder / Civic-adjacent lane |
| `competitor_filter` | Never names blocked competitors (arcade.dev, composio, pipedream, smithery, etc.) favorably |

## Golden examples

`golden-examples.md` holds the engagement-pattern reference set:
- 6 LinkedIn posts hand-picked by Titus
- 5 X posts pulled from top agent-ecosystem voices via the X recent-search API

The X set should be refreshed periodically since the API only goes back ~7 days. To refresh:

```bash
for handle in alexalbert__ swyx simonw; do
  bash scripts/search-x.sh "from:$handle -is:reply -is:retweet"
done
```

Then update the X1-X5 entries in `golden-examples.md` with the highest-engagement posts.

## Results

Each run writes to `evals-tools/results/<run-id>/` (gitignored):
- `results.json` — full grader output for every trial
- `summary.md` — pass/fail table with pass@1, pass@k, pass^k metrics
- `transcripts/` — per-trial model output, useful for debugging failures

## Adding tasks

Copy `evals-tools/templates/task.yaml` into `evals/social-post-quality/tasks/` and customize. See the existing tasks for examples of deterministic + LLM-judge graders.
