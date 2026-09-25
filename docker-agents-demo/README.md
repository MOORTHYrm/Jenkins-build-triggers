# Docker Agents Demo (declarative `agent { docker { } }`)

Demonstrates the declarative **Docker Agent** directive — the simplest way
to run an entire pipeline inside a pre-built public Docker image, without
writing a Dockerfile or using the lower-level Groovy `docker.build()` /
`.inside{}` API.

---

## Docker Agents vs. Docker Pipeline — quick comparison

| | `docker-agents-demo/` (this one) | `docker-pipeline-demo/` |
|---|---|---|
| Directive | `agent { docker { image '...' } }` | `docker.build()` + `.inside {}` (Groovy) |
| Image source | Pulls a pre-built public/registry image | Builds a custom image from your own Dockerfile |
| Complexity | Simple, declarative, one block | More control, more code |
| Best for | "Just run this on image X" | Custom images with your own build steps baked in |

---

## Step 1 — Prerequisites

1. **Docker Pipeline** plugin installed (same plugin used by `docker-pipeline-demo/`)
2. A Docker-capable agent — this demo targets label `aws-linux` (the EC2
   SSH agent set up earlier in this repo's history); change the label to
   match whatever Docker-capable agent you have.

---

## Step 2 — This Jenkinsfile

```groovy
pipeline {
    agent {
        docker {
            image 'python:3.12-alpine'
            label 'aws-linux'
        }
    }
    stages {
        stage('Checkout') {
            steps { checkout scm }
        }
        stage('Confirm Docker Agent') {
            steps {
                echo "Running on: ${env.NODE_NAME}"
                sh 'python3 --version'
            }
        }
    }
}
```

**What happens:** Jenkins pulls `python:3.12-alpine` directly from Docker
Hub and runs the entire pipeline inside a container from that image, on
whatever host matches the `aws-linux` label. `python3 --version` works
even though the underlying host itself has no Python installed — the
image provides it.

---

## Step 3 — Jenkins job setup

1. New Item → name: `docker-agents-demo` → Pipeline → OK
2. Configure → Pipeline → Definition: **Pipeline script from SCM**
3. Repository URL:
   ```
   https://github.com/MOORTHYrm/Jenkins-build-triggers.git
   ```
4. Branch Specifier: `*/main`
5. Script Path: `docker-agents-demo/Jenkinsfile`

   ⚠️ Must be capital `Jenkinsfile`, not `jenkinsfile`.

6. Save → Build Now

---

## Step 4 — Verify it worked

Console Output should show:
- Docker pulling `python:3.12-alpine` (if not already cached)
- A real Python version number printed from `python3 --version`
- No Dockerfile, no `docker.build()` call anywhere — just the image pulled and used directly

---

## `docker { }` agent options

| Option | What it does |
|---|---|
| `image` | The Docker image to run the pipeline inside |
| `label` | Which Jenkins node/agent should run this (must have Docker access) |
| `args` | Extra arguments passed to `docker run` (e.g. volume mounts) |
| `registryUrl` / `registryCredentialsId` | Pull from a private registry instead of Docker Hub |
| `reuseNode true` | Run inside the container on the *same* workspace/node already allocated by an outer `agent`, instead of allocating a new one |

## Use cases

1. **Language version pinning** — guarantee a build always uses exactly `python:3.12` or `node:18`, regardless of what's installed on the host
2. **No host setup needed** — run builds requiring tools (Python, Node, Go, etc.) on agents that don't have them natively installed
3. **Consistent environments across teams** — everyone's pipeline uses the exact same image tag, avoiding "works on my machine" drift
4. **Quick multi-language pipelines** — different stages can each use a different language's image without needing one agent with everything installed
5. **Testing across versions** — easily swap `image 'python:3.11-alpine'` to `python:3.12-alpine` to test compatibility, with no host changes required
6. **Clean, disposable builds** — each run starts from a known-clean image state, no leftover files from previous builds

## Common issues

| Symptom | Cause |
|---|---|
| `permission denied ... docker.sock` | Agent user not in the `docker` group, or session not refreshed after being added (see `docker-pipeline-demo/README.md` for the fix) |
| Build hangs pulling the image | No internet access from the agent, or image name typo |
| `Unable to find .../Jenkinsfile` | Filename case mismatch — must be `Jenkinsfile` |

## Related demos in this repo

- `docker-pipeline-demo/` — building and using a custom image via the Groovy API
- `dynamic-agents-demo/` — the original Docker dynamic agent demo (same underlying concept, `node:18-alpine`)
- `cloud-agents-demo/` — the real EC2 instance this demo's `aws-linux` label points at

