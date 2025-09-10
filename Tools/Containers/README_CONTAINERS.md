# Run heavy tasks in containers

This workspace includes Docker services to offload CPU/RAM heavy jobs from macOS:
- Inventory + docs generation (Ubuntu-based)
- SwiftPM tests for `Shared` (Swift official image)
- Spell checking via cspell (Node image)

Note: Xcode/iOS builds must run on macOS and are not containerized.

## Prerequisites
- Docker Desktop for macOS installed and running

## Build images (first run only)
- docker compose -f Tools/docker-compose.yml build

## Run inventory + docs
- docker compose -f Tools/docker-compose.yml run --rm tools

## Run SwiftPM tests (Shared)
- docker compose -f Tools/docker-compose.yml run --rm swift

## Run cspell (non-blocking)
- docker compose -f Tools/docker-compose.yml run --rm cspell

### Tips
- Volumes mount the repo at /workspace, so outputs write to your host repo.
- You can chain: `docker compose -f Tools/docker-compose.yml run --rm tools && docker compose -f Tools/docker-compose.yml run --rm swift`