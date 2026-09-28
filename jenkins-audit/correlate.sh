#!/bin/bash
# Step 5: correlate one user's audit entries with Jenkins and system logs
# Usage: bash correlate.sh <username>
USER_NAME=${1:?Usage: bash correlate.sh <username>}
show() { # title file
  echo "== $1 =="
  if [ -r "$2" ]; then grep -h "$USER_NAME" "$2" | tail -n 10; else echo "(cannot read $2)"; fi
}
echo "== Audit entries for $USER_NAME =="
grep -h " by $USER_NAME" /var/lib/jenkins/audit-*.log 2>/dev/null | tail -n 10
show "Jenkins application log" /var/log/jenkins/jenkins.log
show "System auth log (ssh/sudo)" /var/log/auth.log
[ -r /var/log/nginx/access.log ] && show "Reverse proxy access log" /var/log/nginx/access.log
echo "Compare the timestamps across sections to confirm the same person/session."
