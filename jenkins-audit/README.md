# Jenkins Audit Logging Demo

## What it is
The Audit Trail plugin records who did what in Jenkins (config changes,
deletes, builds, credential changes). These files store, ship, alert on,
and correlate that trail.

| Step | What | Simple use case |
|------|------|-----------------|
| 1 | Install Audit Trail plugin | A job is deleted at 2 AM. Jenkins alone can't say who did it; the audit log can. |
| 2 | Sample audit log entry | Read who, what, and when for a config change in one line. |
| 3 | Ship logs to a SIEM | An attacker wipes local logs; the central copy survives, and security can search all Jenkins servers in one place. |
| 4 | Alert on high-risk events | Someone touches credentials or the script console, and the team is told within minutes. |
| 5 | Correlate with system/access logs | "Job deleted by moorthy": was it really him? Check the ssh/auth log at the same time. |

## Files
- `show-audit.sh`: prints the latest audit entries (Step 2).
- `ship-to-siem.sh`: rsyslog forwarding to a SIEM or syslog receiver (Step 3).
- `alert-high-risk.sh`: fails the build if high-risk events are found (Step 4).
- `correlate.sh`: joins one user's audit, Jenkins, and system log lines (Step 5).

## Sample audit entry (illustrative, format varies by plugin version)
    Sep 15, 2026 9:15:32 PM  job/demo-webhook/configSubmit  by moorthy

## Local test for Step 3
    nc -u -l 5514
    SIEM_HOST=127.0.0.1 SIEM_PORT=5514 sudo -E bash jenkins-audit/ship-to-siem.sh

## Notes
- The audit log records user and action, not the client IP. Use a reverse
  proxy access log for IPs.
- Reading `/var/log/auth.log` needs the `adm` group for the reader.
- Audit logs can contain sensitive job names. Restrict access and never
  commit log files to GitHub.
- Never commit Slack webhooks or tokens. Store them as Jenkins credentials.
