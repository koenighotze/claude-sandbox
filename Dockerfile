FROM ubuntu:24.04 AS builder
ARG TARGETARCH
ARG DEBIAN_FRONTEND=noninteractive

# ── Tool version manifest ──────────────────────────────────────────────────
# Override any tool: docker build --build-arg LAZYGIT_VERSION=0.62.0 .
ARG UV_VERSION=0.6.14
ARG LAZYGIT_VERSION=0.61.1
ARG DELTA_VERSION=0.19.2
ARG EZA_VERSION=0.23.4
ARG XH_VERSION=0.25.3
ARG JUST_VERSION=1.50.0
ARG WATCHEXEC_VERSION=2.5.1
ARG HYPERFINE_VERSION=1.20.0
ARG SD_VERSION=1.1.0
ARG DUST_VERSION=1.2.4
ARG PROCS_VERSION=0.14.11
# ──────────────────────────────────────────────────────────────────────────

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl ca-certificates xz-utils unzip \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /staging/bin

# lazygit
RUN LAZYGIT_ARCH=$([ "$TARGETARCH" = "amd64" ] && echo "x86_64" || echo "arm64") && \
    curl -fsSL "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_${LAZYGIT_ARCH}.tar.gz" \
    | tar xz lazygit

# delta (git-delta)
RUN DELTA_ARCH=$([ "$TARGETARCH" = "amd64" ] && echo "x86_64-unknown-linux-musl" || echo "aarch64-unknown-linux-gnu") && \
    curl -fsSL "https://github.com/dandavison/delta/releases/download/${DELTA_VERSION}/delta-${DELTA_VERSION}-${DELTA_ARCH}.tar.gz" \
    | tar xz --strip-components=1 --wildcards '*/delta'

# eza
RUN EZA_ARCH=$([ "$TARGETARCH" = "amd64" ] && echo "x86_64-unknown-linux-musl" || echo "aarch64-unknown-linux-gnu") && \
    curl -fsSL "https://github.com/eza-community/eza/releases/download/v${EZA_VERSION}/eza_${EZA_ARCH}.tar.gz" \
    | tar xz --strip-components=1 --wildcards '*/eza'

# xh
RUN XH_ARCH=$([ "$TARGETARCH" = "amd64" ] && echo "x86_64-unknown-linux-musl" || echo "aarch64-unknown-linux-musl") && \
    curl -fsSL "https://github.com/ducaale/xh/releases/download/v${XH_VERSION}/xh-v${XH_VERSION}-${XH_ARCH}.tar.gz" \
    | tar xz --strip-components=1 --wildcards '*/xh'

# just
RUN JUST_ARCH=$([ "$TARGETARCH" = "amd64" ] && echo "x86_64-unknown-linux-musl" || echo "aarch64-unknown-linux-musl") && \
    curl -fsSL "https://github.com/casey/just/releases/download/${JUST_VERSION}/just-${JUST_VERSION}-${JUST_ARCH}.tar.gz" \
    | tar xz just

# watchexec
RUN WATCHEXEC_ARCH=$([ "$TARGETARCH" = "amd64" ] && echo "x86_64-unknown-linux-musl" || echo "aarch64-unknown-linux-musl") && \
    curl -fsSL "https://github.com/watchexec/watchexec/releases/download/v${WATCHEXEC_VERSION}/watchexec-${WATCHEXEC_VERSION}-${WATCHEXEC_ARCH}.tar.xz" \
    | xz -d | tar x --strip-components=1 --wildcards '*/watchexec'

# hyperfine
RUN HYPERFINE_ARCH=$([ "$TARGETARCH" = "amd64" ] && echo "x86_64-unknown-linux-musl" || echo "aarch64-unknown-linux-gnu") && \
    curl -fsSL "https://github.com/sharkdp/hyperfine/releases/download/v${HYPERFINE_VERSION}/hyperfine-v${HYPERFINE_VERSION}-${HYPERFINE_ARCH}.tar.gz" \
    | tar xz --strip-components=1 --wildcards '*/hyperfine'

# sd
RUN SD_ARCH=$([ "$TARGETARCH" = "amd64" ] && echo "x86_64-unknown-linux-musl" || echo "aarch64-unknown-linux-musl") && \
    curl -fsSL "https://github.com/chmln/sd/releases/download/v${SD_VERSION}/sd-v${SD_VERSION}-${SD_ARCH}.tar.gz" \
    | tar xz --strip-components=1 --wildcards '*/sd'

