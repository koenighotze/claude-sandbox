# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This repository provides a Docker-based sandbox for running Claude Code in an isolated environment. It builds a Docker image with Claude Code pre-installed and mounts a local project directory into the container.

## Commands

**Build the image:**
```bash
./build.sh
```
Builds the image tagged as `claude-sandbox:dev`.

**Run the sandbox:**
```bash
./run.sh [project-dir]
```
Mounts `project-dir` (defaults to `$PWD`) into the container at `/ext/project` and launches Claude Code interactively. The container is named `claude-sandbox-<project-name>` and is started with `--rm`, so it is removed automatically on exit.

**Remove a stuck container:**
```bash
./rm.sh [project-dir]
```
Resolves the project name the same way `run.sh` does, so it targets the matching `claude-sandbox-<project-name>` container.

## Architecture

- `Dockerfile` — Based on `node:25-slim`. Creates a non-root user `claude` (uid 1001), installs system tools (git, gh, jq, vim, zsh, iptables/ipset for network control, etc.), installs `@anthropic-ai/claude-code` globally via npm, and sets `/ext/project` as the working directory.
- `build.sh` — Thin wrapper around `docker build`.
- `run.sh` — Runs the container interactively with a bind mount of the target project. Accepts an optional path argument; defaults to `$PWD`.
- `rm.sh` — Force-removes the `claude-sandbox-<project-name>` container for the given project dir (defaulting to `$PWD`) if it is still around. Rarely needed, since `run.sh` uses `--rm`.

The `CLAUDE_CODE_VERSION` build arg controls which version of `@anthropic-ai/claude-code` is installed (defaults to `latest`).
