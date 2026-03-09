# Deployment Guide

## CI/CD Pipeline

This repo uses **GitHub Actions** to deploy changes to the OCI A1 server.

### How It Works

1. Push changes to the `main` branch
2. GitHub Actions triggers the deploy workflow
3. The workflow SSHs into the server and syncs files
4. Relevant services are restarted if needed

### Required GitHub Secrets

Set these in the repo settings under **Settings > Secrets and variables > Actions**:

| Secret | Description |
|--------|-------------|
| `SSH_PRIVATE_KEY` | Contents of `ssh-key-2026-02-28.key` |
| `SERVER_HOST` | `147.224.144.47` |
| `SERVER_USER` | `ubuntu` |

### Manual Deployment

```bash
# SSH into server
ssh -i ~/ssh-key-2026-02-28.key ubuntu@147.224.144.47

# Sync workspace files
scp -i ~/ssh-key-2026-02-28.key -r workspace/ ubuntu@147.224.144.47:~/.openclaw/workspace/

# Sync scripts
scp -i ~/ssh-key-2026-02-28.key scripts/*.sh ubuntu@147.224.144.47:~/

# Restart gateway
ssh -i ~/ssh-key-2026-02-28.key ubuntu@147.224.144.47 "systemctl --user restart openclaw-gateway.service"
```

### What Gets Deployed

The CI/CD pipeline syncs:
- `workspace/` -> `~/.openclaw/workspace/` (agent personality, memory, skills)
- `scripts/` -> `~/` (maintenance and setup scripts)

**NOT deployed** (contain secrets, managed on server only):
- `openclaw.json` (gateway config with tokens)
- `agents/main/agent/models.json` (API keys)
- `agents/main/agent/auth-profiles.json` (API keys)
- `credentials/` (Telegram tokens)
