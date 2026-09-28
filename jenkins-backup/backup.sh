#!/bin/bash
JENKINS_HOME=/var/lib/jenkins
BACKUP_DIR=/var/backups/jenkins
DATE=$(date +%F_%H-%M)

mkdir -p "$BACKUP_DIR"

# Skip workspaces and caches: large and rebuildable
tar --exclude='workspace' --exclude='caches' --exclude='.cache' \
    -czf "$BACKUP_DIR/jenkins_home_$DATE.tar.gz" -C "$JENKINS_HOME" .

# Keep only the last 7 days of backups
find "$BACKUP_DIR" -name 'jenkins_home_*.tar.gz' -mtime +7 -delete

echo "Backup completed: jenkins_home_$DATE.tar.gz"
ls -lh "$BACKUP_DIR"
