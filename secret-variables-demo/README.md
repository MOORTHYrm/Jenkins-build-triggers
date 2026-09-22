# Secret Variables Demo

Demonstrates a **Secret Variable** — a "Secret text" credential injected into
the pipeline as an environment variable, automatically masked (`****`) in
the console log.

This uses the same underlying mechanism as `credentials-variables-demo/`
in this repo — "Secret Variable" and "Credentials Variable" describe the
same feature; "Secret text" is just the specific credential Kind used here.

---

## Step 1: Create the credential

1. Manage Jenkins → Credentials → System → Global credentials (unrestricted)
2. Add Credentials
3. Kind: **Secret text**
4. Secret: paste a real or test value
5. ID: `demo-secret-variable`
6. Create

## Step 2: Jenkinsfile usage

```groovy
pipeline {
    agent any

    environment {
        MY_SECRET = credentials('demo-secret-variable')
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        stage('Use Secret Variable') {
            steps {
                sh 'echo "Secret value is: $MY_SECRET"'
            }
        }
    }
}
```

## Step 3: Create the Jenkins job

1. New Item → name: `secret-variables-demo` → Pipeline → OK
2. Configure → Pipeline → Definition: **Pipeline script from SCM**
3. SCM: Git → Repository URL:
   ```
   https://github.com/MOORTHYrm/Jenkins-build-triggers.git
   ```
4. Branch Specifier: `*/main`
5. Script Path: `secret-variables-demo/Jenkinsfile`
6. Save → Build Now
7. Console Output should show `Secret value is: ****` — masked automatically

## Related demo in this repo

- `credentials-variables-demo/` — the same pattern, applied to an API token used in a curl call

