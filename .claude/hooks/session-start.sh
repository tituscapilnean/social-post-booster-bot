#!/bin/bash
set -euo pipefail

# Only run in remote Claude Code on the web sessions
if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

# Ensure the drafts output directory exists
mkdir -p "$CLAUDE_PROJECT_DIR/drafts"

echo "Session start hook complete."
