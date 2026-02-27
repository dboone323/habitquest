# syntax=docker/dockerfile:1.5
# habitquest - Linux source image for split-platform CI

FROM swift:6.2 AS builder

WORKDIR /app

# Resolve dependencies for Linux-side validation; app compilation remains on macOS CI.
COPY Package.* ./
RUN --mount=type=cache,target=/root/.swiftpm,id=swiftpm \
    swift package resolve

COPY . .

FROM swift:6.2-slim

LABEL maintainer="tools-automation"
LABEL description="HabitQuest source workspace (Linux tooling image)"
LABEL org.opencontainers.image.source="https://github.com/tools-automation/habitquest"
LABEL org.opencontainers.image.documentation="https://github.com/tools-automation/habitquest/wiki"

WORKDIR /workspace

RUN groupadd -r habituser && useradd -r -g habituser -u 1001 habituser

COPY --from=builder --chown=habituser:habituser /app /workspace

USER habituser

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD test -f /workspace/Package.swift || exit 1

CMD ["/bin/sh", "-lc", "echo 'habitquest source container ready (macOS builds app binaries)'; sleep infinity"]
