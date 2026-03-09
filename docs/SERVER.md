# OpenClaw Server - OCI A1 Compute

## Server Details

| Property | Value |
|----------|-------|
| **Host** | `147.224.144.47` |
| **User** | `ubuntu` |
| **SSH Key** | `ssh-key-2026-02-28.key` (in `C:\Users\Dor\`) |
| **Platform** | OCI A1 Compute (ARM) |
| **OS** | Ubuntu |
| **Node.js** | v22.22.0 |
| **npm** | 10.9.4 |

## SSH Access

```bash
ssh -i ~/ssh-key-2026-02-28.key ubuntu@147.224.144.47
```

## What's Running

### OpenClaw Gateway (v2026.3.7)

An AI bot gateway managed via **systemd user services** (not Docker or pm2).

- **Service:** `openclaw-gateway.service` (active, ~440MB memory)
- **Watchdog:** `openclaw-watchdog.timer` (every 2 minutes)
- **Config:** `~/.openclaw/openclaw.json`

### Ports

| Port | Interface | Service |
|------|-----------|---------|
| 18789 | 0.0.0.0 | OpenClaw Gateway (external) |
| 18791 | 127.0.0.1 | OpenClaw Gateway (internal) |
| 18792 | 127.0.0.1 | OpenClaw Gateway (internal) |
| 11434 | 127.0.0.1 | Ollama |
| 22 | 0.0.0.0 | SSH |

### Web UI

```
http://147.224.144.47:18789/#token=<gateway-auth-token>
```

## AI Models

| Provider | Model | Role |
|----------|-------|------|
| Ollama (local) | `minimax-m2.5:cloud` | Primary |
| Gemini | `gemini-2.5-flash` | Fallback |
| Cohere | `command-a-03-2025` | Fallback |

API keys stored in:
- `~/.openclaw/agents/main/agent/models.json`
- `~/.openclaw/agents/main/agent/auth-profiles.json`

Additional key: **Groq** (`groq:default` profile)

## Telegram Integration

- Bot token configured in `openclaw.json`
- Allowed user: Telegram ID `511215186`
- Credentials in `~/.openclaw/credentials/`

## Cron Jobs

| Job | Schedule | Status |
|-----|----------|--------|
| AI News Summary | 9 AM Sun-Thu (Asia/Jerusalem) | Failing (LLM timeout after 120s) |

Config: `~/.openclaw/cron/jobs.json`

## Nginx (STOPPED)

Nginx 1.18.0 is installed but **inactive**. Was configured as:
- Reverse proxy on port 18790 -> 127.0.0.1:18789
- HTTP basic auth (user: `dor`, htpasswd file)
- WebSocket upgrade support

## Security Notes

- Gateway bound to `0.0.0.0:18789` -- externally accessible
- Control UI has dangerous flags enabled:
  - `dangerouslyAllowHostHeaderOriginFallback: true`
  - `allowInsecureAuth: true`
  - `dangerouslyDisableDeviceAuth: true`
- File permissions hardened (700/600) by `phase3-harden.sh`
- Watchdog timer runs every 2 minutes
