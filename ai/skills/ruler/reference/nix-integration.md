# Nix Integration Details

This documents how ruler is declaratively managed in the nix-config.

## Module: `modules/home/ruler.nix`

A custom home-manager module that:

1. **Builds ruler from source** via `buildNpmPackage` (pinned to a specific version/hash)
2. **Defines nix options** for `programs.ruler.{enable, rules, agents, projectRoot}`
3. **Generates config files** from nix attrsets:
   - Each rule: `~/.config/ruler/<name>.md` (symlinked from source)
   - Agent mapping: `~/.config/ruler/ruler.toml` (generated TOML)
4. **Runs `ruler apply`** as a home-manager activation hook (after `writeBoundary`)

### Module Options

```nix
programs.ruler = {
  enable = lib.mkEnableOption "ruler AI config fan-out tool";

  package = lib.mkOption {
    type = lib.types.package;
    default = rulerPkg;  # Built-in buildNpmPackage derivation
  };

  projectRoot = lib.mkOption {
    type = lib.types.str;
    default = config.home.homeDirectory;  # ~ by default
  };

  rules = lib.mkOption {
    type = lib.types.attrsOf lib.types.path;
    default = { };
    # Maps name → path; each becomes ~/.config/ruler/<name>.md
  };

  agents = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule {
      options = {
        enable = lib.mkOption { type = lib.types.bool; default = true; };
        outputPath = lib.mkOption { type = lib.types.str; };
      };
    });
    default = { };
  };
};
```

### Activation Hook

The module registers a home-manager activation that runs after file symlinks are created:

```bash
ruler apply \
  --project-root <projectRoot> \
  --config ~/.config/ruler/ruler.toml \
  --no-backup \
  --no-gitignore
```

`--no-backup` and `--no-gitignore` are used because nix manages the source files — there's no need for ruler to create backups or modify `.gitignore`.

### Generated Files

After `darwin-rebuild switch`:

| Generated File | Source |
|----------------|--------|
| `~/.config/ruler/general.md` | Symlink → nix store copy of `ai/ruler/rules/AGENTS.md` |
| `~/.config/ruler/commits.md` | Symlink → nix store copy of `ai/ruler/rules/commits.md` |
| `~/.config/ruler/planning.md` | Symlink → nix store copy of `ai/ruler/rules/planning.md` |
| `~/.config/ruler/nix-package-management.md` | Symlink → nix store copy of `ai/ruler/rules/nix-package-management.md` |
| `~/.config/ruler/ruler.toml` | Generated from `programs.ruler.agents` attrset |
| `~/.claude/CLAUDE.md` | Ruler output (concatenated rules) |
| `~/.codex/AGENTS.md` | Ruler output (concatenated rules) |
| `~/.gemini/GEMINI.md` | Ruler output (concatenated rules) |

## Feature Configuration: `home/features/ai.nix`

This is where ruler is actually configured for use:

```nix
{ pkgs, claude-code-nix, ... }:
{
  home.packages = [ claude-code-nix.packages.${pkgs.system}.default ];

  programs.ruler = {
    enable = true;
    rules = {
      general              = ../../ai/ruler/rules/AGENTS.md;
      commits              = ../../ai/ruler/rules/commits.md;
      planning             = ../../ai/ruler/rules/planning.md;
      nix-package-management = ../../ai/ruler/rules/nix-package-management.md;
    };
    agents = {
      claude = { enable = true; outputPath = ".claude/CLAUDE.md"; };
      codex  = { enable = true; outputPath = ".codex/AGENTS.md"; };
      gemini = { enable = true; outputPath = ".gemini/GEMINI.md"; };
    };
  };
}
```

## Host Availability

Ruler is enabled via the `laptop` profile (`home/profiles/laptop.nix` imports `features/ai.nix`).

- `personal-macbook` — gets ruler (uses laptop profile)
- `work-macbook` — does NOT get ruler (uses work profile, which doesn't import ai.nix)

## Updating Ruler Version

To update the ruler package version, edit `modules/home/ruler.nix`:

1. Update `version` to the new release tag
2. Update `hash` (run with empty hash first, nix will tell you the correct one)
3. Update `npmDepsHash` (same approach — set to empty, rebuild, use the hash from the error)
4. Rebuild: `sudo darwin-rebuild switch --flake ~/nix-config#$(scutil --get LocalHostName)`

## Adding a Rule

1. Create the markdown file at `ai/ruler/rules/<name>.md`
2. Add to `home/features/ai.nix`:
   ```nix
   rules = {
     # ... existing rules ...
     my-new-rule = ../../ai/ruler/rules/my-new-rule.md;
   };
   ```
3. Commit and rebuild

## Adding an Agent

Add to `programs.ruler.agents` in `home/features/ai.nix`:
```nix
cursor = { enable = true; outputPath = ".cursor/rules/global.md"; };
```
Then rebuild. The ruler module generates a new `ruler.toml` with the agent entry, and `ruler apply` writes to the new output path.
