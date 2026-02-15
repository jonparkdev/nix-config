# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

**Always read `RUNBOOK.md` at the start of a session.** It contains operational knowledge: how the linux-builder works, debugging steps, and common gotchas.

## Build Commands

```bash
# Rebuild system after changes (primary workflow, requires sudo)
sudo darwin-rebuild switch --flake .#macbook

# Initial setup (first time only)
sudo nix run nix-darwin -- switch --flake .

# Update all flake inputs
nix flake update

# Validate flake without building
nix flake check

# Format nix files (nixfmt-rfc-style is installed via apps.nix)
nixfmt .

# Garbage collect old generations
nix-collect-garbage -d
```

## Architecture

This is a Nix flake-based macOS (nix-darwin) system configuration with home-manager for user-level settings.

### Configuration Flow

```
flake.nix                          # Entry point: inputs, mkDarwinConfig/mkNixosConfig helpers
  └─> hosts/darwin/macbook/        # Host-specific: hostname, user, dock apps
        ├─> modules/shared/        # Cross-platform: nix daemon, gc, experimental features
        ├─> modules/darwin/        # macOS: system prefs, packages, homebrew casks
        └─> home/                  # User env: shell, git, ssh, dev tools
```

### Key Design Decisions

- **`flake.nix` uses helper functions** (`mkDarwinConfig`, `mkNixosConfig`) to generate host configurations — new hosts are added by calling these with host-specific paths and system architecture.
- **`modules/nixos/`** exists as a placeholder for future NixOS hosts (e.g., homelab).
- **Nix packages vs Homebrew casks**: CLI tools go in `modules/darwin/apps.nix` as nix packages; GUI-only apps that need Homebrew go in `modules/darwin/homebrew.nix`.
- **1Password integration** is central: SSH agent (`home/ssh.nix`), git commit signing (`home/git.nix`), and the app itself (homebrew cask).
- **nixpkgs-unstable** channel is used for all packages.

### Package Add Workflow (nix-darwin)

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
   - `sudo darwin-rebuild switch --flake .#macbook`

### Adding a New Host

1. Create `hosts/darwin/<name>/default.nix` (or `hosts/nixos/<name>/`)
2. Add the host to `flake.nix` outputs using `mkDarwinConfig` or `mkNixosConfig`
3. The host file sets hostname, username, and imports modules + home
