---
newsletter: TheSequence
sender: thesequence@substack.com
subject: "The Sequence Knowledge #850: The Unexpected Comeback of RNNs"
date: 2026-04-28
message_id: 19dd4019cea9870d
---

TheSequence digs into the architectural renaissance happening below the hype layer: RNNs are coming back, and it matters for anyone building production inference infrastructure.

**The core problem with Transformers at scale.** The KV (Key-Value) cache makes Transformers an O(N^2) operation. At 100K, 1M, or multi-million token context windows, the compute graph "becomes mathematically offensive." The system burns vast amounts of high-bandwidth memory doing memory reads on every token in context. This is a hard infrastructure ceiling.

**The RNN comeback.** New-generation RNNs have larger states, data-dependent gating, and LLM-era training recipes. They are matching Transformer perplexity at scale while maintaining O(1) inference cost — constant memory footprint regardless of sequence length, regardless of context window. The original RNN advantage (fixed hidden state, throw the token away after updating) is exactly what makes inference infrastructure viable at long contexts.

**What this means for builders.** For anyone shipping agentic workflows with long context requirements — multi-hour agent runs, large codebases in context, extended reasoning chains — the memory and compute overhead of Transformer KV caches is a real cost center. New-generation recurrent architectures (the newsletter promises a series covering specific architectures) could fundamentally change the cost curve for long-context agentic inference.

**The benchmark parity claim** is the key data point: new-generation RNNs are matching Transformer perplexity at scale, not just on small benchmarks. If this holds at production scale, it represents a genuine alternative to the Transformer monoculture that has dominated since "Attention Is All You Need" (2017).

Newsletter is paywalled after the concept summary. No competitor mentions flagged. No specific named architectures listed in the accessible portion — the full breakdown is subscriber-only.
