# Jenkins Security Hardening Demo

## What it is
Five steps that move Jenkins from "everyone can do everything" to least privilege.

| Step | What | Why |
|------|------|-----|
| 1 | Enable Matrix or Role-Based authorization | Turns off anonymous and open access |
| 2 | Define roles by function (admin, devops, developer, viewer) | Permissions follow job function |
| 3 | Folder isolation (frontend/, backend/) | Teams only see their own jobs |
| 4 | Restrict Script Console and CLI | Both are full remote code execution for admins |
| 5 | Agent-to-controller security | Builds run on agents, not on the controller |

## Files
- `setup-roles.sh`: creates roles (Step 2) and folder item roles (Step 3), then assigns them.
- `verify-security.sh`: PASS/FAIL checks for Steps 1, 3, 4 and 5.

## Usage
    export JENKINS_USER=<admin-user>
    read -s -p "Jenkins API token: " JENKINS_TOKEN && export JENKINS_TOKEN
    bash jenkins-security/setup-roles.sh
    bash jenkins-security/verify-security.sh

## Key rules
- Give Overall/Administer (script console, credentials, plugins) to admin only.
- Keep the global `developer` role minimal (Overall/Read only). Job permissions
  come from folder item roles, so teams stay isolated.
- Item role patterns match the full job name. Use `frontend(/.*)?` so the folder
  itself is visible, not just its jobs.
- Set built-in node executors to 0 only after at least one agent exists.
- Never commit API tokens or passwords. Pass them as environment variables.
