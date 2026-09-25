# Dynamic Agents Demo (Docker-based)

Demonstrates a **dynamic agent**: instead of a permanently-connected static
agent (see `static-agents-demo/` in this repo), Jenkins creates a fresh
Docker container per build and destroys it automatically once the
pipeline finishes.

---

## Static vs. Dynamic — quick comparison

| | Static Agent | Dynamic Agent |
|---|---|---|
| Lifecycle | Set up once, stays running | Created per-build, destroyed after |
| Resource cost | Always consuming resources, even idle | Only costs resources while building |
| Environment | Can accumulate leftover state | Always fresh/clean |
| Setup | Manual node registration (Manage Jenkins → Nodes) | Declared directly in the Jenkinsfile |

---

## Step 1 — Prerequisites

1. Docker installed and running on the machine Jenkins/its agent can reach
2. Manage Jenkins → Plugins → Available plugins → search **"Docker Pipeline"** → install
3. No separate node registration needed — unlike static agents, this one is
   declared entirely inside the Jenkinsfile below.

---

## Step 2 — This Jenkinsfile

```groovy
pipeline {
    agent {
        docker {
            image 'node:18-alpine'
        }
    }
    stages {
        stage('Checkout') {
            steps { checkout scm }
        }
        stage('Confirm Agent') {
            steps {
                echo "Running on: ${env.NODE_NAME}"
                sh 'node --version'
                sh 'uname -a'
            }
        }
    }
}
```

**What happens when it runs:**
1. Jenkins pulls the `node:18-alpine` image (if not already cached locally)
2. Starts a brand-new container from that image
3. Runs every stage **inside** that container — `node --version` works even
   if the Jenkins host itself has no Node.js installed
4. Once finished, Jenkins automatically stops and removes the container
5. The next build gets a completely fresh container — no leftover state

---

## Step 3 — Jenkins job setup

1. New Item → name: `dynamic-agents-demo` → Pipeline → OK
2. Configure → Pipeline → Definition: **Pipeline script from SCM**
3. Repository URL:
   ```
   https://github.com/MOORTHYrm/Jenkins-build-triggers.git
   ```
4. Branch Specifier: `*/main`
5. Script Path: `dynamic-agents-demo/Jenkinsfile`

   ⚠️ Must be capital `Jenkinsfile`, not `jenkinsfile`.

6. Save → Build Now

---

## Step 4 — Verify it worked

Console Output should show:
- Docker pulling/using the `node:18-alpine` image
- A real Node.js version number from `node --version`
- The container being torn down after the build completes

Unlike the static agent demo, you will **not** see this agent listed under
Manage Jenkins → Nodes as a persistent entry — it only exists for the
duration of the build.

---

## Kubernetes alternative (for larger/cloud setups)

Instead of Docker directly, larger setups often use the **Kubernetes
plugin** so dynamic agents run as pods in a cluster:

1. Manage Jenkins → Plugins → install **Kubernetes**
2. Manage Jenkins → Clouds → Add a new cloud → Kubernetes
3. Enter your cluster's API server URL and credentials
4. Configure a Pod Template with a label (e.g. `k8s-node-builder`)
5. Reference it in a Jenkinsfile:
   ```groovy
   pipeline {
       agent { label 'k8s-node-builder' }
       stages {
           stage('Build') {
               steps { sh 'node --version' }
           }
       }
   }
   ```

## Common issues

| Symptom | Cause |
|---|---|
| `docker: not found` / connection refused | Docker isn't installed or the daemon isn't reachable from Jenkins |
| `No such DSL method 'docker'` in agent block | Docker Pipeline plugin isn't installed |
| Build hangs pulling the image | No internet access to Docker Hub, or image name typo |
| `Unable to find .../Jenkinsfile` | Filename case mismatch — must be `Jenkinsfile` |

## Related demos in this repo

- `static-agents-demo/` — the permanent-agent counterpart to this demo

