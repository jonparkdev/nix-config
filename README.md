<h2 align="center">My Nix Configuration (macOS + NixOS [coming soon])</h2>

<p align="center">
  <a href="https://lix.systems/">
    <img alt="Lix" src="https://img.shields.io/badge/Lix-Nix-informational?style=for-the-badge&logo=nixos&color=F2CDCD&logoColor=D9E0EE&labelColor=302D41" />
  </a>
  <a href="https://github.com/LnL7/nix-darwin">
    <img alt="nix-darwin" src="https://img.shields.io/badge/nix--darwin-macOS-informational?style=for-the-badge&logo=apple&color=B5E8E0&logoColor=D9E0EE&labelColor=302D41" />
  </a>
</p>

<p align="center">Welcome to my Nix configuration!</p>

## Overview

This repo is my "learn Nix in public" project.

I use it every day to manage my macOS machines with `nix-darwin` + `home-manager`, and I keep it intentionally readable so other people learning Nix can copy patterns (or avoid mistakes) without digging through a giant abstraction maze.

I am not trying to present this as "the perfect Nix setup." I am trying to build a setup I understand, improve it over time, and document what I learn.

If you are new to Nix, feel free to use this as reference material. If you run it as-is, you will get my machine defaults, so fork first and make it yours.

## Current Scope

- Platform in active use: macOS (`aarch64-darwin`)
- Hosts:
1. `personal-macbook`
2. `work-macbook`
- NixOS: scaffold exists (`modules/nixos/`) but no active hosts yet
- Nix implementation: [Lix](https://lix.systems/) (standard Nix works too)

## Philosophy

- Learn by building and using the config daily.
- Keep modules boring and explicit over clever.
- Prefer Nix for CLI tooling.
- Prefer Homebrew casks for GUI apps that integrate better with macOS.
- Keep role-specific customization minimal (`personal` vs `work`).

## Repository Layout

```text
.
├── flake.nix
├── hosts/
│   └── darwin/
│       ├── personal-macbook/default.nix
│       └── work-macbook/default.nix
├── modules/
│   ├── shared/
│   │   └── nix-core.nix
│   ├── darwin/
│   │   ├── default.nix
│   │   ├── system.nix
│   │   ├── apps.nix
│   │   ├── homebrew.nix
│   │   ├── dock.nix
│   │   ├── builders.nix
│   │   └── roles/
│   │       ├── personal.nix
│   │       └── work.nix
│   └── nixos/
│       └── default.nix
├── home/
│   ├── default.nix
│   ├── base/
│   │   ├── shell.nix
│   │   ├── git.nix
│   │   ├── ssh.nix
│   │   └── ai.nix
│   ├── features/
│   │   ├── dev.nix
│   │   └── hammerspoon.nix
│   ├── profiles/
│   │   ├── laptop.nix
│   │   ├── server-admin.nix
│   │   └── work.nix
│   └── hosts/
│       └── personal-macbook.nix
└── RUNBOOK.md
```

## Why This Structure

This split is intentional so changes stay local and predictable:

- `hosts/`: machine identity only (`hostname`, user wiring, imports). Avoid putting package logic here.
- `modules/shared/`: Nix core behavior shared across platforms (`nix.*`, GC, substituters, features).
- `modules/darwin/`: macOS system layer (`system.defaults`, Homebrew, Dock, optional builder).
- `modules/darwin/roles/`: role-level differences (`personal` vs `work`) without duplicating base config.
- `modules/nixos/`: reserved for future Linux hosts so expansion does not require a repo reshape.
- `home/base/`: user defaults common to all hosts (shell/git/ssh/AI CLI settings).
- `home/profiles/`: reusable bundles selected per host (`laptop`, `work`, `server-admin`).
- `home/hosts/`: last-mile host overrides when a profile is too broad.

A quick rule of thumb: if a change applies to many machines, move it "up" (shared/base/profile). If it applies to one machine, keep it "down" (role/host).

### Roles vs Profiles

This is the most common point of confusion in this repo:

- Darwin roles (`modules/darwin/roles/*.nix`) are system-level machine deltas.
- Home profiles (`home/profiles/*.nix`) are user-level reusable bundles.

In practice:

- Use a role when you are changing machine behavior (system packages, Homebrew casks, OS-level defaults).
- Use a profile when you are changing user environment composition and want mix-and-match bundles per host.

Examples from this repo:

- `role = "work"` adds work machine deltas like `slack` and `aws-vpn-client`.
- `homeProfiles = ["laptop" "work"]` composes user-level contexts for that host.

## Getting Started

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

### 3. Rebuild for a host

```bash
sudo darwin-rebuild switch --flake .#personal-macbook
# or
sudo darwin-rebuild switch --flake .#work-macbook
```

## Daily Workflow

```bash
# Validate flake outputs/evaluation
nix flake check

# Update inputs
nix flake update

# Format nix files
nixfmt .

# Clean old generations + unreachable store paths
nix-collect-garbage -d
```

For builder troubleshooting and operational notes, read `RUNBOOK.md` first.

## What This Repo Optimizes For

- Reproducible local setup
- Fast rebuild loop on macOS
- Clear host/role/profile boundaries
- A public paper trail of what I am learning in Nix

## Reference Repos

These are the configs that most influenced how I think about structure and workflow:

- [dustinlyons/nixos-config](https://github.com/dustinlyons/nixos-config)
- [ryan4yin/nix-config](https://github.com/ryan4yin/nix-config)
- [mitchellh/nixos-config](https://github.com/mitchellh/nixos-config)

## License

MIT
