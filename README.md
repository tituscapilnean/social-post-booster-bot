# Social Post Booster Bot

A prompt-driven agent that generates daily LinkedIn and X posts from newsletter signals. No runtime, no build system — runs entirely inside [Claude Code](https://claude.ai/code) sessions.

## How it works

1. Fetches newsletters from Gmail (via [Civic](https://civic.com) MCP server)
2. Selects the most relevant signals about AI agents, agentic workflows, and infrastructure
3. Searches X for real-time context on the topic
4. Generates platform-specific posts (LinkedIn + X) following a defined style guide
5. Scores drafts on relevance, hotness, and engagement-worthiness before saving

The full 10-step workflow is defined in `CLAUDE.md`. Just open the repo in Claude Code and say "generate today's post".

## Repo structure

```
CLAUDE.md              # Agent instructions and workflow
config/
  style.md             # Voice, tone, and post structure rules
  pillars.md           # Communication pillars (every post must hit 1-2)
  competitors.md       # Companies to filter out of posts
drafts/
  YYYY-MM-DD.md        # Daily post drafts
scripts/
  x-auth.sh            # X OAuth 2.0 PKCE flow (saves tokens to .tokens)
  linkedin-auth.sh     # LinkedIn OAuth flow (saves tokens to .tokens)
  post-x.sh            # Post a tweet via X API v2
  post-linkedin.sh     # Post to LinkedIn via UGC API
  search-x.sh          # Search recent tweets via X API v2
```

## Setup

### Prerequisites

- [Claude Code](https://claude.ai/code) CLI or desktop app
- [Civic](https://civic.com) MCP server (profile: `social-media-toolkit`) for Gmail and Twitter tools
- X developer app with OAuth 2.0 enabled (callback: `http://localhost:8643/callback`)
- LinkedIn developer app with "Share on LinkedIn" product (callback: `http://localhost:8642/callback`)

### Credentials

1. Copy `.env.example` to `.env` and fill in your API keys, client IDs, and secrets
2. Run the auth scripts to generate OAuth tokens (saved automatically to `.tokens`):

```bash
./scripts/x-auth.sh
./scripts/linkedin-auth.sh
```

Both `.env` and `.tokens` are gitignored. The auth scripts preserve existing tokens from the other platform when regenerating.

## Usage

Open the repo in Claude Code and run:

```
generate today's post
```

The agent walks through the full workflow, asks for topic confirmation, generates drafts, and saves to `drafts/`. Posts are reviewed before publishing.

## License

MIT
