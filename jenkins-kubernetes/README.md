# Jenkins Kubernetes Credentials Demo

## What it is
A kubeconfig file holds the cluster address and login details for
`kubectl`. Jenkins stores it as a "Secret file" credential. A job binds
it to the `KUBECONFIG` variable at build time, so the file never lives
in the repo or the workspace permanently.

## Files
- `k8s-demo.sh`: prints the current context and runs `kubectl get nodes`
  and `kubectl get namespaces`.

## Prerequisites
- `kubectl` installed on the Jenkins server, and the `jenkins` user can run it.
- A kubeconfig for a test cluster (kind, minikube, or a GKE dev cluster).
- The cluster API must be reachable from the Jenkins server.

## Expected console output
    Current context: <your-context>
    NAME        STATUS   ROLES           AGE   VERSION
    <node>      Ready    control-plane   ...   ...
    (namespaces list)

## Notes
- A kubeconfig can contain cluster admin access. Use a dedicated service
  account with read-only permissions for demos.
- Never commit a kubeconfig or paste it into chat or tickets. Rotate the
  credentials if it is exposed.
- For production, prefer short-lived tokens or workload identity over
  static kubeconfigs.
