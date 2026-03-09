# OpenClaw Architecture

## Directory Structure on Server

```
~/.openclaw/
├── openclaw.json              # Main gateway config
├── watchdog.sh                # Health check script
├── update-check.json          # Auto-update tracking
├── agents/
│   └── main/
│       └── agent/
│           ├── models.json        # LLM provider configs + API keys
│           └── auth-profiles.json # API key profiles (google, cohere, gemini, groq)
├── canvas/
├── completions/
├── credentials/
│   ├── whatsapp/
│   ├── telegram-default-allowFrom.json
│   └── telegram-pairing.json
├── cron/
│   ├── jobs.json              # Scheduled tasks
│   └── runs/
├── delivery-queue/
│   └── failed/
├── devices/
│   ├── paired.json
│   └── pending.json
├── extensions/
│   └── openclaw-web-search/   # DuckDuckGo search plugin
├── identity/
│   ├── device.json
│   └── device-auth.json
├── logs/
├── sandboxes/
│   └── agent-main-f331f052/
├── telegram/
└── workspace/
    ├── .clawhub/lock.json
    ├── .git/
    ├── .openclaw/workspace-state.json
    ├── memory/
    │   ├── 2026-02-28.md      # Daily notes
    │   └── heartbeat-state.json
    └── skills/
        └── ddg-web-search/    # DuckDuckGo search skill
```

## Agent Identity

- **Name:** Ron
- **Emoji:** Lightning bolt
- **Owner:** Dor (Field CTO Data and AI Innovation at Oracle, Kfar Saba, Israel)
- **Personality:** Defined in `workspace/SOUL.md`
- **Behavior:** Defined in `workspace/AGENTS.md`

## Systemd Services

```bash
# Gateway service
systemctl --user status openclaw-gateway.service

# Watchdog timer (every 2 min)
systemctl --user status openclaw-watchdog.timer

# Restart gateway
systemctl --user restart openclaw-gateway.service

# View logs
journalctl --user -u openclaw-gateway.service -f
```

## Home Directory Scripts

Setup and maintenance scripts in `~/`:

| Script | Purpose |
|--------|---------|
| `step1-reset.sh` | Reset OpenClaw installation |
| `step4-onboard.sh` | Run onboarding wizard |
| `step5-configure.sh` | Configure Gemini + Cohere providers, Telegram |
| `step6-start.sh` | Start the gateway |
| `step7-verify.sh` | Verify everything is working |
| `phase3-harden.sh` | Security hardening (permissions, watchdog, rules) |
| `phase4-smart.sh` | Enable workflows, memory, anticipatory planning |
| `set-models.sh` | Set Cohere primary / Gemini fallback |
| `fix-auth*.sh` | Various auth fix scripts |
| `fix-cohere*.sh` | Cohere provider fix scripts |
| `fix-gemini-auth.sh` | Gemini auth fix |
| `check-cohere.sh` | Verify Cohere connection |
| `check-main-config.sh` | Verify config providers |
| `full-reset.sh` | Full reset script |
| `reset-oc.sh` | OpenClaw reset |

## Installed Extensions

- **openclaw-web-search** (v0.1.3) - Web search tool by Ollama

## Installed Skills

- **ddg-web-search** (v1.0.0) - DuckDuckGo search via web_fetch (workaround for missing Brave API key)
