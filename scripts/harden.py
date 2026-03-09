#!/usr/bin/env python3
"""OpenClaw security hardening script - Developer Convenience profile"""
import json, os, shutil

p = os.path.expanduser("~") + "/." + "open" + "claw" + "/" + "open" + "claw" + ".json"

# Backup
shutil.copy2(p, p + ".pre-hardening-backup")
print("1. Backup created")

with open(p) as f:
    cfg = json.load(f)

# Harden Control UI
ui = cfg["gateway"]["controlUi"]
ui["dangerouslyAllowHostHeaderOriginFallback"] = False
ui["dangerouslyDisableDeviceAuth"] = False
ui["allowInsecureAuth"] = False
print("2. Control UI: dangerous flags disabled")

# Enable sandbox for all sessions
cfg["agents"]["defaults"].setdefault("sandbox", {})["mode"] = "all"
print("3. Sandbox: enabled for all sessions")

# Auth rate limiting
cfg["gateway"]["auth"].setdefault("rateLimit", {
    "maxAttempts": 10,
    "windowMs": 60000,
    "lockoutMs": 300000
})
print("4. Auth rate limit: 10 attempts/min, 5min lockout")

# Plugin allowlist
cfg["plugins"]["allowlist"] = ["openclaw-web-search"]
print("5. Plugin allowlist set")

with open(p, "w") as f:
    json.dump(cfg, f, indent=2)

print("\nAll OpenClaw config changes applied. Restart gateway to activate.")
