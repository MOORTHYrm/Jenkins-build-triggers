# Security Reports Demo (OWASP Dependency-Check)

Demonstrates publishing a dependency vulnerability report using the
**OWASP Dependency-Check Plugin** — scans dependencies for known CVEs and
shows severity, description, and a trend graph across builds.

---

## Step 1 — Install the plugin

1. Manage Jenkins → Plugins → Available plugins
2. Search: `OWASP Dependency-Check`
3. Check it → Install without restart
4. Confirm under Installed plugins once done

---

## Step 2 — This Jenkinsfile

```groovy
pipeline {
    agent any
    stages {
        stage('Checkout') {
            steps { checkout scm }
        }
        stage('Run Security Scan') {
            steps {
                sh '''
                    mkdir -p reports
                    cat > reports/dependency-check-report.xml << 'EOF'
                    ... fake OWASP XML: 1 HIGH severity CVE in lodash ...
                    EOF
                '''
            }
        }
    }
    post {
        always {
            dependencyCheckPublisher(
                pattern: 'reports/dependency-check-report.xml'
            )
        }
    }
}
```

The `Run Security Scan` stage fakes an OWASP Dependency-Check XML report
(one HIGH severity CVE found in `lodash-4.17.15.tgz`) so the reporting
side is visible without needing a real scanner installed. In a real
project, replace that `sh` block with an actual scan command.

---

## Replacing the fake step with a real scan

| Tool | What it scans | Command |
|---|---|---|
| OWASP Dependency-Check | Dependency CVEs (any language) | `dependency-check.sh --project "app" --scan . --format XML --out reports/` |
| Snyk | Dependency CVEs + license issues | `snyk test --json > reports/snyk.json` (needs a separate Snyk plugin) |
| Trivy | Container image + filesystem scanning | `trivy image myimage:latest --format template --output reports/trivy.xml` |
| SonarQube | Code quality + security hotspots (SAST) | `sonar-scanner` (needs the SonarQube plugin + server) |
| npm audit | Node.js dependency vulnerabilities | `npm audit --json > reports/npm-audit.json` |

---

## Jenkins job setup

1. New Item → name: `security-reports-demo` → Pipeline → OK
2. Configure → Pipeline → Definition: **Pipeline script from SCM**
3. Repository URL:
   ```
   https://github.com/MOORTHYrm/Jenkins-build-triggers.git
   ```
4. Branch Specifier: `*/main`
5. Script Path: `security-reports-demo/Jenkinsfile`

   ⚠️ Must be capital `Jenkinsfile` — a lowercase `jenkinsfile` will fail
   with `Unable to find .../Jenkinsfile from git ...` (same issue hit
   earlier with `test-reports-demo` in this repo).

6. Save → Build Now

---

## Viewing the results

1. Open the completed build
2. Look for a **"Dependency-Check"** link (left sidebar, or on the job's main page)
3. Click it → see the vulnerability count and severity breakdown
4. Drill into `lodash-4.17.15.tgz` → see `CVE-2020-8203`, severity **HIGH**, with the description
5. Run the pipeline a few more times → a trend graph builds up showing vulnerability counts over time

---

## `dependencyCheckPublisher` options

| Option | What it does |
|---|---|
| `pattern` | Path to the XML report file |
| Quality gates (configurable) | Can mark the build unstable/failed if vulnerabilities above a severity threshold are found |
| Trend graph | Builds automatically across runs, same as Test/Coverage reports |

## Why this matters for real pipelines

Security Reports are commonly tied into **Merge Validation** — failing the
build (or blocking a PR merge) if a HIGH/CRITICAL vulnerability is found,
so insecure dependencies can't reach production silently.

## Common issues

| Symptom | Cause |
|---|---|
| `No such DSL method 'dependencyCheckPublisher'` | Plugin isn't installed yet |
| "No dependency-check reports found" | Wrong `pattern` path, or the scan step didn't actually produce the XML |
| `Unable to find .../Jenkinsfile` | Filename case mismatch — must be `Jenkinsfile`, not `jenkinsfile` |

## Related demos in this repo

- `test-reports-demo/` — pass/fail test results
- `coverage-reports-demo/` — how much code was exercised by tests
- `security-reports-demo/` — this folder — known vulnerabilities in dependencies

