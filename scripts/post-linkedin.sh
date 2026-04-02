#!/usr/bin/env bash
# Post to LinkedIn using UGC API
# Usage: echo "post text" | ./scripts/post-linkedin.sh
#    or: ./scripts/post-linkedin.sh "post text"

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../.env"

for var in LINKEDIN_ACCESS_TOKEN LINKEDIN_PERSON_URN; do
  if [[ -z "${!var:-}" ]]; then
    echo "Error: $var is not set in .env" >&2
    exit 1
  fi
done

if [[ $# -gt 0 ]]; then
  TEXT="$1"
else
  TEXT="$(cat)"
fi

if [[ -z "$TEXT" ]]; then
  echo "Error: No post text provided" >&2
  exit 1
fi

BODY=$(python3 -c "
import json, sys
text = sys.stdin.read().strip()
print(json.dumps({
    'author': '$LINKEDIN_PERSON_URN',
    'lifecycleState': 'PUBLISHED',
    'specificContent': {
        'com.linkedin.ugc.ShareContent': {
            'shareCommentary': {'text': text},
            'shareMediaCategory': 'NONE'
        }
    },
    'visibility': {
        'com.linkedin.ugc.MemberNetworkVisibility': 'PUBLIC'
    }
}))
" <<< "$TEXT")

RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "https://api.linkedin.com/v2/ugcPosts" \
  -H "Authorization: Bearer $LINKEDIN_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -H "X-Restli-Protocol-Version: 2.0.0" \
  -d "$BODY")

HTTP_CODE=$(echo "$RESPONSE" | tail -1)
RESP_BODY=$(echo "$RESPONSE" | sed '$d')

if [[ "$HTTP_CODE" == "201" ]]; then
  echo "Posted to LinkedIn successfully."
  echo "$RESP_BODY"
else
  echo "Error ($HTTP_CODE): $RESP_BODY" >&2
  exit 1
fi
