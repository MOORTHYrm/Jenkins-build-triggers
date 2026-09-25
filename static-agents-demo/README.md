# Static Agents Demo

Demonstrates a pipeline scheduled onto a **static (permanent) agent** by
label, instead of always running on the built-in controller node.

A static agent is a machine you set up once and leave connected — as
opposed to a dynamic/cloud agent that spins up on-demand and is destroyed
after use.

---

## Step 1 — Set up the static agent

1. On the machine that will become the agent: install **Java** (matching
   the major version your Jenkins controller requires).
2. In Jenkins: Manage Jenkins → Nodes → **New Node**
3. Node name: `linux-agent-1` → select **Permanent Agent** → Create
4. Configure:
   - **# of executors**: e.g. `2`
   - **Remote root directory**: e.g. `/home/moorthy/jenkins-agent`
   - **Labels**: `linux` (must match `agent { label 'linux' }` in the Jenkinsfile)
   - **Launch method**: "Launch agent by connecting it to the controller" (JNLP/WebSocket) — works well behind firewalls since the agent connects outbound
5. Save — Jenkins shows a command to run on the agent machine, e.g.:
   ```bash
   curl -sO http://localhost:8080/jnlpJars/agent.jar
   java -jar agent.jar -url http://localhost:8080/ -secret <SECRET> -name "linux-agent-1" -workDir "/home/moorthy/jenkins-agent"
   ```
6. Run that exact command on the agent machine.
7. Back in Manage Jenkins → Nodes → confirm `linux-agent-1` shows a green ✅ (online).

---

## Step 2 — This Jenkinsfile

```groovy
pipeline {
    agent { label 'linux' }
    stages {
        stage('Checkout') {
            steps { checkout scm }
        }
        stage('Confirm Agent') {
            steps {
                echo "Running on: ${env.NODE_NAME}"
                sh 'uname -a || echo "uname not available on this OS"'
            }
        }
    }
}
```

---

## Step 3 — Jenkins job setup

1. New Item → name: `static-agents-demo` → Pipeline → OK
2. Configure → Pipeline → Definition: **Pipeline script from SCM**
3. Repository URL:
   ```
   https://github.com/MOORTHYrm/Jenkins-build-triggers.git
   ```
4. Branch Specifier: `*/main`
5. Script Path: `static-agents-demo/Jenkinsfile`

   ⚠️ Must be capital `Jenkinsfile`, not `jenkinsfile`.

6. Save → Build Now

---

## Step 4 — Verify it actually ran on the static agent

Open Console Output. Compare:

| If you see | What it means |
|---|---|
| `Running on: Jenkins` | Still running on the built-in controller node — the `linux` agent either isn't set up, isn't labeled correctly, or isn't online |
| `Running on: linux-agent-1` | ✅ Correctly scheduled onto the static agent you set up |

---

## Common issues

| Symptom | Cause |
|---|---|
| Build stuck: "Still waiting to schedule task" | No agent currently online has the `linux` label |
| Agent shows red/offline in Manage Jenkins → Nodes | The `java -jar agent.jar ...` process isn't running, or lost connection |
| `Unable to find .../Jenkinsfile` | Filename case mismatch — must be `Jenkinsfile` |

## Related concepts in this repo

- `jenkinsfile-structure-demo/` — the `agent` block's role in overall pipeline structure
- `scripted-pipeline-demo/` — the `node('linux')` block in Scripted Pipeline, same underlying concept