# dust
RUN DUST_ARCH=$([ "$TARGETARCH" = "amd64" ] && echo "x86_64-unknown-linux-musl" || echo "aarch64-unknown-linux-gnu") && \
    curl -fsSL "https://github.com/bootandy/dust/releases/download/v${DUST_VERSION}/dust-v${DUST_VERSION}-${DUST_ARCH}.tar.gz" \
    | tar xz --strip-components=1 --wildcards '*/dust'

# procs
RUN PROCS_ARCH=$([ "$TARGETARCH" = "amd64" ] && echo "x86_64-linux" || echo "aarch64-linux") && \
    curl -fsSL "https://github.com/dalance/procs/releases/download/v${PROCS_VERSION}/procs-v${PROCS_VERSION}-${PROCS_ARCH}.zip" \
    -o /tmp/procs.zip && unzip -o /tmp/procs.zip -d . && rm /tmp/procs.zip

# uv
RUN UV_ARCH=$([ "$TARGETARCH" = "amd64" ] && echo "x86_64-unknown-linux-musl" || echo "aarch64-unknown-linux-musl") && \
    curl -fsSL "https://github.com/astral-sh/uv/releases/download/${UV_VERSION}/uv-${UV_ARCH}.tar.gz" \
    | tar xz --strip-components=1 --wildcards '*/uv'

# Make everything executable
RUN chmod +x /staging/bin/*

FROM node:22-slim
ARG DEBIAN_FRONTEND=noninteractive
ARG CLAUDE_CODE_VERSION=2.1.139
ARG CHUB_VERSION=0.1.4
ENV COLORTERM=truecolor

RUN apt-get update && apt-get install -y --no-install-recommends \
    bat \
    buildah \
    ca-certificates \
    curl \
    direnv \
    dnsutils \
    fzf \
    fd-find \
    gh \
    git \
    gnupg2 \
    gpg \
    iproute2 \
    ipset \
    iptables \
    jq \
    less \
    nano \
    openssh-client \
    procps \
    ripgrep \
    tmux \
    tree \
    uidmap \
    unzip \
    vim \
    wget \
    zsh \
    # Python (for semgrep + general use)
    python3 \
    python3-venv \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN ln -sf /usr/bin/fdfind /usr/local/bin/fd && \
    ln -sf /usr/bin/batcat /usr/local/bin/bat
COPY --from=builder /staging/bin/ /usr/local/bin/
RUN UV_TOOL_BIN_DIR=/usr/local/bin uv tool install semgrep
RUN echo 'eval "$(direnv hook bash)"' >> /etc/bash.bashrc

RUN useradd --uid 1001 --create-home --shell /bin/bash claude
RUN mkdir -p /ext/project && chown claude:claude /ext /ext/project

# Allow claude to use user namespaces for rootless buildah
RUN echo "claude:100000:65536" >> /etc/subuid && \
    echo "claude:100000:65536" >> /etc/subgid

# Seed buildah config: vfs storage (no overlay/fuse needed), rootless isolation
RUN mkdir -p /etc/claude-defaults/containers && \
    printf '[storage]\ndriver = "vfs"\n' > /etc/claude-defaults/containers/storage.conf
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

USER claude
RUN git config --global core.pager "delta" && \
    git config --global interactive.diffFilter "delta --color-only" && \
    git config --global delta.navigate true && \
    git config --global delta.side-by-side true && \
    git config --global merge.conflictstyle zdiff3

COPY sandbox-claude.md /ext/CLAUDE.md
COPY statusline.sh /etc/claude-defaults/statusline.sh
COPY sandbox-settings.json /etc/claude-defaults/settings.json

ENV NPM_CONFIG_PREFIX=/home/claude/.npm-global
ENV PATH=/home/claude/.npm-global/bin:$PATH
RUN npm install -g \
    @anthropic-ai/claude-code@${CLAUDE_CODE_VERSION} \
    @aisuite/chub@${CHUB_VERSION}

WORKDIR /ext/project

# Interactive sandbox — no daemon to health-check
HEALTHCHECK NONE

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]