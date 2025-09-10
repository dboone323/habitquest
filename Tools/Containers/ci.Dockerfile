FROM swift:5.10-jammy

# Utilities
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    curl git ca-certificates python3 python3-pip jq ripgrep gnupg \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 20.x via NodeSource setup script, then cspell
RUN set -eux; \
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash -; \
    DEBIAN_FRONTEND=noninteractive apt-get install -y nodejs; \
    npm i -g cspell@8; \
    node -v && npm -v && cspell --version

WORKDIR /workspace
