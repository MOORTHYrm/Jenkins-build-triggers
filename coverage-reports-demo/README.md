# Coverage Reports Demo

Demonstrates publishing code coverage using Jenkins' **Coverage Plugin**,
which parses Cobertura/JaCoCo/LCOV-format XML and shows an overall
percentage, per-file breakdown, and trend graph across builds.

---

## Step 1 — Install the plugin

1. Manage Jenkins → Plugins → Available plugins
2. Search: `Coverage`
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
        stage('Run Tests with Coverage') {
            steps {
                sh '''
                    mkdir -p coverage
                    cat > coverage/cobertura.xml << 'EOF'
                    ... Cobertura XML: 82% line coverage, 75% branch coverage ...
                    EOF
                '''
            }
        }
    }
    post {
        always {
            recordCoverage(tools: [[parser: 'COBERTURA', pattern: 'coverage/cobertura.xml']])
        }
    }
}
```

The `Run Tests with Coverage` stage fakes a Cobertura XML file so the
reporting side is visible without needing a real test suite. In a real
project, replace that `sh` block with an actual coverage-generating
command.

---

## Replacing the fake step with real coverage data

| Language/Tool | Real command to use instead |
|---|---|
| Python (pytest + coverage.py) | `pytest --cov=myapp --cov-report=xml:coverage/cobertura.xml` |
| JavaScript (Jest) | `jest --coverage --coverageReporters=cobertura` |
| Java (Maven + JaCoCo) | `mvn test jacoco:report` (outputs `target/site/jacoco/jacoco.xml`) |
| .NET (coverlet) | `dotnet test /p:CollectCoverage=true /p:CoverletOutputFormat=cobertura` |
| Go | `go test -coverprofile=coverage.out ./...` then convert via `gocover-cobertura` |

---

## Jenkins job setup

1. New Item → name: `coverage-reports-demo` → Pipeline → OK
2. Configure → Pipeline → Definition: **Pipeline script from SCM**
3. Repository URL:
   ```
   https://github.com/MOORTHYrm/Jenkins-build-triggers.git
   ```
4. Branch Specifier: `*/main`
5. Script Path: `coverage-reports-demo/Jenkinsfile`

   ⚠️ Note: this must be capital `Jenkinsfile` — a lowercase `jenkinsfile`
   will fail with `Unable to find .../Jenkinsfile from git ...` (this
   exact issue came up with `test-reports-demo` earlier in this repo).

6. Save → Build Now

---

## Viewing the results

1. Open the completed build
2. Look for a **"Coverage"** link (left sidebar, or on the job's main page)
3. Click it → see the overall percentage and a file-by-file breakdown
4. Drill into `login.py` (90%) vs `logout.py` (70%) to see the difference
5. Run the pipeline a few more times → a coverage **trend graph** builds up on the job's main page

---

## `recordCoverage` options

| Option | What it does |
|---|---|
| `tools: [[parser: 'COBERTURA', pattern: '...']]` | Which coverage format to parse and where to find it |
| Multiple entries in `tools` | Combine coverage from different languages/tools in one report |
| Quality gates (configurable) | Can mark the build unstable/failed if coverage drops below a threshold |

## Common issues

| Symptom | Cause |
|---|---|
| `No such DSL method 'recordCoverage'` | Coverage plugin isn't installed yet |
| "No coverage results found" | Wrong `pattern` path, or the test step didn't actually produce the XML |
| `Unable to find .../Jenkinsfile` | Filename case mismatch — must be `Jenkinsfile`, not `jenkinsfile` |

## Related demos in this repo

- `test-reports-demo/` — pass/fail test results (what ran and what broke)
- `html-publisher-demo/` — static/custom HTML reports
- `coverage-reports-demo/` — this folder — how much code was actually exercised by tests

