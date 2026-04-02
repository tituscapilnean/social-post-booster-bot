#!/usr/bin/env bash
# Post a tweet using X API v2 with OAuth 2.0 user token
# Usage: echo "tweet text" | ./scripts/post-x.sh
#    or: ./scripts/post-x.sh "tweet text"

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../.env"

if [[ -z "${X_USER_ACCESS_TOKEN:-}" ]]; then
  echo "Error: X_USER_ACCESS_TOKEN is not set in .env (run ./scripts/x-auth.sh first)" >&2
  exit 1
fi

if [[ $# -gt 0 ]]; then
  TEXT="$1"
else
  TEXT="$(cat)"
fi

if [[ -z "$TEXT" ]]; then
  echo "Error: No tweet text provided" >&2
  exit 1
fi

BODY=$(python3 -c "import json,sys; print(json.dumps({'text': sys.stdin.read().strip()}))" <<< "$TEXT")

RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "https://api.x.com/2/tweets" \
  -H "Authorization: Bearer $X_USER_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d "$BODY")

HTTP_CODE=$(echo "$RESPONSE" | tail -1)
RESP_BODY=$(echo "$RESPONSE" | sed '$d')

if [[ "$HTTP_CODE" == "201" ]]; then
  TWEET_ID=$(echo "$RESP_BODY" | python3 -c "import json,sys; print(json.loads(sys.stdin.read())['data']['id'])")
  echo "Posted: https://x.com/i/status/$TWEET_ID"
else
  echo "Error ($HTTP_CODE): $RESP_BODY" >&2
  exit 1
fi
