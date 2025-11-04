# HabitQuest

Habit tracker that is gamified

# Trigger workflows Thu Aug 14 16:13:24 CDT 2025

## Local Agent CI

This repository is wired to run local, agent‑assisted validation with Ollama.

- Cloud first: set `OLLAMA_CLOUD_URL` to use a cloud endpoint.
- Local fallback: if no cloud is set, scripts start `ollama serve` automatically.

Quick start:

```bash
# Optional: install prerequisites
# brew install ollama swiftlint swiftformat
# ollama pull llama3.1:8b qwen2.5-coder:7b mistral:7b

# Prefer cloud (if available)
export OLLAMA_CLOUD_URL=https://your-cloud-endpoint
make validate

# Or run locally
unset OLLAMA_CLOUD_URL
make validate
```

Scripts:
- `.ci/agent_validate.sh`: sets AI env and runs validation
- `.ci/run_validation.sh`: performs lint/format, tests, and best‑effort remediation via Tools/Automation
