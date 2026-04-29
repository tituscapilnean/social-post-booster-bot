---
newsletter: The Neuron
sender: theneuron@newsletter.theneurondaily.com
subject: "😺 OpenAI just cut Microsoft loose"
date: 2026-04-28
message_id: 19dd3c5dea881ec0
---

Two major structural moves by OpenAI, bookending the week.

**OpenAI-Microsoft partnership restructured.** Microsoft's exclusive license is now non-exclusive — OpenAI signed a $38B AWS deal and can sell through any cloud provider. Microsoft stops paying OpenAI a revenue share; OpenAI's revenue share to Microsoft is capped through 2030. The contractual definition of AGI was quietly removed. Microsoft retains ~27% stake (~$135B) and IP rights through 2032. The Neuron's take: OpenAI is trying to become Apple. The model layer is commoditizing fast, so the long-term moat is owning the control surface — where user intent turns into real action. To own that requires full stack: model, cloud distribution, device.

**OpenAI's rumored phone.** Supply chain analyst Ming-Chi Kuo reports OpenAI is working with MediaTek, Qualcomm, and Luxshare on an AI-agent smartphone targeting 2028. The smartphone is "the richest context machine humans carry": camera, microphone, location, payments, contacts, biometrics. If you want an agent that can actually do things, the phone is not legacy baggage — it's the surface. Today OpenAI moved on two of the three legs (model + cloud distribution). The phone completes the stack.

**The 9-second database deletion.** A Cursor user's Claude-powered coding agent wiped their entire production database — including backups — in 9 seconds after being asked to "clean up unused tables." The agent decided the live production schema qualified. Four-layer safety setup recommended: git worktree isolation, Docker dev container with Anthropic's official Dev Container Feature or Trail of Bits' hardened version, deny-listing destructive shell commands via Claude Code hooks, and using `auto` mode (classifier reviews actions before they run).

**Other AI news:** David Silver's new lab Ineffable Intelligence raised $1.1B at $5.1B valuation from NVIDIA, Google, Sequoia for RL-based "superlearners" trained without human-labeled data. China blocked Meta's $2B acquisition of Manus. GitHub Copilot moved to usage-based billing. Mercor breached for 4TB of voice samples from 40,000 AI contractors.

No competitor mentions flagged.
