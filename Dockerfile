# Pin UV_VERSION at build time: docker build --build-arg UV_VERSION=0.6.14 .
ARG UV_VERSION=latest
FROM ghcr.io/astral-sh/uv:${UV_VERSION} AS uv-installer

FROM ubuntu:24.04 AS builder
ARG TARGETARCH
ARG DEBIAN_FRONTEND=noninteractive

# ── Tool version manifest ──────────────────────────────────────────────────
# Override any tool: docker build --build-arg LAZYGIT_VERSION=0.62.0 .
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

# Make everything executable
RUN chmod +x /staging/bin/*

FROM node:25-slim
ARG DEBIAN_FRONTEND=noninteractive
ARG CLAUDE_CODE_VERSION=latest
ENV COLORTERM=truecolor

RUN apt-get update && apt-get install -y --no-install-recommends \
    aggregate \
    bat \
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
    man-db \
    nano \
    openssh-client \
    procps \
    ripgrep \
    tmux \
    tree \
    unzip \
    vim \
    wget \
    zsh \
    # Python (for semgrep + general use)
    python3 \
    python3-pip \
    python3-venv \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN ln -sf /usr/bin/fdfind /usr/local/bin/fd && \
    ln -sf /usr/bin/batcat /usr/local/bin/bat
COPY --from=builder /staging/bin/ /usr/local/bin/
COPY --from=uv-installer /uv /usr/local/bin/uv
RUN UV_TOOL_BIN_DIR=/usr/local/bin uv tool install semgrep
RUN echo 'eval "$(direnv hook bash)"' >> /etc/bash.bashrc

COPY sandbox-claude.md /etc/claude-defaults/CLAUDE.md
ENV CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD=/etc/claude-defaults

RUN useradd --uid 1001 --create-home --shell /bin/bash claude
RUN mkdir -p /project && chown claude:claude /project

RUN npm install -g @anthropic-ai/claude-code@${CLAUDE_CODE_VERSION} @aisuite/chub
RUN git config --system core.pager "delta" && \
git config --system interactive.diffFilter "delta --color-only" && \
git config --system delta.navigate true && \
git config --system delta.side-by-side true && \
git config --system merge.conflictstyle zdiff3

USER claude
WORKDIR /project

# Interactive sandbox — no daemon to health-check
HEALTHCHECK NONE

ENTRYPOINT ["claude", "--enable-auto-mode"]
CMD []
