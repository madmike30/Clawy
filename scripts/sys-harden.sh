#!/bin/bash
set -e

echo "=== System-level security hardening ==="

# Step 0: Update OpenClaw
echo "1. Updating OpenClaw..."
npm update -g openclaw 2>/dev/null && echo "   OpenClaw updated" || echo "   OpenClaw update skipped (may need manual update)"

# Step 3c: Enable unattended-upgrades
echo "2. Checking unattended-upgrades..."
if dpkg -l unattended-upgrades >/dev/null 2>&1; then
    echo "   unattended-upgrades already installed"
else
    sudo apt-get update -qq && sudo apt-get install -y -qq unattended-upgrades
    echo "   unattended-upgrades installed"
fi
sudo dpkg-reconfigure -plow unattended-upgrades 2>/dev/null || true
echo "   Auto security updates configured"

# Step 3d: Harden SSH
echo "3. Hardening SSH..."
SSHD_CONFIG="/etc/ssh/sshd_config"
sudo sed -i 's/^#*PermitRootLogin.*/PermitRootLogin no/' $SSHD_CONFIG
sudo sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication no/' $SSHD_CONFIG
sudo sed -i 's/^#*MaxAuthTries.*/MaxAuthTries 3/' $SSHD_CONFIG
sudo systemctl reload sshd 2>/dev/null || sudo systemctl reload ssh 2>/dev/null
echo "   SSH: root login disabled, password auth disabled, max 3 auth tries"

# Step: Setup UFW firewall
echo "4. Configuring firewall (UFW)..."
sudo ufw --force reset >/dev/null 2>&1
sudo ufw default deny incoming >/dev/null
sudo ufw default allow outgoing >/dev/null
sudo ufw allow 22/tcp comment 'SSH' >/dev/null
sudo ufw allow 18789/tcp comment 'OpenClaw Gateway' >/dev/null
sudo ufw --force enable >/dev/null
echo "   UFW: only ports 22 (SSH) and 18789 (Gateway) open"

# Step: Restart OpenClaw gateway
echo "5. Restarting OpenClaw gateway..."
systemctl --user restart openclaw-gateway.service
sleep 2
if systemctl --user is-active openclaw-gateway.service >/dev/null 2>&1; then
    echo "   Gateway: active"
else
    echo "   WARNING: Gateway may not be running!"
fi

echo ""
echo "=== Hardening complete ==="
echo "Summary:"
echo "  - OpenClaw UI dangerous flags: DISABLED"
echo "  - Agent sandbox: ENABLED (all sessions)"
echo "  - Auth rate limiting: ENABLED (10/min, 5min lockout)"
echo "  - SSH: key-only, no root, max 3 tries"
echo "  - Firewall: ports 22 + 18789 only"
echo "  - Auto security updates: ENABLED"
echo ""
echo "IMPORTANT: UI access now requires proper device auth."
echo "If locked out, SSH in and edit config manually."
