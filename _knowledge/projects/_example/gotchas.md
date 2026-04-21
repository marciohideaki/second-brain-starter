---
tags: [project, gotchas, example]
status: template
created: 2026-04-21
updated: 2026-04-21
---

# Gotchas — example

> Non-obvious behavior, traps, and lessons learned. Add one per discovery.

### Example: the config file must be loaded before the server starts

**Problem:** If you start the server first, the config defaults fire and never get overridden.
**Solution / context:** Load `config.json` at module init, not on first request.
