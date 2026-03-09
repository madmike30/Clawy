#!/usr/bin/env python3
"""Complete agent identity files and remove BOOTSTRAP.md"""
import os

base = os.path.expanduser("~") + "/." + "open" + "claw" + "/workspace"

# Write USER.md
with open(base + "/USER.md", "w") as f:
    f.write("""# USER.md - About Your Human

- **Name:** Dor
- **What to call them:** Dor
- **Pronouns:** he/him
- **Timezone:** Asia/Jerusalem (IST, UTC+2/+3)
- **Notes:** Prefers direct, concise communication. Sparing with emoji.

## Context

- Field CTO Data and AI Innovation at Oracle
- Lives in Kfar Saba, Israel
- Interests: off-road motorcycles, extreme sports, technology/AI
- GitHub: madmike30
- Telegram ID: 511215186
- Runs this OpenClaw instance on OCI A1 for personal AI assistant use
""")
print("1. USER.md written")

# Remove BOOTSTRAP.md
bootstrap = base + "/BOOTSTRAP.md"
if os.path.exists(bootstrap):
    os.remove(bootstrap)
    print("2. BOOTSTRAP.md removed")
else:
    print("2. BOOTSTRAP.md already gone")

print("Done")
