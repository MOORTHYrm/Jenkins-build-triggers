# Jenkins → ECR → Kubernetes (EC2) - Simple App

## What is a Kubernetes Deployment?
A **Deployment** tells Kubernetes: "keep N copies (replicas) of my app running."
- **Self-healing**: crashed pods are recreated automatically
- **Scaling**: change `replicas` to add or remove pods
- **Rolling updates**: new version replaces old pods gradually, no downtime
- **Rollback**: `kubectl rollout undo` returns to the previous version

A **Service** gives the pods one stable address and load-balances traffic across them.

## Demo application
A small Flask app that shows the **pod name** serving each request, so refreshing the
page shows load balancing across 3 replicas.

## Flow
```
git push ──► GitHub ──► Webhook ──► Jenkins (EC2 agent: aws-linux)
                                       │
                  docker build ──► docker push ──► Amazon ECR (jenkins-demo-app:k8s-app-<build>)
                                       │
                          kubectl apply (pulls image from ECR)
                                       ▼
                        Deployment (3 pods) ◄── Service :30080
                                       │
                          http://43.204.142.31:30080
```

## Folder structure
```
Jenkins-build-triggers/
└── k8s-app-demo/
    ├── app/
    │   ├── app.py
    │   └── requirements.txt
    ├── k8s/
    │   ├── deployment.yaml
    │   └── service.yaml
    ├── Dockerfile
    ├── Jenkinsfile
    └── README.md
```

## Prerequisites (EC2 instance i-0b73a42205d686ec1)
- t3.medium or larger; Security Group open: 22, 8080, 30080
- Docker, kubectl, kind installed; cluster created with port 30080 mapped
  (`kind create cluster --name demo --config kind-config.yaml`)
- AWS CLI on the agent: `sudo snap install aws-cli --classic`
- ECR repo `jenkins-demo-app` exists (ap-south-1)
- Jenkins credential `aws-ecr-creds` (AWS Credentials) exists
- Jenkins agent `aws-linux-1` (label `aws-linux`) online, `ubuntu` in docker group

## Configuration Steps

1. → Confirm ECR repo: AWS Console → ECR → `jenkins-demo-app` (same repo as before)
2. → Confirm on EC2: `docker ps` ✔ → `kubectl get nodes` ✔ → `aws --version` ✔
3. → Confirm Jenkins credential: Manage Jenkins → Credentials → ID `aws-ecr-creds`
4. → Check `Jenkinsfile` values: `AWS_ACCOUNT_ID`, `AWS_REGION`, `ECR_REPO_NAME`
5. → Push code to GitHub:
```
git clone https://github.com/MOORTHYrm/Jenkins-build-triggers.git
cd Jenkins-build-triggers
# copy the k8s-app-demo folder here
git add k8s-app-demo
git commit -m "Add k8s-app-demo: ECR push and Kubernetes deploy"
git push origin main
```
6. → Jenkins → New Item → `k8s-app-deploy` → Pipeline → OK
7. → Pipeline script from SCM → Git
   - Repo URL: `https://github.com/MOORTHYrm/Jenkins-build-triggers.git`
   - Branch: `*/main`
   - Script Path: `k8s-app-demo/Jenkinsfile`
   → Save
8. → GitHub → Settings → Webhooks → Payload URL `http://43.204.142.31:8080/github-webhook/` → push event
9. → Job → Configure → Build Triggers → check "GitHub hook trigger for GITScm polling" → Save
10. → Build Now → Checkout ✔ → Docker Build ✔ → Push to ECR ✔ → Deploy ✔ → Verify ✔
11. → Verify ECR: AWS Console → ECR → `jenkins-demo-app` → Images → tag `k8s-app-<build>`
12. → Verify on EC2:
```
kubectl get deployment
kubectl get pods
kubectl describe pod <pod-name> | grep Image
```
13. → Open `http://43.204.142.31:30080` → refresh → pod name changes

## How ECR pull works in Kubernetes
Pods pull the image from ECR using the `ecr-secret` imagePullSecret.
Jenkins recreates this secret on every build (ECR tokens expire after 12 hours).

## Demo commands
```
kubectl scale deployment simple-app --replicas=5
kubectl delete pod <pod-name>
kubectl rollout history deployment/simple-app
kubectl rollout undo deployment/simple-app
```

## Update demo (rolling update)
1. → Edit `app/app.py` (change heading text)
2. → `git add . && git commit -m "update app" && git push origin main`
3. → Jenkins pushes a new tag to ECR → rolling update → refresh browser

## Cleanup
```
kubectl delete -f k8s-app-demo/k8s/
kubectl delete secret ecr-secret
```

