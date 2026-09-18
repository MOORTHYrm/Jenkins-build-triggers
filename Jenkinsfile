  pipeline {
       agent any
       stages {
           stage('Build') {
               steps {
                   echo "Upstream pipeline build at ${new Date()}"
               }
           }
       }
       post {
           success {
               build job: 'demo-pipeline-downstream', wait: false
           }
       }
   }
