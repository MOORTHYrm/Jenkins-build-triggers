# Docker Pipeline Demo

Demonstrates the **Docker Pipeline plugin** — building a custom Docker
image from a `Dockerfile` in this folder, then running commands inside a
real container built from that image, all within the same pipeline run.

This is different from `dynamic-agents-demo/` (which runs the whole
pipeline *on* a pre-built public image like `node:18-alpine`) — this demo
*builds its own image* first, then uses it.

---

## Step 1 — Prerequisites

1. Manage Jenkins → Plugins → Available plugins → search **"Docker Pipeline"** → install
2. Docker installed and running on the Jenkins host/agent
3. The `jenkins` system user must be able to talk to Docker:
   ```bash
   sudo usermod -aG docker jenkins
   sudo systemctl restart jenkins
   ```

---

## Step 2 — Files in this folder

**`Dockerfile`**
```dockerfile
FROM alpine:3.19
RUN echo "Built by Docker Pipeline demo" > /build-info.txt
CMD ["sh"]
```

**`Jenkinsfile`**
```groovy
pipeline {
    agent any
    stages {
        stage('Checkout') {
            steps { checkout scm }
        }
        stage('Build Custom Image') {
            steps {
                script {
                    dockerImage = docker.build(
                        "demo-app:${env.BUILD_NUMBER}",
                        "docker-pipeline-demo"
                    )
                }
            }
        }
        stage('Run Inside the Image') {
            steps {
                script {
                    dockerImage.inside {
                        sh 'cat /build-info.txt'
                        sh 'cat /etc/os-release'
                    }
                }
            }
        }
    }
}
```

**What happens when it runs:**
1. Jenkins checks out this repo
2. `docker.build(...)` builds a real image from `docker-pipeline-demo/Dockerfile`, tagged `demo-app:<BUILD_NUMBER>`
3. `dockerImage.inside { }` starts a container from that freshly built image and runs commands inside it
4. `cat /build-info.txt` proves the custom build step actually ran (file only exists because the `Dockerfile` created it)
5. The container is cleaned up automatically after the stage finishes

---

## Step 3 — Jenkins job setup

1. New Item → name: `docker-pipeline-demo` → Pipeline → OK
2. Configure → Pipeline → Definition: **Pipeline script from SCM**
3. Repository URL:
   ```
   https://github.com/MOORTHYrm/Jenkins-build-triggers.git
   ```
4. Branch Specifier: `*/main`
5. Script Path: `docker-pipeline-demo/Jenkinsfile`

   ⚠️ Must be capital `Jenkinsfile`, not `jenkinsfile`.

6. Save → Build Now

---

## Step 4 — Verify it worked

Console Output should show:
- Docker building the image, with `RUN echo "Built by Docker Pipeline demo" > /build-info.txt` executing
- The container starting from the new image
- `Built by Docker Pipeline demo` printed from `cat /build-info.txt`
- Alpine Linux details printed from `cat /etc/os-release`

## Common `docker` step options

| Method | What it does |
|---|---|
| `docker.build("tag", "path")` | Builds an image from a Dockerfile at the given path, with the given tag |
| `image.inside { }` | Runs pipeline steps inside a container from that image |
| `docker.withRegistry(url, credentialsId) { }` | Authenticates to a private registry before push/pull |
| `image.push()` | Pushes the built image to a registry |

## Related demos in this repo

- `dynamic-agents-demo/` — running an entire pipeline on a pre-built public Docker image
- `cloud-agents-demo/` — running on a real cloud VM instead of a container

