#!/bin/sh

# Check if Python 3 is installed
if ! command -v python3 >/dev/null 2>&1; then
  echo "Error: Python 3 is required but not installed." >&2
  exit 1
fi

escaped_google_credentials=$(echo "$GOOGLE_CREDENTIALS" | python3 -c 'import json, sys; input_str = sys.stdin.read().rstrip().replace("\\", "\\\\").replace("\n", "\\n"); print(json.dumps(input_str)[1:-1])')
cat <<EOF
{
  "PF_TOKEN": "$PF_TOKEN",
  "PF_ACCOUNT_ID": "$PF_ACCOUNT_ID",
  "PF_AWS_ACCOUNT_ID": "$PF_AWS_ACCOUNT_ID",
  "AWS_ACCESS_KEY_ID": "$AWS_ACCESS_KEY_ID",
  "AWS_SECRET_ACCESS_KEY": "$AWS_SECRET_ACCESS_KEY",
  "GOOGLE_CREDENTIALS": "$escaped_google_credentials"
}
EOF
