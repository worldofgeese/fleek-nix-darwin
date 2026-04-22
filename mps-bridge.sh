#!/usr/bin/env bash
set -euo pipefail

# --- Configuration ---
MPS_BASE_URL="${MPS_BASE_URL:-https://models.assistant.legogroup.io}"
MPS_API_KEY="${MPS_API_KEY:?Set MPS_API_KEY to your account_id:secret}"
MPS_MODEL="${MPS_MODEL:-anthropic.claude-opus-4-6-v1}"
MAX_TOKENS="${MPS_MAX_TOKENS:-8192}"

# Read the plain-text transcript from stdin
INPUT=$(cat)

# Parse the [system] / [user] / [assistant] blocks into Anthropic Messages JSON
SYSTEM_MSG=""
MESSAGES="[]"
CURRENT_ROLE=""
CURRENT_TEXT=""

flush_block() {
  if [ -n "$CURRENT_ROLE" ] && [ -n "$CURRENT_TEXT" ]; then
    # Trim leading/trailing whitespace
    CURRENT_TEXT=$(echo "$CURRENT_TEXT" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    if [ "$CURRENT_ROLE" = "system" ]; then
      SYSTEM_MSG="$CURRENT_TEXT"
    else
      MESSAGES=$(echo "$MESSAGES" | jq \
        --arg role "$CURRENT_ROLE" \
        --arg content "$CURRENT_TEXT" \
        '. + [{"role": $role, "content": $content}]')
    fi
  fi
  CURRENT_ROLE=""
  CURRENT_TEXT=""
}

while IFS= read -r line || [ -n "$line" ]; do
  case "$line" in
    \[system\])
      flush_block
      CURRENT_ROLE="system"
      ;;
    \[user\])
      flush_block
      CURRENT_ROLE="user"
      ;;
    \[assistant\])
      flush_block
      CURRENT_ROLE="assistant"
      ;;
    *)
      if [ -n "$CURRENT_ROLE" ]; then
        if [ -n "$CURRENT_TEXT" ]; then
          CURRENT_TEXT="$CURRENT_TEXT
$line"
        else
          CURRENT_TEXT="$line"
        fi
      fi
      ;;
  esac
done <<< "$INPUT"
flush_block

# Build the request body
BODY=$(jq -n \
  --arg model "$MPS_MODEL" \
  --argjson max_tokens "$MAX_TOKENS" \
  --arg system "$SYSTEM_MSG" \
  --argjson messages "$MESSAGES" \
  '{model: $model, max_tokens: $max_tokens, system: $system, messages: $messages}')

# Debug
echo "$BODY" > /tmp/mps-bridge-input.json

# POST to the MPS Claude endpoint
RESPONSE=$(curl -s -w "\n%{http_code}" \
  "${MPS_BASE_URL}/claude/v1/messages" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${MPS_API_KEY}" \
  -d "$BODY")

HTTP_CODE=$(echo "$RESPONSE" | tail -1)
RESP_BODY=$(echo "$RESPONSE" | sed '$d')

echo "$RESP_BODY" > /tmp/mps-bridge-response.json
echo "HTTP $HTTP_CODE" > /tmp/mps-bridge-status.txt

# Extract the assistant message content
echo "$RESP_BODY" | jq -r '.content[0].text // empty'