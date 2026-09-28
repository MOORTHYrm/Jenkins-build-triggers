#!/bin/bash
# Usage: JENKINS_USER=<admin> JENKINS_TOKEN=<api-token> bash setup-roles.sh
JENKINS_URL=${JENKINS_URL:-http://localhost:8080}
: "${JENKINS_USER:?Set JENKINS_USER}"
: "${JENKINS_TOKEN:?Set JENKINS_TOKEN}"
AUTH="$JENKINS_USER:$JENKINS_TOKEN"
API="$JENKINS_URL/role-strategy/strategy"

add_role() { # type name permissions [pattern]
  curl -s -o /dev/null -u "$AUTH" -X POST "$API/addRole" \
    -d "type=$1" -d "roleName=$2" -d "permissionIds=$3" \
    -d "overwrite=true" -d "pattern=${4:-.*}"
  echo "Role added: $2"
}
assign() { # type role user
  curl -s -o /dev/null -u "$AUTH" -X POST "$API/assignUserRole" \
    -d "type=$1" -d "roleName=$2" -d "user=$3"
  echo "Assigned $2 to $3"
}

# Step 2: roles by function (global). Admin is created in the UI to avoid lockout.
add_role globalRoles devops "hudson.model.Hudson.Read,hudson.model.Item.Read,hudson.model.Item.Build,hudson.model.Item.Configure,hudson.model.Item.Create,hudson.model.Item.Cancel,hudson.model.Item.Workspace"
add_role globalRoles developer "hudson.model.Hudson.Read"
add_role globalRoles viewer "hudson.model.Hudson.Read,hudson.model.Item.Read"

# Step 3: folder isolation (item roles matched on the full job name)
add_role projectRoles frontend-team "hudson.model.Item.Read,hudson.model.Item.Build,hudson.model.Item.Cancel,hudson.model.Item.Workspace" "frontend(/.*)?"
add_role projectRoles backend-team "hudson.model.Item.Read,hudson.model.Item.Build,hudson.model.Item.Cancel,hudson.model.Item.Workspace" "backend(/.*)?"

assign globalRoles developer frontend-dev
assign globalRoles developer backend-dev
assign projectRoles frontend-team frontend-dev
assign projectRoles backend-team backend-dev
echo "Done"
