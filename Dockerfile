# Build Stage
FROM swift:6.2 as builder

WORKDIR /app
COPY . .

# Resolve dependencies and build
RUN swift package resolve
RUN swift build -c release

# Output is in .build/release/

# Run Stage (Slim)
FROM swift:6.2-slim

WORKDIR /app

# Create non-root user
RUN groupadd -r swiftuser && useradd -r -g swiftuser -m swiftuser

COPY --from=builder --chown=swiftuser:swiftuser /app .

USER swiftuser

# Default to testing
CMD ["swift", "test"]
