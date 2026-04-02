#!/usr/bin/env bash
# Search recent tweets using X API v2 with Bearer token
# Usage: ./scripts/search-x.sh "AI agents agentic"

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../.env"

if [[ -z "${X_BEARER_TOKEN:-}" ]]; then
  echo "Error: X_BEARER_TOKEN is not set in .env" >&2
  exit 1
fi

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 \"search query\"" >&2
  exit 1
fi

QUERY=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$1'))")

curl -s "https://api.x.com/2/tweets/search/recent?query=$QUERY&max_results=10&tweet.fields=created_at,public_metrics,author_id" \
  -H "Authorization: Bearer $X_BEARER_TOKEN" | python3 -m json.tool
