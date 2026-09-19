# Jenkins Build Triggers Demo

This repo demonstrates four related Jenkins patterns:

1. Upstream job triggered remotely via API
2. Upstream → Downstream Freestyle job chaining
3. Pipeline chaining (Jenkinsfile-based)
4. Dependency management between jobs (Copy Artifact)

---

## 1. Upstream Job — Remote API Trigger

**Job:** `demo-api-trigger` (Freestyle)

Configuration:
- Source Code Management → Git → this repo, branch `*/main`
- Build Triggers → "Trigger builds remotely (e.g., from scripts)" → Token: `demo-secret-token`
- Build step (Execute shell): see `scripts/upstream-build-step.sh`

Trigger it:
```bash
curl -X POST -u moorthy:<YOUR_API_TOKEN> \
  "https://<your-jenkins-url>/job/demo-api-trigger/build?token=demo-secret-token"
```

Generate `<YOUR_API_TOKEN>` from Jenkins: username (top right) → Configure → API Token → Add new Token → Generate.

---

## 2. Downstream Job — Build After Other Projects

**Job:** `demo-downstream-job` (Freestyle)

Configuration:
- Build Triggers → "Build after other projects are built" → Projects to watch: `demo-api-trigger`
- Trigger option: "Trigger only if build is stable" (or "even if unstable" / "even if it fails" for rollback jobs)
- Build step (Execute shell): see `scripts/downstream-build-step.sh`

Once `demo-api-trigger` succeeds, this job fires automatically — no manual step needed.

---

## 3. Pipeline Chaining (Jenkinsfile)

**Job:** `demo-pipeline-upstream` (Pipeline, script from SCM → `Jenkinsfile` in repo root)
**Job:** `demo-pipeline-downstream` (Pipeline, script from SCM → `downstream/Jenkinsfile`)

The upstream `Jenkinsfile`'s `post { success { build job: 'demo-pipeline-downstream', wait: false } } }` block
automatically triggers the downstream pipeline — no UI checkbox needed, everything is defined as code.

Trigger the chain:
```bash
curl -X POST -u moorthy:<YOUR_API_TOKEN> \
  "https://<your-jenkins-url>/job/demo-pipeline-upstream/build?token=demo-secret-token"
```

---

## 4. Dependency Management (Copy Artifact)

**Job:** `demo-build-job` (Freestyle) — builds and archives `output/artifact.txt`
**Job:** `demo-consumer-job` (Freestyle) — copies that artifact and consumes it

Requires the **Copy Artifact** plugin (Manage Jenkins → Plugins → Available).

Configuration:
- `demo-build-job` → Execute shell: see `scripts/dependency-build-job.sh`
- `demo-build-job` → Post-build Actions → "Archive the artifacts" → `output/artifact.txt`
- `demo-consumer-job` → Build Triggers → "Build after other projects are built" → `demo-build-job`
- `demo-consumer-job` → Build step → "Copy artifacts from another project" → Project: `demo-build-job`,
  Which build: "Latest successful build", Artifacts: `output/artifact.txt`, Target: `dependencies/`
- `demo-consumer-job` → Execute shell: see `scripts/dependency-consumer-job.sh`

This demonstrates "build once, promote everywhere" — the consumer never rebuilds from source,
it only ever uses the exact artifact the build job produced.

---

## Repo layout

```
.
├── Jenkinsfile                       # upstream pipeline (demo-pipeline-upstream)
├── downstream/
│   └── Jenkinsfile                   # downstream pipeline (demo-pipeline-downstream)
├── scripts/
│   ├── upstream-build-step.sh        # demo-api-trigger build step
│   ├── downstream-build-step.sh      # demo-downstream-job build step
│   ├── dependency-build-job.sh       # demo-build-job build step
│   └── dependency-consumer-job.sh    # demo-consumer-job build step
└── README.md
```

## Notes

- `demo-secret-token` is a demo value only — replace it with a real secret before using this outside a sandbox.
- Store API tokens as Jenkins credentials, not hardcoded in scripts, for anything beyond a demo.
  to keep chained builds reproducible.
