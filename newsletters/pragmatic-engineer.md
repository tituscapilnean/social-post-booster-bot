---
newsletter: The Pragmatic Engineer
sender: pragmaticengineer@substack.com
subject: DHH's new way of writing code
date: 2026-04-08
message_id: 19d6e1a8d0134e1c
---

Interview with DHH (creator of Ruby on Rails, CTO of 37signals/Basecamp/HEY) about his shift to agent-first development.

**The shift:**
- 6 months ago on Lex Fridman podcast: didn't use AI, typed all code by hand
- Now: agent-first approach, barely writes code by hand
- Inflection point was shift from tab-completion to agent harnesses + models like Opus 4.5

**DHH's current workflow:**
- Runs tmux with two models: one fast (Gemini 2.5) in one split, one powerful (Opus) in another
- NeoVim in center for reviewing diffs via Lazygit
- Describes it as "wearing a mech suit" -- NOT project management of agents

**Key observations:**
- "A big win from using AI agents is tackling stuff that you wouldn't have before" -- a senior 37signals engineer optimized P1 requests from 4ms to under 0.5ms, work that wouldn't have been considered previously
- Senior engineers benefit far more than juniors. Amazon no longer lets junior programmers ship agent-generated code to production without review
- 37signals: 20 engineers, 10 designers (1:2 ratio). Designers also serve as PMs and builders
- AI agents could make 37signals' designer-builder model the industry standard
- CLIs are the ultimate AI interface -- validates Unix philosophy of the 1970s. Agents can chain tools: check errors, write fix, post PR, report to Basecamp
- Shape Up (2019 methodology for 2-month product cycles) now needs rewriting -- AI acceleration made that timeline slow
- Ruby on Rails experiencing a Renaissance: token-efficient, testing built-in, human-readable output
- 8 hours of sleep non-negotiable even during AI gold rush -- dopamine loop of shipping with agents risks burnout

**Quotes:**
- Re: beautiful code: "When something is beautiful, it's likely to be correct."
- Shape Up methodology: now obsolete because AI acceleration has made 2-month cycles feel slow
