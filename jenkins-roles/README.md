# Jenkins Role Creation Demo (Role-based Authorization Strategy)

## What it is
The Role-based Authorization Strategy plugin lets you define roles
(sets of permissions) and assign them to users, instead of giving
everyone full access.

- Global role: applies to all of Jenkins (example: `viewer`)
- Project role: applies to jobs matching a name pattern (example:
  `demo-developer` on `demo-.*`)

## Files
- `create-roles.sh`: creates both roles and assigns them to `demo-dev`
  using the plugin's REST API.

## Usage
    JENKINS_USER=<admin-user> JENKINS_TOKEN=<api-token> bash jenkins-roles/create-roles.sh

## Expected result
- Manage Jenkins > Manage and Assign Roles > Manage Roles shows
  `viewer` (global) and `demo-developer` (project, pattern `demo-.*`).
- Logging in as `demo-dev` shows jobs named `demo-*` with a Build Now
  button, and no Manage Jenkins menu.

## Notes
- Assign your admin user to an admin role BEFORE enabling the strategy,
  or you can lock yourself out.
- Never commit API tokens or passwords. Pass them as environment variables.
- Use the principle of least privilege: give only the permissions needed.
