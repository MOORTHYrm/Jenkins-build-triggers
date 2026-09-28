# Jenkins Plugin Backup

## What it is
Plugins live in `/var/lib/jenkins/plugins`. This script saves:
- `plugins_<date>.tar.gz`: the plugin files
- `plugins_<date>.txt`: plugin names and versions (`name:version`)

Use it before upgrades or to rebuild Jenkins on a new server with the same plugin versions.

## Prerequisite
    sudo mkdir -p /var/backups/jenkins && sudo chown jenkins:jenkins /var/backups/jenkins

## Verify
    ls -lh /var/backups/jenkins/plugins_*
    head -5 /var/backups/jenkins/plugins_*.txt

Expected lines look like `git:5.2.2`.

## Restore from archive
    sudo systemctl stop jenkins
    sudo tar -xzf /var/backups/jenkins/plugins_<date>.tar.gz -C /var/lib/jenkins
    sudo chown -R jenkins:jenkins /var/lib/jenkins/plugins
    sudo systemctl start jenkins

## Reinstall from the list (fresh Jenkins)
    while IFS=: read -r name ver; do
      java -jar jenkins-cli.jar -s http://localhost:8080/ -auth admin:<api-token> install-plugin "$name:$ver"
    done < plugins_<date>.txt

## Notes
- Do not commit the `.tar.gz` files to GitHub (large, may contain secrets).
- Store copies off-server (GCS/S3) for real disaster recovery.
