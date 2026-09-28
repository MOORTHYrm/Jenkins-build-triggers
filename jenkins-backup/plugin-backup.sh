#!/bin/bash
BACKUP_DIR=/var/backups/jenkins
DATE=$(date +%F_%H-%M)
mkdir -p "$BACKUP_DIR"

for d in /var/lib/jenkins/plugins/*/; do
  name=$(basename "$d")
  ver=$(grep -m1 '^Plugin-Version' "$d/META-INF/MANIFEST.MF" | cut -d' ' -f2 | tr -d '\r')
  echo "$name:$ver"
done > "$BACKUP_DIR/plugins_$DATE.txt"

tar -czf "$BACKUP_DIR/plugins_$DATE.tar.gz" -C /var/lib/jenkins plugins

echo "Plugin backup completed"
wc -l "$BACKUP_DIR/plugins_$DATE.txt"
ls -lh "$BACKUP_DIR"
