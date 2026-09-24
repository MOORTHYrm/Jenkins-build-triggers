# Test Reports Demo (JUnit)

Demonstrates Jenkins' built-in test result reporting using the `junit`
step, which parses JUnit-format XML and turns it into a pass/fail
dashboard, per-test drill-down, and trend graphs across builds.

No plugin install required — the `junit` step ships with Jenkins core.

---

## This Jenkinsfile

```groovy
pipeline {
    agent any
    stages {
        stage('Checkout') {
            steps { checkout scm }
        }
        stage('Run Tests') {
            steps {
                sh '''
                    mkdir -p test-results
                    cat > test-results/results.xml << 'EOF'
                    ... JUnit XML with 2 passing, 1 failing test ...
                    EOF
                '''
            }
        }
    }
    post {
        always {
            junit 'test-results/*.xml'
        }
    }
}
```

The `Run Tests` stage fakes a JUnit XML result file so the reporting side
is visible without needing a real test suite wired up. In a real project,
replace that `sh` block with your actual test command.

---

## Replacing the fake step with a real test command

| Language/Tool | Real command to use instead |
|---|---|
| Java (Maven/Gradle) | native — no extra flags needed, just run `mvn test` / `gradle test` |
| Python (pytest) | `pytest --junitxml=test-results/results.xml` |
| JavaScript (Jest) | `jest --reporters=jest-junit` |
| JavaScript (Mocha) | `mocha --reporter mocha-junit-reporter` |
| .NET | `dotnet test --logger "junit;LogFilePath=test-results/results.xml"` |
| Go | `go test -v ./... \| go-junit-report > test-results/results.xml` |

---

## Jenkins job setup

1. New Item → name: `test-reports-demo` → Pipeline → OK
2. Configure → Pipeline → Definition: **Pipeline script from SCM**
3. Repository URL:
   ```
   https://github.com/MOORTHYrm/Jenkins-build-triggers.git
   ```
4. Branch Specifier: `*/main`
5. Script Path: `test-reports-demo/Jenkinsfile`
6. Save → Build Now

---

## Viewing the results

1. Open the completed build
2. Look for a **"Test Result"** link (left sidebar, or on the job's main page)
3. Click it → see the pass/fail breakdown: 2 passed, 1 failed
4. Click the failed test (`testInvalidLogin`) → see the failure message: `Expected error message not shown`
5. Run the pipeline a few more times → a **trend graph** builds up on the job's main page, showing pass/fail counts over recent builds

---

## `junit` step options

| Option | What it does |
|---|---|
| `testResults` (the path string, e.g. `'test-results/*.xml'`) | Glob pattern matching your result files |
| `allowEmptyResults: true` | Don't fail the build if no test files are found |
| `skipPublishingChecks: true` | Skip posting results as a GitHub commit status check |
| `healthScaleFactor` | Controls how test failures affect the job's "weather" health icon |

## Common issues

| Symptom | Cause |
|---|---|
| "No test report files were found" | Wrong path/glob in `junit 'path'`, or the test step didn't actually produce XML |
| Build fails even though tests look fine | `junit` by default fails the build if XML is missing — add `allowEmptyResults: true` if that's not desired |
| Trend graph doesn't appear | Needs at least 2 builds with test results to start showing a trend |

## Related demos in this repo

- `html-publisher-demo/` — for static/custom HTML reports (coverage, lint output) that aren't structured test results

