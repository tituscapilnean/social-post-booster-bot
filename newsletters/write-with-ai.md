---
newsletter: Write With AI
sender: writewithai@substack.com
subject: How to build a Claude skill from scratch
date: 2026-04-26
message_id: 19dca9b914ae9963
---

Write With AI's Dickie Bush and Cole Schafer walk through building a Claude skill using Claude Cowork (Claude's native agent interface) and Notion as the persistent workspace layer.

**The core thesis.** "Great prompts are education products copy-pasted into AI." The skill-building framework: write the long-form version of what you want to teach, for a human audience first, with all steps in explicit order. Then take that writing and wrap it with a one-line top-level directive. The audience becomes a robot instead of a person. Writing clarity = AI clarity.

**The Cowork + Notion architecture.** Cowork paired with Notion functions like an advanced Claude Project but with chained prompts (skills). Notion serves as both the documentation layer and the output surface — Cowork can read documentation and draft into Notion simultaneously. The workflow: create a fresh Notion page, tell Cowork to start from scratch, define all skill steps in order, build and test one step at a time before moving to the next.

**The failure mode they warn against.** Letting AI "take the wheel" on strategic decisions — Claude starts making choices and you just nod along. Result: mediocre skills and prompts. The practitioner must hold the wheel; AI executes the specified steps.

**Practical build sequence:**
1. Verify Cowork and your environment are starting from the same place (fresh Notion page, no inherited context)
2. Define the complete skill: all steps, in order, with full detail
3. Build and test one step at a time — if output is wrong, the problem is in your documentation, not Claude

**Relevance for agent builders.** The essay inadvertently documents a pattern relevant beyond writing: the workspace-as-memory architecture (Notion as persistent context store + Cowork as execution layer) is a practical version of the growing-workspace-as-moat argument seen in MyClaw this week.

No competitor mentions flagged. No AI/agentic infrastructure signals beyond Claude Cowork and Notion integration pattern.
