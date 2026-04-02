#!/usr/bin/env bash
# X OAuth 2.0 PKCE authorization flow
# Grants user context access for posting tweets
#
# Prerequisites:
#   1. App at developer.x.com with OAuth 2.0 enabled
#   2. Set callback URL to http://localhost:8643/callback
#   3. Fill X_CLIENT_ID and X_CLIENT_SECRET in .env

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../.env"

for var in X_CLIENT_ID X_CLIENT_SECRET; do
  if [[ -z "${!var:-}" ]]; then
    echo "Error: $var is not set in .env" >&2
    exit 1
  fi
done

REDIRECT_URI="http://127.0.0.1:8643/callback"
SCOPE="tweet.read%20tweet.write%20users.read%20offline.access"
STATE="$(openssl rand -hex 8)"

# PKCE: generate code_verifier and code_challenge
CODE_VERIFIER="$(openssl rand -hex 32)"
CODE_CHALLENGE="$(printf '%s' "$CODE_VERIFIER" | openssl dgst -sha256 -binary | base64 | tr '+/' '-_' | tr -d '=')"

AUTH_URL="https://x.com/i/oauth2/authorize?response_type=code&client_id=$X_CLIENT_ID&redirect_uri=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$REDIRECT_URI'))")&scope=$SCOPE&state=$STATE&code_challenge=$CODE_CHALLENGE&code_challenge_method=S256"

echo "Opening browser for X authorization..."
open "$AUTH_URL"

echo ""
echo "Waiting for callback on http://localhost:8643 ..."
echo "(If the browser didn't open, visit this URL manually:)"
echo "$AUTH_URL"
echo ""

# Minimal HTTP server to catch the callback
CALLBACK=$(python3 -c "
import http.server, urllib.parse

class Handler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        params = urllib.parse.parse_qs(urllib.parse.urlparse(self.path).query)
        code = params.get('code', [''])[0]
        state = params.get('state', [''])[0]
        self.send_response(200)
        self.send_header('Content-Type', 'text/html')
        self.end_headers()
        self.wfile.write(b'<h1>Done! You can close this tab.</h1>')
        print(f'CODE={code}')
        print(f'STATE={state}')
    def log_message(self, *args):
        pass

server = http.server.HTTPServer(('localhost', 8643), Handler)
server.handle_request()
")

CODE=$(echo "$CALLBACK" | grep "^CODE=" | cut -d= -f2)

if [[ -z "$CODE" ]]; then
  echo "Error: No authorization code received" >&2
  exit 1
fi

echo "Got authorization code. Exchanging for access token..."

BASIC_AUTH=$(printf '%s:%s' "$X_CLIENT_ID" "$X_CLIENT_SECRET" | base64)

TOKEN_RESPONSE=$(curl -s -X POST "https://api.x.com/2/oauth2/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -H "Authorization: Basic $BASIC_AUTH" \
  -d "code=$CODE" \
  -d "grant_type=authorization_code" \
  -d "redirect_uri=$REDIRECT_URI" \
  -d "code_verifier=$CODE_VERIFIER")

ACCESS_TOKEN=$(echo "$TOKEN_RESPONSE" | python3 -c "import json,sys; d=json.loads(sys.stdin.read()); print(d.get('access_token',''))")
REFRESH_TOKEN=$(echo "$TOKEN_RESPONSE" | python3 -c "import json,sys; d=json.loads(sys.stdin.read()); print(d.get('refresh_token',''))")

if [[ -z "$ACCESS_TOKEN" ]]; then
  echo "Error getting token: $TOKEN_RESPONSE" >&2
  exit 1
fi

echo ""
echo "Success! Add these to your .env:"
echo "X_USER_ACCESS_TOKEN=$ACCESS_TOKEN"
echo "X_USER_REFRESH_TOKEN=$REFRESH_TOKEN"
