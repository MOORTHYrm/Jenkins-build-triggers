#!/bin/bash
# Step 2: show the latest audit log entries
LOG=$(ls -t /var/lib/jenkins/audit-*.log 2>/dev/null | head -1)
[ -z "$LOG" ] && { echo "No audit log found. Complete Step 1 first."; exit 1; }
echo "Latest audit log: $LOG"
echo "---- last 5 entries ----"
tail -n 5 "$LOG"
echo "---- how to read an entry ----"
echo "<timestamp>  <action or URL>  by <user>"
