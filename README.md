<h2 align="center">nix-config</h2>

<p align="center">Declarative macOS setup with nix-darwin, home-manager, and ruler.</p>

<p align="center">
  <a href="https://lix.systems/">
    <img alt="Lix" src="https://img.shields.io/badge/Lix-Nix-informational?style=for-the-badge&logo=nixos&color=F2CDCD&logoColor=D9E0EE&labelColor=302D41" />
  </a>
  <a href="https://github.com/LnL7/nix-darwin">
    <img alt="nix-darwin" src="https://img.shields.io/badge/nix--darwin-macOS-informational?style=for-the-badge&logo=apple&color=B5E8E0&logoColor=D9E0EE&labelColor=302D41" />
  </a>
</p>

## Overview

A "learn Nix in public" configuration for managing macOS machines with [nix-darwin](https://github.com/LnL7/nix-darwin) and [home-manager](https://github.com/nix-community/home-manager). Intentionally readable so other people learning Nix can copy patterns (or avoid mistakes) without digging through a giant abstraction maze.

This is not "the perfect Nix setup." It is a setup I understand, improve over time, and document what I learn.

**Current scope:**

| | |
|---|---|
| Platform | macOS (`aarch64-darwin`) |
| Hosts | `personal-macbook`, `work-macbook` |
| Nix implementation | [Lix](https://lix.systems/) (standard Nix works too) |
| NixOS | Scaffold exists, no active hosts yet |

## Quick Start

### 1. Install Nix

With Lix (what I use):

```bash
curl -sSf -L https://install.lix.systems/lix | sh -s -- install
```

Or standard Nix:

```bash
sh <(curl -L https://nixos.org/nix/install)
```

### 2. Clone and apply

```bash
git clone https://github.com/jonparkdev/nix-config.git ~/nix-config
cd ~/nix-config
sudo nix run nix-darwin -- switch --flake .
```

### 3. Rebuild

```bash
sudo darwin-rebuild switch --flake .#personal-macbook
# or
sudo darwin-rebuild switch --flake .#work-macbook
```

> [!TIP]
> After the first build, `scutil --get LocalHostName` returns the nix-managed hostname, so you can rebuild with:
> ```bash
> sudo darwin-rebuild switch --flake .#$(scutil --get LocalHostName)
> ```

## Repository Layout

```text
.
├── flake.nix                           # Flake inputs + host definitions
├── hosts/darwin/
│   ├── personal-macbook/default.nix    # Machine identity + profile selection
│   └── work-macbook/default.nix
├── modules/
│   ├── shared/nix-core.nix             # Nix settings shared across platforms
│   ├── darwin/
│   │   ├── system.nix                  # macOS system defaults
│   │   ├── apps.nix                    # Nix packages (system-level)
│   │   ├── homebrew.nix                # Homebrew casks + formulae
│   │   ├── dock.nix                    # Dock layout
│   │   ├── builders.nix                # Remote/Linux builders
│   │   └── roles/                      # Machine-level deltas (personal, work)
│   ├── nixos/                          # Reserved for future Linux hosts
│   └── home/ruler.nix                  # Home-manager module for ruler
├── home/
│   ├── default.nix                     # Home-manager wiring + profile composition
│   ├── base/                           # User defaults for all hosts (shell, git, ssh)
│   ├── features/                       # Opt-in capabilities (dev tools, AI, hammerspoon)
│   ├── profiles/                       # Composable bundles (laptop, work, server-admin)
│   └── hosts/                          # Last-mile per-host overrides
├── ai/
│   ├── ruler/rules/                    # AI agent rule source files
│   └── skills/                         # Claude Code skills (ruler, create-readme)
└── RUNBOOK.md                          # Operational notes + troubleshooting
```

## Architecture

### Layer Model

Changes stay local and predictable because each layer has a single job:

| Layer | Location | Scope |
|-------|----------|-------|
| **Host** | `hosts/` | Machine identity only (hostname, user wiring, imports) |
| **Shared modules** | `modules/shared/` | Nix core behavior across all platforms |
| **Darwin modules** | `modules/darwin/` | macOS system layer (defaults, Homebrew, Dock) |
| **Roles** | `modules/darwin/roles/` | Machine-level deltas (`personal` vs `work`) |
| **Base** | `home/base/` | User defaults common to all hosts |
| **Features** | `home/features/` | Opt-in capabilities selected by profiles |
| **Profiles** | `home/profiles/` | Composable user-level bundles per host |
| **Host overrides** | `home/hosts/` | Last-mile tweaks when a profile is too broad |

Rule of thumb: if a change applies to many machines, move it **up** (shared/base/profile). If it applies to one machine, keep it **down** (role/host).

### Roles vs Profiles

This is the most common point of confusion:

- **Roles** (`modules/darwin/roles/`) are system-level machine deltas (Homebrew casks, OS defaults).
- **Profiles** (`home/profiles/`) are user-level composable bundles (dev tools, AI config).

Examples from this repo:

- `role = "work"` adds `slack` and `aws-vpn-client` at the system level.
- `homeProfiles = ["laptop" "work"]` composes user-level contexts for that host.

### Package Placement

| Where | When | Examples |
|-------|------|----------|
| `home/base/*` via `home.packages` | User-facing CLI tools (cross-platform reuse) | `gh`, `kubectl`, `k9s`, `nixfmt` |
| `modules/darwin/apps.nix` | Machine-level apps/runtimes | `colima`, `docker`, fonts |
| `modules/darwin/homebrew.nix` | GUI macOS apps | Casks via Homebrew |

## AI Agent Configuration

AI agent rules are managed declaratively with [ruler](https://github.com/intellectronica/ruler), which fans a single set of markdown rules to all agents on every rebuild.

```
ai/ruler/rules/*.md  →  home/features/ai.nix  →  darwin-rebuild  →  ruler apply
                                                                        ├── ~/.claude/CLAUDE.md
                                                                        ├── ~/.codex/AGENTS.md
                                                                        └── ~/.gemini/GEMINI.md
```

Rules are focused markdown files (`AGENTS.md`, `commits.md`, `planning.md`, `nix-package-management.md`), registered in `home/features/ai.nix` and applied automatically during activation.

Claude Code skills live in `ai/skills/` and are available as slash commands.

## Daily Workflow

```bash
# Rebuild after config changes
sudo darwin-rebuild switch --flake .#$(scutil --get LocalHostName)

# Validate flake outputs
nix flake check

# Update inputs
nix flake update

# Format nix files
nixfmt .

# Clean old generations + unreachable store paths
nix-collect-garbage -d
```

For builder troubleshooting and operational notes, see `RUNBOOK.md`.

## Philosophy

- Learn by building and using the config daily
- Keep modules boring and explicit over clever
- Prefer Nix for CLI tools, Homebrew casks for GUI apps
- Minimize role-specific customization

## Reference Repos

Configs I keep going back to when learning:

- [dustinlyons/nixos-config](https://github.com/dustinlyons/nixos-config)
- [ryan4yin/nix-config](https://github.com/ryan4yin/nix-config)
- [mitchellh/nixos-config](https://github.com/mitchellh/nixos-config)
