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
        └─> home/                    # User env: shell, git, ssh, dev tools
```

### Key Design Decisions

- `flake.nix` uses helper functions (`mkDarwinConfig`, `mkNixosConfig`) to generate host configurations.
- `modules/nixos/` exists as a placeholder for future NixOS hosts.
- Darwin uses role-based layering: host identity in `hosts/darwin/<host>/default.nix`, shared Darwin config in `modules/darwin/{apps,homebrew,system}.nix`, host-specific packages in `modules/darwin/roles/{personal,work}.nix`.
- Home Manager uses a layered layout: `home/base/` (core user defaults), `home/profiles/` (reusable user contexts), and `home/hosts/` (per-host overrides).
- 1Password integration spans SSH agent (`home/base/ssh.nix`), git signing (`home/base/git.nix`), and Homebrew casks.
- `nixpkgs-unstable` is the active package channel.

## Package Add Workflow (nix-darwin)

When the user asks to add a package:

1. Check **both** nixpkgs (unstable) and Homebrew (formula/cask) for availability.
2. If only one has the package, use that package manager.
3. If both have it, compare versions and ask the user which manager/version to use.
4. Prefer **Nix** for CLI tools. Prefer **Homebrew casks** for GUI apps unless Nix is the only option.
5. Apply changes:
   - Nix packages → `modules/darwin/apps.nix` (place in the relevant section).
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
