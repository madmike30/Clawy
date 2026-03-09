# Clawy - OpenClaw Bot Server

OpenClaw AI bot gateway running on OCI A1 Compute.

## Overview

- **Bot name:** Ron (lightning bolt)
- **Primary model:** minimax-m2.5:cloud (via Ollama)
- **Fallback models:** Gemini 2.5 Flash, Cohere Command A
- **Channel:** Telegram
- **Server:** OCI A1 @ 147.224.144.47

## Structure

```
├── .github/workflows/   # CI/CD pipeline
├── docs/                # Server and architecture documentation
├── workspace/           # Agent workspace (synced to server)
└── scripts/             # Maintenance scripts (synced to server)
```

## Docs

- [Server Details](docs/SERVER.md)
- [Architecture](docs/ARCHITECTURE.md)
- [Deployment](docs/DEPLOYMENT.md)

## CI/CD

Push to `main` triggers auto-deploy of `workspace/` and `scripts/` to the server via SSH.

Required secrets: `SSH_PRIVATE_KEY`, `SERVER_HOST`, `SERVER_USER` - see [Deployment docs](docs/DEPLOYMENT.md).
