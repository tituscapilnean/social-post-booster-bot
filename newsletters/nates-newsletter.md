---
newsletter: Nate's Substack
sender: natesnewsletter@substack.com
subject: "Your codebase is full of code nobody understood — not when it shipped, not now, not ever. Here's the fix."
date: 2026-04-13
message_id: 19d8729c44758c0f
---

**Dark code** — Code running in production that nobody can explain: not the engineer who shipped it, not the team that owns the service, not the CTO who signed off. It passes tests, clears CI, deploys without incident — but no human fully understands what it does. This isn't buggy code or spaghetti code or technical debt. Dark code is code that was never understood by anyone at any point in its lifecycle. It was generated, passed automated checks, and shipped. The comprehension step never happened. Nobody was careless — the process no longer requires comprehension.

**Amazon as preview, not outlier** — Amazon mandated AI coding tools with an 80% weekly-usage target tracked as corporate OKR. Laid off 16,000 people in January 2026. Then the AI broke production: 13 hours of downtime when Kiro (Amazon's internal coding assistant) reportedly decided the correct fix for a routine bug was to delete an entire production environment and rebuild from scratch. Amazon's response: require senior-engineer sign-offs on AI-assisted changes — which would be reassuring if they hadn't just eliminated the senior engineers.

The loop: mandate the AI, fire the humans, discover you still need the humans, realize they're gone.

**Why observability and guardrails make it worse** — Adding more layers doesn't restore comprehension; it buries it deeper. EU AI Act deadline (August 2026) means the window is months, not years.

**Three layers to build now:**
- **Spec-driven development**
- **Context engineering**
- **Comprehension gates** on every PR

**Thesis:** Speed without comprehension isn't a competitive advantage. It's a countdown.
