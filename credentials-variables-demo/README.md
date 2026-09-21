# Credentials Variables Demo

This folder shows how to use **Jenkins Credentials Manager** instead of
hardcoding secrets directly in a Jenkinsfile — replacing the plain-text
`demo-secret-token` used in this repo's earlier Freestyle/API-trigger demos
with a proper managed credential.

---

## Why this matters

Earlier demos in this repo (`Jenkinsfile`, `scripts/upstream-build-step.sh`)
use a hardcoded token value:

```
demo-secret-token
```

That's fine for a local sandbox, but in a real setup this should **never**
live in plain text in a Jenkinsfile or script — anyone with repo access can
read it, and it stays in Git history forever even if removed later.

---

## Step 1: Store the secret in Jenkins (one-time setup)

1. Manage Jenkins → Credentials → (select a domain, e.g. "Global") → Add Credentials
2. Kind: **Secret text**
3. Secret: paste your real token value
4. ID: `demo-api-token` (this exact ID is what the Jenkinsfiles below reference)
5. Save

---

## Step 2: Reference it in your pipeline

### Declarative (`Jenkinsfile`)

```groovy
pipeline {
    agent { label 'linux' }

    environment {
        API_TOKEN = credentials('demo-api-token')
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        stage('Use Credential') {
            steps {
                sh 'curl -s -X POST -H "Authorization: token $API_TOKEN" https://example.com/api/status || true'
            }
        }
    }
}
```

### Scripted (`Jenkinsfile.scripted`)

```groovy
node('linux') {
    stage('Checkout') {
        checkout scm
    }
    stage('Use Credential') {
        withCredentials([string(credentialsId: 'demo-api-token', variable: 'API_TOKEN')]) {
            sh 'curl -s -X POST -H "Authorization: token $API_TOKEN" https://example.com/api/status || true'
        }
    }
}
```

---

## How to run this demo

1. New Item → Pipeline → OK
2. Configure → Pipeline → Definition: **Pipeline script from SCM**
3. Repository URL:
   ```
   https://github.com/MOORTHYrm/Jenkins-build-triggers.git
   ```
4. Branch Specifier: `*/main`
5. Script Path: `credentials-variables-demo/Jenkinsfile` (or `Jenkinsfile.scripted` for the Scripted variant — set this job's Definition to reference that file if testing it instead)
6. Save → Build Now
7. Check Console Output — `$API_TOKEN` will show as `****` even though the real value was used in the `curl` command

---

## Common credential types

| Kind | Used for |
|---|---|
| Secret text | A single token/API key |
| Username with password | Login credentials (Docker Hub, registries) |
| SSH Username with private key | Git over SSH, remote server access |
| Secret file | A config/key file (`.pem`, `kubeconfig`) |
| Certificate | Client certs for secure connections |

## Key takeaway

Replace any plain-text secret in this repo (like `demo-secret-token`) with a
managed credential referenced by ID — the Jenkinsfile itself should never
contain the actual secret value.

