# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This repository provides a Docker-based sandbox for running Claude Code in an isolated environment. It builds a Docker image with Claude Code pre-installed and mounts a local project directory into the container.

## Commands

**Build the image:**
```bash
./build.sh
```
Builds the image tagged as `koenighotze/claude-sandbox:dev`.

**Run the sandbox:**
```bash
./run.sh [project-dir]
```
Mounts `project-dir` (defaults to `$PWD`) into the container at `/project` and launches Claude Code interactively. The container is named `claude-sandbox`.

## Architecture

- `Dockerfile` — Based on `node:25-slim`. Creates a non-root user `claude` (uid 1001), installs system tools (git, gh, jq, vim, zsh, iptables/ipset for network control, etc.), installs `@anthropic-ai/claude-code` globally via npm, and sets `/project` as the working directory.
- `build.sh` — Thin wrapper around `docker buildx build`.
- `run.sh` — Runs the container interactively with a bind mount of the target project. Accepts an optional path argument; defaults to `$PWD`.

The `CLAUDE_CODE_VERSION` build arg controls which version of `@anthropic-ai/claude-code` is installed (defaults to `latest`).
