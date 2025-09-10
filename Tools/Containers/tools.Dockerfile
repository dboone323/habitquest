FROM ubuntu:22.04
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    bash curl git ca-certificates python3 python3-pip jq ripgrep && \
    rm -rf /var/lib/apt/lists/*
WORKDIR /workspace
