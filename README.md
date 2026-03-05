# claude-sandbox

A Docker-based sandbox for running [Claude Code](https://claude.ai/code) in an isolated environment.

## Prerequisites

- Docker with buildx support
- An Anthropic API key (or Claude Max subscription)

## Usage

**Build the image:**
```bash
./build.sh
```

**Run Claude Code against a project:**
```bash
./run.sh /path/to/your/project
```

If no path is provided, the current directory is mounted:
```bash
./run.sh
```

This drops you into an interactive Claude Code session with your project available at `/project` inside the container.

## What's included

The sandbox image includes: `git`, `gh`, `jq`, `fzf`, `vim`, `nano`, `zsh`, `curl`, and network tools (`iptables`, `ipset`, `iproute2`).

Claude Code runs as a non-root user (`claude`, uid 1001).

## Pinning a Claude Code version

To use a specific version of `@anthropic-ai/claude-code`:
```bash
docker buildx build --build-arg CLAUDE_CODE_VERSION=1.2.3 -t koenighotze/claude-sandbox:dev .
```
