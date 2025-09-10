FROM node:20-bookworm-slim
RUN npm i -g cspell@8
WORKDIR /workspace
