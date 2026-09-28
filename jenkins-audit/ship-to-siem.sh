#!/bin/bash
# Step 3: forward Jenkins audit logs to a SIEM/syslog receiver via rsyslog
# Usage: SIEM_HOST=127.0.0.1 SIEM_PORT=5514 sudo -E bash ship-to-siem.sh
[ "$EUID" -eq 0 ] || { echo "Run with sudo -E"; exit 1; }
SIEM_HOST=${SIEM_HOST:-127.0.0.1}
SIEM_PORT=${SIEM_PORT:-5514}
cat > /etc/rsyslog.d/30-jenkins-audit.conf << CONF
module(load="imfile")
input(type="imfile" File="/var/lib/jenkins/audit-*.log" Tag="jenkins-audit" Severity="info" Facility="local6")
local6.* @${SIEM_HOST}:${SIEM_PORT}
CONF
systemctl restart rsyslog
echo "Forwarding Jenkins audit logs to ${SIEM_HOST}:${SIEM_PORT}"
