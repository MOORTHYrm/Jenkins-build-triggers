#!/bin/bash
# Optional env: DEV_USER/DEV_TOKEN (frontend-dev), JENKINS_USER/JENKINS_TOKEN (admin)
JENKINS_URL=${JENKINS_URL:-http://localhost:8080}

expect_denied() { # description curl-args...
  c=$(curl -s -o /dev/null -w "%{http_code}" "${@:2}")
  case "$c" in
    401|403|404) echo "PASS: $1 (HTTP $c)" ;;
    *)           echo "FAIL: $1 (HTTP $c)" ;;
  esac
}

# Step 1: anonymous access blocked
expect_denied "Anonymous API blocked" "$JENKINS_URL/api/json"
# Step 4: script console restricted
expect_denied "Anonymous script console blocked" "$JENKINS_URL/script"

if [ -n "$DEV_USER" ] && [ -n "$DEV_TOKEN" ]; then
  expect_denied "Developer script console blocked" -u "$DEV_USER:$DEV_TOKEN" "$JENKINS_URL/script"
  # Step 3: folder isolation (frontend-dev must not see backend)
  expect_denied "frontend-dev blocked from backend folder" -u "$DEV_USER:$DEV_TOKEN" "$JENKINS_URL/job/backend/api/json"
fi

# Step 5: built-in node has 0 executors
if [ -n "$JENKINS_USER" ] && [ -n "$JENKINS_TOKEN" ]; then
  n=$(curl -s -u "$JENKINS_USER:$JENKINS_TOKEN" "$JENKINS_URL/computer/api/json?tree=computer[numExecutors]" | grep -o '"numExecutors":[0-9]*' | head -1 | cut -d: -f2)
  if [ "$n" = "0" ]; then echo "PASS: Built-in node executors = 0"; else echo "FAIL: Built-in node executors = $n"; fi
fi
