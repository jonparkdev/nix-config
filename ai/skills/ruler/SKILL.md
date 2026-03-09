---
name: ruler
description: >
  Manage AI agent rules with Ruler. Activate when the user wants to update global AI rules,
  add a rule for something, sync their AI config, set up project-level rules, initialize ruler
  in a project, or write/improve rule files. Also activate when the user says "update my rules",
  "add a rule for X", "rebuild my nix config", "set up rules for this project".
---

# Ruler

Ruler fans a single set of rules out to all AI agents (Claude, Codex, Gemini, etc.).

## Global Workflow (declarative, nix-managed)

Global rules live in `~/nix-config/ai/ruler/rules/` and are rebuilt on every `darwin-rebuild switch`.

1. **Edit** the relevant rule file:
   - `global.md` — applies to all agents
   - `claude.md` — Claude Code-specific additions
2. **Commit**:
   ```
   git -C ~/nix-config add ai/ruler/rules/
   git -C ~/nix-config commit -m "chore(ai): <description>"
   ```
3. **Push**: `git -C ~/nix-config push`
4. **Rebuild**:
   ```
   sudo darwin-rebuild switch --flake ~/nix-config#$(scutil --get LocalHostName)
   ```
   Home-manager activation automatically runs `ruler apply`, writing rules to
   `~/.claude/CLAUDE.md`, `~/.codex/AGENTS.md`, and `~/.gemini/GEMINI.md`.

## Local Workflow (project-specific, imperative)

For rules scoped to a single project repo:

1. **Initialize** (once per project):
   ```
   cd /path/to/project
   ruler init
   ```
   Creates `.ruler/ruler.toml` and `.ruler/AGENTS.md`.
2. **Add rule files** following best practices (see below). Edit `.ruler/AGENTS.md` or add focused files.
3. **Apply**:
   ```
   ruler apply
   ```
   Ruler fans rules to all enabled agents in the project.
4. **Commit** the `.ruler/` directory to the project repo so teammates get the same rules.

Local rules take precedence over global rules when running inside a project that has a `.ruler/` directory.

## Best Practices for Rule Files

- **One concern per file.** Break rules into focused `.md` files rather than one large file.
  Good examples: `coding_style.md`, `api_conventions.md`, `security_guidelines.md`, `testing.md`.
- **Use clear section headers** within each file so agents can navigate quickly.
- **Keep rules actionable.** Prefer "Use `rg` for search" over "search efficiently".
- **Preview before applying**: `ruler apply --dry-run` shows what will change without writing files.
- **Version rule files** in git. For global rules, that's nix-config. For project rules, the project repo.
- **Avoid duplication** between global and project rules. Global rules apply everywhere; project
  rules should only add project-specific context.

## Adding a New Agent

Edit `programs.ruler.agents` in `~/nix-config/home/features/ai.nix`:
```nix
cursor = { enable = true; outputPath = ".cursor/rules/global.md"; };
```
Then run the global workflow to rebuild.

## CLI Reference

| Command | Description |
|---------|-------------|
| `ruler init` | Initialize `.ruler/` in current directory |
| `ruler init --global` | Initialize global config at `~/.config/ruler/` |
| `ruler apply` | Fan rules out to all configured agents |
| `ruler apply --dry-run` | Preview changes without writing |
| `ruler apply --agents claude,codex` | Target specific agents only |
| `ruler apply --no-gitignore` | Skip `.gitignore` updates |
| `ruler apply --no-backup` | Skip `.bak` backup files |
| `ruler apply --local-only` | Skip global config fallback |
| `ruler apply --nested` | Load rules from parent directories too |
| `ruler revert` | Undo all changes from last apply |
| `ruler revert --dry-run` | Preview what revert would undo |
