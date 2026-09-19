pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                echo "Upstream pipeline build at ${new Date()}"
                sh 'mkdir -p output && echo "build-$(date +%s)" > output/artifact.txt'
            }
        }
    }
    post {
        success {
            archiveArtifacts artifacts: 'output/artifact.txt', fingerprint: true
            build job: 'demo-pipeline-downstream', wait: false
        }
    }
}

