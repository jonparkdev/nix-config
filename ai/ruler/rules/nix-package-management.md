# Package Add Workflow

All packages are managed via nix-darwin in `~/nix-config`.

When adding a package:

1. Check **both** nixpkgs (unstable) and Homebrew for availability.
2. If only one has it, use that.
3. If both have it, compare versions. Default to Nix for CLI tools, Homebrew for GUI apps — but ask the user to confirm when versions differ significantly.
4. Apply changes:
   - Nix packages → `modules/darwin/apps.nix` (place in the relevant section).
   - Homebrew casks → `modules/darwin/homebrew.nix` under `homebrew.casks`.
   - Homebrew formulae → `modules/darwin/homebrew.nix` under `homebrew.brews`.
5. Ask for confirmation, then: `sudo darwin-rebuild switch --flake .#personal-macbook` (or `#work-macbook`)
