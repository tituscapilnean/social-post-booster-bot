#!/usr/bin/env bash
# LinkedIn OAuth 2.0 token exchange
# Step 1: Run this script — it opens the browser for authorization
# Step 2: After you authorize, LinkedIn redirects to localhost with a code
# Step 3: The script exchanges the code for an access token
#
# Prerequisites:
#   1. Create app at https://www.linkedin.com/developers/apps
#   2. Add "Share on LinkedIn" product (grants w_member_social)
#   3. Set redirect URL to http://localhost:8642/callback
#   4. Fill LINKEDIN_CLIENT_ID and LINKEDIN_CLIENT_SECRET in .env

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../.env"

for var in LINKEDIN_CLIENT_ID LINKEDIN_CLIENT_SECRET; do
  if [[ -z "${!var:-}" ]]; then
    echo "Error: $var is not set in .env" >&2
    exit 1
  fi
done

REDIRECT_URI="http://127.0.0.1:8642/callback"
SCOPE="openid%20profile%20w_member_social"
STATE="$(openssl rand -hex 8)"

AUTH_URL="https://www.linkedin.com/oauth/v2/authorization?response_type=code&client_id=$LINKEDIN_CLIENT_ID&redirect_uri=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$REDIRECT_URI'))")&scope=$SCOPE&state=$STATE"

echo "Opening browser for LinkedIn authorization..."
open "$AUTH_URL"

echo ""
echo "Waiting for callback on http://localhost:8642 ..."
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

server = http.server.HTTPServer(('localhost', 8642), Handler)
server.handle_request()
")

CODE=$(echo "$CALLBACK" | grep "^CODE=" | cut -d= -f2)

if [[ -z "$CODE" ]]; then
  echo "Error: No authorization code received" >&2
  exit 1
fi

echo "Got authorization code. Exchanging for access token..."

TOKEN_RESPONSE=$(curl -s -X POST "https://www.linkedin.com/oauth/v2/accessToken" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  --data-urlencode "grant_type=authorization_code" \
  --data-urlencode "code=$CODE" \
  --data-urlencode "client_id=$LINKEDIN_CLIENT_ID" \
  --data-urlencode "client_secret=$LINKEDIN_CLIENT_SECRET" \
  --data-urlencode "redirect_uri=$REDIRECT_URI")

echo "Response: $TOKEN_RESPONSE"

ACCESS_TOKEN=$(echo "$TOKEN_RESPONSE" | python3 -c "import json,sys; d=json.loads(sys.stdin.read()); print(d.get('access_token',''))")

if [[ -z "$ACCESS_TOKEN" ]]; then
  echo "Error getting token. See response above." >&2
  exit 1
fi

echo "Got access token: ${ACCESS_TOKEN:0:10}..."

# Fetch Person URN
PROFILE=$(curl -s "https://api.linkedin.com/v2/userinfo" \
  -H "Authorization: Bearer $ACCESS_TOKEN")

PERSON_SUB=$(echo "$PROFILE" | python3 -c "import json,sys; print(json.loads(sys.stdin.read())['sub'])")
PERSON_URN="urn:li:person:$PERSON_SUB"

echo "Person URN: $PERSON_URN"
echo ""
echo "Add these to your .env:"
echo "LINKEDIN_ACCESS_TOKEN=$ACCESS_TOKEN"
echo "LINKEDIN_PERSON_URN=$PERSON_URN"
