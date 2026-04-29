---
newsletter: The Pragmatic Engineer
sender: pragmaticengineer@substack.com
subject: How will AI change operating systems? Part 1: Ubuntu and Linux
date: 2026-04-28
message_id: 19dd47dc0084926c
---

The Pragmatic Engineer interviews Jon Seager (VP Engineering, Canonical) on Ubuntu's AI strategy — a ground-level look at how the OS layer is responding to agentic and inference workloads.

**The hardware enablement thesis.** Canonical's core position: don't blur the line between application features and the OS itself. The most powerful contribution is hardware enablement — ensuring AI accelerators (GPUs, NPUs, DPUs) perform at their full potential when plugged into Ubuntu. If a machine has AI hardware, Ubuntu should unlock it without manual driver gymnastics.

**NVIDIA partnership.** Canonical now packages and distributes the full NVIDIA CUDA toolkit directly within Ubuntu's apt repositories — collapsing a multi-step manual installation (download, GPG keys, pinning a separate repo) into one standard command. NVIDIA discontinued its custom DGX OS and now ships plain Ubuntu. The DGX Spark ($4,000 AI workstation with ARM64 chipset) ships running vanilla Ubuntu as the only supported OS. Ubuntu 26.04 LTS announced day-one support for NVIDIA Vera Rubin NVL72 rack-scale architecture.

**AMD and Intel neutrality.** Ubuntu 26.04 LTS will be the first major distribution to natively package all three GPU compute stacks — NVIDIA CUDA, AMD ROCm, and Intel OpenVINO — with 15-year enterprise support under Ubuntu Pro.

**Architecture variant support.** Ubuntu now produces binaries for x86_64 v3 (and plans more variants including ARM v9, v10, v11, RISC-V RVA). Previously, all AMD64 builds compiled for v1 to maximize compatibility, leaving newer CPUs unable to use AVX-512 and other ML-accelerating instructions. Now users on v3-compatible processors get an OS variant that uses the silicon fully.

**Local-first and agentic workflow plans.** Focus on "inference snaps" for choosing the right model with the right quantization. Agentic workflow support at the OS level is at "early exploration stage" — Canonical is committed to it but has not shipped it. Engineering culture shift: skepticism about AI has given way to encouraged experimentation, with no targets for token usage or AI-generated code percentages.

**Other Linux distributions:** Arch takes DIY approach. Omarchy makes AI tool installation easy. Red Hat Enterprise Linux ships AI integrated into the CLI with support for AI accelerators and popular tools.

No competitor mentions flagged.
