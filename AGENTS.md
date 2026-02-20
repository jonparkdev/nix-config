# AGENTS.md

Guidance for Codex when working in this repository.

**Always read `RUNBOOK.md` at the start of a session.**

## Build Commands

```bash
# Rebuild system after changes (primary workflow, requires sudo)
sudo darwin-rebuild switch --flake .#personal-macbook
# or
sudo darwin-rebuild switch --flake .#work-macbook

# Initial setup (first time only)
sudo nix run nix-darwin -- switch --flake .

# Update all flake inputs
nix flake update

# Validate flake without building
nix flake check

# Format nix files (nixfmt is installed via apps.nix)
nixfmt .

# Garbage collect old generations
nix-collect-garbage -d
```

## Architecture

This is a Nix flake-based macOS (nix-darwin) configuration with home-manager for user-level settings.

### Configuration Flow

```text
flake.nix                           # Entry point: inputs, mkDarwinConfig/mkNixosConfig helpers
  ├─> hosts/darwin/personal-macbook/ # Host identity: hostname, user
  └─> hosts/darwin/work-macbook/     # Host identity: hostname, user
        ├─> modules/shared/          # Cross-platform: nix daemon, gc, experimental features
        ├─> modules/darwin/          # macOS: shared settings + role-based packages/casks
        └─> home/                    # User env: shell, git, ssh, AI CLI config, dev tools
```

### Directory Responsibilities

Use this map when deciding where changes belong:

- `hosts/`: machine identity and module composition only. Keep package lists and policy out of host files.
- `modules/shared/`: platform-agnostic Nix behavior (`nix.*`, cache settings, GC, feature flags).
- `modules/darwin/`: macOS system behavior and shared Darwin packages/casks.
- `modules/darwin/roles/`: minimal role deltas (`personal`/`work`) layered on top of shared Darwin modules.
- `modules/nixos/`: placeholder for future Linux-specific modules; do not put active Darwin logic here.
- `home/base/`: user defaults that should apply everywhere (shell/git/ssh/AI CLI settings).
- `home/profiles/`: reusable user contexts selected per host via `homeProfiles`.
- `home/hosts/`: narrow host-only user overrides.

Roles vs profiles:

- Darwin roles (`modules/darwin/roles/*.nix`) are machine-level deltas.
- Home profiles (`home/profiles/*.nix`) are user-level composition bundles.
- If a change affects system packages/casks or OS behavior, prefer roles.
- If a change affects user environment composition across hosts, prefer profiles.
- For package placement, prefer Home Manager (`home.packages`) for user CLI tools and `modules/darwin/apps.nix` for machine-level runtimes/apps.

Escalation rule for placement:

1. Start specific (role/host).
2. Promote to shared only when at least two hosts or roles need the same behavior.
3. Keep `flake.nix` focused on wiring and metadata, not concrete settings.

### Key Design Decisions

- `flake.nix` uses helper functions (`mkDarwinConfig`, `mkNixosConfig`) to generate host configurations.
- `modules/nixos/` exists as a placeholder for future NixOS hosts.
- Darwin uses role-based layering: host identity in `hosts/darwin/<host>/default.nix`, shared Darwin config in `modules/darwin/{apps,homebrew,system}.nix`, host-specific packages in `modules/darwin/roles/{personal,work}.nix`.
- Home Manager uses a layered layout: `home/base/` (core user defaults), `home/profiles/` (reusable user contexts), and `home/hosts/` (per-host overrides).
- 1Password integration spans SSH agent (`home/base/ssh.nix`), git signing (`home/base/git.nix`), and Homebrew casks.
- AI CLI defaults are managed in `home/base/ai.nix` (currently Claude status line settings).
- `nixpkgs-unstable` is the active package channel.

## Package Add Workflow (nix-darwin)

When the user asks to add a package:

1. Check **both** nixpkgs (unstable) and Homebrew (formula/cask) for availability.
2. If only one has the package, use that package manager.
3. If both have it, compare versions and ask the user which manager/version to use.
4. Prefer **Nix** for CLI tools and place them in Home Manager (`home.packages`) when they are user-level tools. Prefer **Homebrew casks** for GUI apps unless Nix is the only option.
5. Apply changes:
   - User-level Nix CLI packages → `home/base/*.nix` via `home.packages`.
   - Machine-level Nix packages/runtime tooling → `modules/darwin/apps.nix`.
   - Homebrew casks → `modules/darwin/homebrew.nix` under `homebrew.casks`.
   - Homebrew CLI formulae (if chosen) → add `homebrew.brews` in `modules/darwin/homebrew.nix` if it doesn’t exist.
6. After edits, ask for confirmation, then run:
   - `sudo darwin-rebuild switch --flake .#personal-macbook`
   - or `sudo darwin-rebuild switch --flake .#work-macbook`

## Adding a New Host

1. Create `hosts/darwin/<name>/default.nix` (or `hosts/nixos/<name>/`).
2. Add host metadata in `flake.nix`:
   - `system`
   - `role`
   - `homeProfiles` (for example `["laptop" "work"]`)
   - optional flags (for example `enableLinuxBuilder`)
3. Add role behavior in `modules/darwin/roles/<role>.nix` (or `modules/nixos/roles/<role>.nix` when added).
