---
newsletter: AlphaSignal
sender: news@alphasignal.ai
subject: Anthropic Opus Advisor cuts agent costs 12% with auto-escalation
date: 2026-04-10
message_id: 19d7826af6fb539c
---

Daily AI briefing. Lead story: Anthropic ships the **advisor tool** in the Claude API.

**Advisor strategy (Anthropic):**
- New Messages API tool (`advisor_20260301`) lets a Sonnet or Haiku executor call Opus only when reasoning gets hard. Single API request, no external orchestration.
- Executor handles tools and outputs. Advisor reads shared context, returns a plan or correction, exits without producing user-visible responses.
- **Results:** SWE-bench Multilingual +2.7 points over Sonnet alone. Cost per task drops 11.9% vs Sonnet-only execution. **Haiku jumps from 19.7% to 41.2% on BrowseComp with advisor enabled.** Haiku setup remains 85% cheaper than Sonnet for comparable workloads.
- Anthropic also ships **Monitor tool**: Claude can run background scripts and wake on events.

**Other top news:**
- OpenAI launches $100/mo Pro tier with higher Codex limits, GPT-5.4 Pro reasoning model access, ~400K context window. Plus tier rebalanced toward steady weekly usage.
- Meta debuts **Neural Computer**: model trained on screen recordings, predicts next screen state and action. Encodes logic in weights instead of calling APIs/tools. Prototype fails on multi-step reasoning with dependencies.
- Anthropic exploring own AI chips. Project Rainier: 1GW Trainium2 cluster, ~500K chips, all latest Anthropic models trained on it. $8B Amazon commitment.
- Perplexity integrates Plaid for bank/credit/loan tracking. Cursor lets agents attach demos and screenshots to PRs. Augment Code hosts 90-min Vibe Code Cup.
