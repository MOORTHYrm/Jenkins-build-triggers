# Shared Library Demo (Consumer)

This folder's `Jenkinsfile` demonstrates **consuming** a Jenkins Shared
Library — it does not contain the library code itself. The library lives
in a separate repo: `jenkins-shared-library`.

---

## Prerequisites

1. Create and push a separate repo named `jenkins-shared-library`
   (structure and files provided alongside this demo).
2. Register it in Jenkins: Manage Jenkins → System → Global Pipeline
   Libraries → Add:
   - Name: `jenkins-shared-library`
   - Default version: `main`
   - Retrieval method: Modern SCM → Git → your library repo URL
3. Save.

---

## This Jenkinsfile

```groovy
@Library('jenkins-shared-library') _
import org.example.Utils

pipeline {
    agent any
    stages {
        stage('Checkout') {
            steps { checkout scm }
        }
        stage('Build') {
            steps {
                script {
                    def filename = Utils.buildFilename('nightly-report', 'pdf')
                    echo "Generated filename from shared library: ${filename}"
                }
            }
        }
        stage('Deploy') {
            steps {
                deployApp('staging')
            }
        }
        stage('Notify') {
            steps {
                notifySlack('Deployment to staging complete')
            }
        }
    }
}
```

`@Library('jenkins-shared-library') _` pulls in the library by its
registered name. `deployApp(...)` and `notifySlack(...)` come from the
library's `vars/` folder — no import needed for those. `Utils` comes from
`src/org/example/Utils.groovy` and does need an explicit `import`.

---

## Jenkins job setup for this demo

1. New Item → name: `shared-library-demo` → Pipeline → OK
2. Configure → Pipeline → Definition: **Pipeline script from SCM**
3. Repository URL:
   ```
   https://github.com/MOORTHYrm/Jenkins-build-triggers.git
   ```
4. Branch Specifier: `*/main`
5. Script Path: `shared-library-demo/Jenkinsfile`
6. Save → Build Now
7. Console Output should show:
   ```
   Generated filename from shared library: nightly-report.pdf
   Deploying to staging...
   [Slack notification] Deployment to staging complete
   Shared library demo pipeline finished.
   ```

