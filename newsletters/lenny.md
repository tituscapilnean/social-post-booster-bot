---
newsletter: Lenny's Newsletter (How I AI)
sender: lenny@substack.com
subject: "🎙️ This week on How I AI: How Intercom 2x'd their engineering velocity with Claude Code"
date: 2026-04-20
message_id: 19dab8799397660e
---

**Brian Scanlan (Senior Principal Engineer at Intercom) — how Intercom doubled engineering throughput in 9 months by going all-in on Claude Code.**

**Key numbers & context (from Brian's X posts):**
- 90% of pull requests at Intercom now authored by Claude Code.
- Internal Claude Code plugin system: 13 plugins, 100+ skills, hooks — turns Claude into a full-stack engineering platform.
- Des Traynor (Intercom founder): goal was 2x output in 1 year from June 2025. "Take it very, very seriously."
- Intercom official: shipped "Fin CLI for autonomous setup through your Agents."

**Core takeaways:**

1. **Treat your engineering org like a product — instrument everything.** Skill invocations tracked in Honeycomb. Anonymized Claude Code sessions stored in S3. Custom dashboards show engineers how they compare to peers. Not surveillance — same product thinking you'd apply to customer features. Can't improve what you don't measure; can't scale AI adoption without visibility into what's working and breaking.

2. **The 2x gain is real, but requires preparation.** Intercom doubled merged PRs per R&D employee in 9 months because they already had mature CI/CD, comprehensive test coverage, high-trust culture. AI magnifies strengths AND weaknesses. If your pipeline is broken or code review is manual chaos, AI just helps you ship broken code faster. Fix fundamentals first, then pour gasoline on the fire.

3. **Custom skills with hooks enforce quality at creation, not after.** Intercom's "Create PR" skill blocks Claude Code from using GitHub CLI directly and forces context-rich PR descriptions instead of regurgitating code. Make the golden path the only path.

4. **Code quality improves when you ship 2x faster because you finally have capacity for tech debt.** Stanford partnership shows quality metrics going UP. When fixing flaky tests, improving DX, tackling tech debt compresses to near-zero cost, you actually do those things instead of discussing in retros. Internal-project constraint disappears when agents execute in hours instead of quarters.

5. **The most important job of technical leadership in the AI era: give permission, take accountability.** Brian's framework: "Tell people they can do things, and if anything goes wrong, blame me." Engineers don't need more tutorials — they need permission to connect Claude Code to Snowflake, ship code from their phone on the subway, build a CLI that bypasses email verification. Activation energy is cultural, not technical.

6. **KEY FOR BUILDERS: Make your product agent-friendly or watch customers build it themselves.** Brian built an Intercom CLI that can autonomously sign up for Fin, verify email addresses by accessing Gmail, and complete installation without human intervention. "If you don't build this, your customers' agents will just brute-force your website, burn more tokens, get frustrated, and eventually press escape and build it themselves. The switching cost is literally one keystroke. Your conversion funnel is now invisible, and your drop-off point is 'forget it, let's do this a different way.'"

7. **All work will become agent-first. Set a deadline.** Brian's vision: by end of any given month, the first response to an alarm, planning meeting, or customer question should be an agent doing the basic work. Not aspirational — realistic given current models. Bottleneck is organizational willingness, not tech.

**Brian's workflows (public):**
- How Intercom Doubled Engineering Output: 4 Claude Code workflows
- Design an Agent-Friendly CLI to Automate SaaS Product Onboarding
- Build a Self-Improving AI Agent to Automatically Fix Flaky Tests
- Automate High-Quality Pull Request Descriptions with a Custom AI Skill
