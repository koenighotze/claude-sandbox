# claude-sandbox

[![CI](https://github.com/koenighotze/claude-sandbox/actions/workflows/ci.yml/badge.svg)](https://github.com/koenighotze/claude-sandbox/actions/workflows/ci.yml)
[![Publish](https://github.com/koenighotze/claude-sandbox/actions/workflows/publish.yml/badge.svg)](https://github.com/koenighotze/claude-sandbox/actions/workflows/publish.yml)

A Docker-based sandbox for running [Claude Code](https://claude.ai/code) in an isolated environment.

## Prerequisites

- Docker
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

This drops you into an interactive Claude Code session with your project available at `/ext/project` inside the container.

A `claude_home/` directory is created inside the project directory and mounted as the Claude user's home. This persists Claude Code settings, chat history, and skills across container runs.

**Remove a running or stopped container:**

```bash
./rm.sh [project-dir]
```

Defaults to the current directory, matching `run.sh`'s naming scheme.

## What's included

The sandbox image includes standard tools (`git`, `gh`, `jq`, `fzf`, `vim`, `nano`, `zsh`, `curl`, `tmux`, network tools) plus these additional CLI utilities:

| Tool      | Why                                    |
|-----------|----------------------------------------|
| lazygit   | TUI for git, useful inside the sandbox |
| delta     | Syntax-highlighted git diffs           |
| eza       | Modern ls replacement                  |
| bat       | Syntax-highlighted file viewer         |
| fd        | Fast file finder                       |
| ripgrep   | Fast text search                       |
| xh        | Better httpie-style HTTP client        |
| just      | Command runner (like make but sane)    |
| watchexec | Re-run commands on file change         |
| hyperfine | CLI benchmarking                       |
| sd        | sed replacement, cleaner syntax        |
| dust      | Disk usage visualiser                  |
| procs     | Better ps                              |
| uv        | Fast Python package manager            |
| semgrep   | Static analysis / code scanning        |
| direnv    | Per-directory environment variables    |
| chub      | API documentation (context-hub)        |

Claude Code runs as a non-root user (`claude`, uid 1001).

## Default configuration

On first launch, `entrypoint.sh` seeds the following into `~/.claude/` **only if the files don't already exist**, so any customisations you make are preserved across container restarts.

### Permissions (`settings.json`)

All common Claude Code tools are allowed by default:

```
Bash(*), Read(*), Write(*), Edit(*), WebFetch(*), WebSearch(*), mcp__*__*
```

Sensitive paths are blocked regardless:

```
.env, .env.*, .env.local, .env.production, .env.staging,
**/secrets/**, **/credentials/**, **/.aws/**, **/.ssh/**
```

The built-in Claude Code sandbox is disabled (the Docker container is the isolation boundary).

### Enabled plugins

The following official plugins are enabled out of the box:

`context7`, `code-review`, `code-simplifier`, `commit-commands`, `frontend-design`, `github`, `playwright`, `ralph-loop`, `security-guidance`, `skill-creator`, `superpowers`, `claude-md-management`, `claude-code-setup`, `pr-review-toolkit`

### Status line

A custom status line script (`~/.claude/statusline.sh`) is seeded, showing:

- Active model name
- Current working directory and git branch
- Context window usage (colour-coded bar)
- Cumulative session cost and duration

### Skills

The `get-api-docs` skill (provided by `chub`) is linked into `~/.claude/skills/` on first launch. Use it to pull current API documentation for any library without leaving the session.

### Sandbox CLAUDE.md

`sandbox-claude.md` is baked into the image at `/ext/CLAUDE.md`. It gives Claude Code context about the sandbox environment (available tools, network capabilities, user setup) and is loaded automatically by Claude Code as a project-level instruction file.

## Pinning versions

**Claude Code:**

```bash
docker build --build-arg CLAUDE_CODE_VERSION=1.2.3 -t claude-sandbox:dev .
```

**Individual CLI tools** — every pre-installed binary has a corresponding build arg:

```bash
docker build \
  --build-arg LAZYGIT_VERSION=0.62.0 \
  --build-arg DELTA_VERSION=0.18.0 \
  --build-arg UV_VERSION=0.6.14 \
  -t claude-sandbox:dev .
```

Available args: `UV_VERSION`, `LAZYGIT_VERSION`, `DELTA_VERSION`, `EZA_VERSION`, `XH_VERSION`, `JUST_VERSION`, `WATCHEXEC_VERSION`, `HYPERFINE_VERSION`, `SD_VERSION`, `DUST_VERSION`, `PROCS_VERSION`, `CHUB_VERSION`.
