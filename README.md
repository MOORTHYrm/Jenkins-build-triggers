# Jenkins Build Triggers Demo - 1

- `Jenkinsfile` — upstream pipeline (demo-pipeline-upstream)
   - `downstream/Jenkinsfile` — downstream pipeline (demo-pipeline-downstream)
   - Trigger via: curl -X POST -u moorthy:<TOKEN> "<jenkins-url>/job/demo-pipeline-upstream/build?token=demo-secret-token"

