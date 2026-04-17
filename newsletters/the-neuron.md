---
newsletter: The Neuron
sender: theneuron@newsletter.theneurondaily.com
subject: 😺 Opus 4.7 just made Claude more expensive
date: 2026-04-17
message_id: 19d9b1f13a87f342
---

**Headline: Opus 4.7 dropped. OpenAI overhauled Codex. Same day.**

**Claude Opus 4.7:**
- Same $5/$25 per MTok pricing as 4.6 — sticker price unchanged.
- Vision: 69.1% → 82.1% on benchmarks. Images up to 2,576 pixels on long edge (3x prior Claude).
- SWE-bench Pro: 53.4% → 64.3%. #1 on Vals AI Vibe Code Benchmark at 71%.
- **Hidden cost:** New tokenizer can use up to 35% more tokens for the same text. Combined with Claude Code's new `xhigh` effort default, Pro and Max users hit weekly caps faster unless they manually dial down. "A friend hit their weekly Max limit in basically one prompt."
- `xhigh` is the new Claude Code default (use `/effort` to step down).
- Web app gets adaptive thinking — Claude decides how long to think.

**Launch-day playbooks from Claude Code team (Boris Cherny, Cat Wu):**
Treat 4.7 like an engineer you're delegating to, not a pair programmer you guide line by line.
1. Front-load context (goal, constraints, acceptance criteria in turn 1).
2. Turn on auto mode (Shift+Tab) — safety classifier handles permission prompts, enables parallel Claudes.
3. Tell it how to verify its own work (2-3x quality multiplier). Put testing workflow in `claude.md` or install `/verify-app` skill.
4. `xhigh` is the new default — use `/effort` to step down on routine work.

**OpenAI Codex overhaul (same day):** Desktop app = full agent workstation. Mac-level computer use, in-app browser, persistent memory, automations that wake across days, 90+ plugins (Atlassian Rovo, CircleCI, Microsoft Suite). Free with ChatGPT account.

**CLAUDE.md nesting (AI Skill of the Day):** Taylor Pearson — Claude Code auto-loads CLAUDE.md from every parent directory. Structure: Global (~/CLAUDE.md) → Vault folder → Business folder → Project folder. Claude walks up the tree loading all four into first message. Run a `/wrap` routine end-of-session to update relevant CLAUDE.md files. Starter repo: `claudesidian`.

**Other beats:**
- Anthropic CPO Mike Krieger resigned from Figma's board same day reports surfaced Anthropic is shipping design software.
- Canva 2.0: rebranded as "an AI platform with design tools" at $42B IPO test.
- Qwen3.6-35B-A3B (35B sparse, 3B active) rivals Claude Sonnet 4.5 on vision. Simon Willison's laptop-local version drew a better pelican than Opus 4.7.
- Factory raised $150M from Khosla at $1.5B valuation for autonomous coding agents that switch between models by task complexity; Keith Rabois joined the board.
- OpenAI's chief economist published AI Jobs Transition Framework: 18% of 900+ occupations face higher near-term automation risk, 24% reorganize, 12% grow, 46% see less change.
- OpenAI launched GPT-Rosalind (life-sciences model) with Moderna, Amgen, Allen Institute, Thermo Fisher.
- White House preparing to give federal agencies access to Anthropic Mythos.
- Perplexity launched Personal Computer — Mac app reads/writes local files, drives iMessage, Mail, Calendar.

**Big read — Sequoia: "Services: The New Software":** Next $1T company sells the work, not the software. Autopilot opportunities mapped: insurance ($140-200B), accounting ($50-80B), tax advisory ($30-35B), recruitment ($200B+).

**Amazon AI agent canceled a webcomic creator's 15-year account + Prime + income from self-published books. No flag, no appeal, no human.** Another creator Tom Ray lost his per-page comics catalog back to 2018. "When an 800-pound gorilla outsources due process to a moderation LLM, losing one platform can mean losing a life's work."

**Takeaway:** Opus 4.7 is a better model AND a more expensive one, even with unchanged sticker prices. The people who get the most out of it follow the playbook. The rest pay the tokenizer tax.
