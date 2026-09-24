# HTML Publisher Demo

Demonstrates publishing an HTML report from a pipeline build using the
**HTML Publisher Plugin** — the report becomes viewable as a clickable tab
directly on the build page, no downloading required.

---

## Step 1 — Install the plugin

1. Manage Jenkins → Plugins → Available plugins
2. Search: `HTML Publisher` (or plugin ID: `htmlpublisher`)
3. Check it → Install without restart
4. Confirm it under Installed plugins once done

If it doesn't show up in Available plugins, your Jenkins instance likely
can't reach the update center. Test with:
```bash
curl -I https://updates.jenkins.io/update-center.json
```
If that fails, download the `.hpi` manually from
https://plugins.jenkins.io/htmlpublisher/ on a machine with internet access,
then upload it via Manage Jenkins → Plugins → Advanced settings → Deploy Plugin.

---

## Step 2 — This Jenkinsfile

```groovy
pipeline {
    agent any
    stages {
        stage('Checkout') {
            steps { checkout scm }
        }
        stage('Generate Report') {
            steps {
                sh '''
                    mkdir -p report
                    cat > report/index.html << 'EOF'
                    ... simple HTML table ...
                    EOF
                '''
            }
        }
    }
    post {
        always {
            publishHTML(target: [
                allowMissing: false,
                alwaysLinkToLastBuild: true,
                keepAll: true,
                reportDir: 'report',
                reportFiles: 'index.html',
                reportName: 'Nightly Report'
            ])
        }
    }
}
```

## `publishHTML` options

| Option | What it does |
|---|---|
| `reportDir` | Folder containing the HTML file(s) |
| `reportFiles` | The main HTML file to open (e.g. `index.html`) |
| `reportName` | Label shown in the Jenkins sidebar |
| `keepAll` | Keeps every build's report, not just the latest |
| `alwaysLinkToLastBuild` | Job-level link always points to the most recent report |
| `allowMissing` | If `false`, build fails when the report file is missing |

---

## Step 3 — Jenkins job setup

1. New Item → name: `html-publisher-demo` → Pipeline → OK
2. Configure → Pipeline → Definition: **Pipeline script from SCM**
3. Repository URL:
   ```
   https://github.com/MOORTHYrm/Jenkins-build-triggers.git
   ```
4. Branch Specifier: `*/main`
5. Script Path: `html-publisher-demo/Jenkinsfile`
6. Save → Build Now

## Step 4 — View the report

1. Open the completed build
2. Look at the left sidebar → a new link labeled **"Nightly Report"** should appear
3. Click it → the HTML table renders directly inside Jenkins

## Common issues

| Symptom | Cause |
|---|---|
| `No such DSL method 'publishHTML' found` | Plugin isn't installed yet |
| Report link doesn't appear | Build failed before reaching the `post` block, or `reportDir`/`reportFiles` path is wrong |
| Report shows blank/404 | `reportFiles` doesn't match the actual HTML filename generated |

