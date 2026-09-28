#!/bin/bash
# Step 4: fail the build (and optionally ping Slack) when high-risk events appear
WINDOW_LINES=${WINDOW_LINES:-200}
PATTERN='doDelete|credential|/script|scriptText|configSubmit|doWipeOutWorkspace|pluginManager|safeRestart|by anonymous'
LOG=$(ls -t /var/lib/jenkins/audit-*.log 2>/dev/null | head -1)
[ -z "$LOG" ] && { echo "No audit log found. Complete Step 1 first."; exit 1; }

HITS=$(tail -n "$WINDOW_LINES" "$LOG" | grep -E "$PATTERN")
if [ -n "$HITS" ]; then
  echo "ALERT: high-risk audit events found"
  echo "$HITS"
  if [ -n "$SLACK_WEBHOOK_URL" ]; then
    curl -s -X POST -H 'Content-type: application/json' \
      --data '{"text":"Jenkins: high-risk audit events detected"}' "$SLACK_WEBHOOK_URL" > /dev/null
  fi
  exit 1
fi
echo "OK: no high-risk events in the last $WINDOW_LINES entries"
