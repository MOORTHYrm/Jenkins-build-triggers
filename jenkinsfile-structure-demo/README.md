# Jenkinsfile Structure Demo

This folder demonstrates the standard **Declarative Pipeline** structure —
the blocks Jenkins expects, in the order it expects them.

---

## The Blocks

| Block | Purpose |
|---|---|
| `agent` | WHERE the pipeline runs (which machine/label) |
| `environment` | Shared variables available to every stage |
| `options` | Pipeline-wide settings (timeouts, build retention, etc.) |
| `triggers` | What causes this to run automatically (cron, polling, etc.) |
| `stages` | WHAT the pipeline actually does — one or more `stage()` blocks, run in order |
| `post` | WHAT HAPPENS AFTER — success/failure/always cleanup and notifications |

---

## This Demo's Jenkinsfile

- `agent { label 'linux' }` — runs on an agent labeled `linux`
- `environment { REPORT_NAME = 'nightly-report' }` — one shared variable used across stages
- `options { timeout(time: 30, unit: 'MINUTES') }` — auto-kills the build if it hangs past 30 minutes
- `stages` — two stages: `Checkout` (pulls source) and `Generate Report` (prints report info)
- `post` — prints a different message depending on whether the build succeeded, failed, or just finished

---

## How to run this demo

1. In Jenkins: **New Item** → Name: `demo-jenkinsfile-structure` → **Pipeline** → OK
2. **Configure** → Pipeline → Definition: **Pipeline script from SCM**
3. SCM: **Git** → Repository URL:
   ```
   https://github.com/MOORTHYrm/Jenkins-build-triggers.git
   ```
4. Branch Specifier: `*/main`
5. Script Path:
   ```
   jenkinsfile-structure-demo/Jenkinsfile
   ```
6. Save → **Build Now**
7. Check **Console Output** — you'll see each stage run in order, followed by the matching `post` block message

---

## Use cases

- **Stage visibility** — Blue Ocean / Stage View shows exactly which named stage is running or failed
- **Automatic notifications** — `post { success / failure }` sends Slack/email alerts the moment the build finishes
- **Scheduled runs** — `triggers { cron(...) }` runs the pipeline automatically (e.g., nightly reports)
- **Environment-specific values** — `environment { }` can pull credentials or branch-based values for prod vs staging
- **Build limits** — `options { timeout(...) }` prevents a stuck build from blocking the queue
- **Guaranteed cleanup** — `post { always { ... } }` runs cleanup steps no matter the outcome

## Related demos in this repo

- `Jenkinsfile` — upstream pipeline (demo-pipeline-upstream)
- `downstream/Jenkinsfile` — downstream pipeline (demo-pipeline-downstream)
- `scripts/` — Freestyle job build step scripts (upstream trigger, downstream, dependency management)
- `scripted-pipeline-demo/` — Scripted Pipeline basics (Groovy data, node block)
- `jenkinsfile-structure-demo/` — this folder — standard Declarative Pipeline structure

