# Sandbox Environment

You are running inside a Docker-based Claude Code sandbox.

## Project

The mounted project lives at `/project`. All file operations should target this directory.

## Available tools

The following CLI tools are pre-installed:

| Tool | Purpose |
|------|---------|
| `git`, `gh` | Version control and GitHub |
| `rg` (ripgrep) | Fast text search |
| `fd` | Fast file finder |
| `bat` | Syntax-highlighted file viewer |
| `eza` | Modern `ls` replacement |
| `jq` | JSON processing |
| `xh` | HTTP client |
| `delta` | Diff viewer (git pager) |
| `lazygit` | Terminal git UI |
| `just` | Command runner |
| `watchexec` | File watcher |
| `hyperfine` | Benchmarking |
| `sd` | sed replacement |
| `dust` | Disk usage |
| `procs` | Process viewer |
| `fzf` | Fuzzy finder |
| `tmux` | Terminal multiplexer |
| `semgrep` | Static analysis |
| `chub` | API documentation (context-hub) |
| `uv` | Python package manager |
| `direnv` | Per-directory env vars |

## Network

The container has `NET_ADMIN` capability. `iptables` and `ipset` are available for network control if needed.

## User

Running as `claude` (uid 1001), non-root. Sudo is not available.
