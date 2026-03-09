#!/bin/bash
set -e

BACKUP_DIR="$HOME/backups"
OC_DIR="$HOME/.openclaw"

echo "=== Setting up automated daily backups ==="

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Create backup script
cat > "$HOME/backup-openclaw.sh" << 'BACKUP'
#!/bin/bash
BACKUP_DIR="$HOME/backups"
OC_DIR="$HOME/.openclaw"
DATE=$(date +%Y%m%d-%H%M%S)
BACKUP_FILE="$BACKUP_DIR/openclaw-backup-$DATE.tar.gz"

# Keep only last 7 backups
ls -t "$BACKUP_DIR"/openclaw-backup-*.tar.gz 2>/dev/null | tail -n +8 | xargs rm -f 2>/dev/null

# Backup critical files
tar czf "$BACKUP_FILE" \
    "$OC_DIR/openclaw.json" \
    "$OC_DIR/agents/" \
    "$OC_DIR/credentials/" \
    "$OC_DIR/cron/" \
    "$OC_DIR/workspace/" \
    "$OC_DIR/identity/" \
    "$OC_DIR/devices/" \
    2>/dev/null

echo "Backup created: $BACKUP_FILE ($(du -h "$BACKUP_FILE" | cut -f1))"
BACKUP

chmod +x "$HOME/backup-openclaw.sh"
echo "1. Backup script created at ~/backup-openclaw.sh"

# Run initial backup
bash "$HOME/backup-openclaw.sh"
echo "2. Initial backup completed"

# Set up daily cron job at 3 AM
(crontab -l 2>/dev/null | grep -v backup-openclaw; echo "0 3 * * * $HOME/backup-openclaw.sh >> $BACKUP_DIR/backup.log 2>&1") | crontab -
echo "3. Daily cron job set (3 AM)"

echo ""
echo "=== Backup setup complete ==="
echo "Backups stored in: $BACKUP_DIR (7 day retention)"
echo "Manual backup: ~/backup-openclaw.sh"
