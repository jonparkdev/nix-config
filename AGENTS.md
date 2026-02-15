# AGENTS.md

Guidance for Codex when working in this repository.

**Always read `RUNBOOK.md` at the start of a session.**

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
   - `sudo darwin-rebuild switch --flake .#macbook`
