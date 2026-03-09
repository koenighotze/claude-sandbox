FROM node:25-slim
# FROM node:25 

ARG CLAUDE_CODE_VERSION=latest

RUN apt-get update && apt-get install -y --no-install-recommends \
    aggregate \
    ca-certificates \
    curl \
    dnsutils \
    fzf \
    gh \
    git \
    gnupg2 \
    iproute2 \
    ipset \
    iptables \
    jq \
    less \
    man-db \
    nano \
    procps \
    sudo \
    unzip \
    vim \
    zsh \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN useradd --uid 1001 --create-home --shell /bin/bash claude
RUN mkdir -p /project && chown claude:claude /project

RUN npm install -g @anthropic-ai/claude-code@${CLAUDE_CODE_VERSION}
USER claude
WORKDIR /project
# bmm (BMad Method — core framework with 34+ workflows), 
# bmb (BMad Builder — create custom agents/workflows), 
# tea (Test Architect — risk-based test strategy), 
# bmgd (Game Dev Studio — Unity/Unreal/Godot workflows), 
# cis (Creative Intelligence Suite — innovation and brainstorming).
RUN npx --yes bmad-method install \
    --directory /project \
    --modules bmm,tea \
    --tools none \
    --yes

ENTRYPOINT ["claude"]
CMD []