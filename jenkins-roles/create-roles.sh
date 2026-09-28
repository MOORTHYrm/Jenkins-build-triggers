#!/bin/bash
# Usage: JENKINS_USER=moorthy JENKINS_TOKEN=<api-token> bash create-roles.sh
JENKINS_URL=${JENKINS_URL:-http://localhost:8080}
: "${JENKINS_USER:?Set JENKINS_USER}"
: "${JENKINS_TOKEN:?Set JENKINS_TOKEN}"
API="$JENKINS_URL/role-strategy/strategy"

# Global role: can log in and see jobs
curl -s -u "$JENKINS_USER:$JENKINS_TOKEN" -X POST "$API/addRole" \
  -d "type=globalRoles" -d "roleName=viewer" \
  -d "permissionIds=hudson.model.Hudson.Read,hudson.model.Item.Read" \
  -d "overwrite=true"

# Project role: can build jobs whose name starts with demo-
curl -s -u "$JENKINS_USER:$JENKINS_TOKEN" -X POST "$API/addRole" \
  -d "type=projectRoles" -d "roleName=demo-developer" \
  -d "permissionIds=hudson.model.Item.Read,hudson.model.Item.Build,hudson.model.Item.Workspace" \
  -d "overwrite=true" -d "pattern=demo-.*"

# Assign both roles to the test user
for r in "globalRoles:viewer" "projectRoles:demo-developer"; do
  curl -s -u "$JENKINS_USER:$JENKINS_TOKEN" -X POST "$API/assignUserRole" \
    -d "type=${r%%:*}" -d "roleName=${r##*:}" -d "user=demo-dev"
done

echo "Roles created and assigned to demo-dev"
