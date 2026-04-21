---
newsletter: Nate's Substack
sender: natesnewsletter@substack.com
subject: "Opus 4.7 migration: what broke, what it actually costs, and the one pattern that catches what both models miss"
date: 2026-04-21
message_id: 19db0292b9dc034a
---

Detailed Opus 4.7 migration analysis from 4 days of production testing vs GPT-5.4, plus Claude Design evaluation.

**What's Real in Opus 4.7**
Genuine capability gains in persistence, coding, vision, and knowledge work. But gains are NOT uniform — web research and terminal regressions worth routing around. The model became more literal: inference it previously did automatically (guessing what you meant) is now gone. Fix is clearer prompts, not longer ones.

**The Tokenizer Tax**
Bills went up even though sticker price didn't change. Three compounding factors: a tokenizer tax, adaptive thinking overhead, and breaking API changes that compound in ways headline pricing hides. Some workflows now cost measurably more per unit of output.

**Backlash and Praise Are Both Describing Real Things**
People treating this as one story will make the wrong migration call. Some will overpay for work that got cheaper. Others will downgrade away from the one model that actually got the hard stuff right. The combative, more literal behavior and the capability gains are separate engineering choices that shipped in the same release — they have separate fixes.

**Claude Design — The $42 Afternoon**
Nate spent an afternoon inside Claude Design. The design tool turns brand assets into machine-readable agent instructions. Correction loop reveals where Anthropic actually is vs. where the valuation says they should be. Useful but not fully realized — the feedback loop between intent and output still requires significant human iteration.

**Three Migration Prompts**
1. Pre-flight check: flags what breaks when switching from Opus 4.6 to 4.7
2. Cost estimator: quantifies the tokenizer tax on your specific usage patterns
3. Peer review workflow builder: adds the reliability layer that catches what both models miss

**Bottom Line for Builders**
Opus 4.7 is stronger on the hardest work. It's also more expensive per-unit even at the same list price, and more combative on ambiguous instructions. Don't treat migration as a toggle — audit which workloads genuinely need the new capabilities vs. which got cheaper to run on 4.6-class alternatives.
