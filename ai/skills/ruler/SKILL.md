---
name: ruler
description: >
  Manage AI agent rules with Ruler — a CLI tool that fans a single set of markdown rules
  out to all AI agents (Claude, Codex, Gemini, Copilot, Cursor, etc.). Use when the user wants to
  add/edit/remove rules, sync AI config, set up project-level rules, initialize ruler in a project,
  write or improve rule files, add a new agent target, or troubleshoot rule fan-out. Also activate
  when the user says "update my rules", "add a rule for X", "set up rules for this project",
  "sync my AI config", or "what rules do I have".
---

# Ruler

Ruler provides a single source of truth for AI agent instructions. Write rules once in Markdown, and ruler distributes them to every configured agent's native config format.

**Repo**: [intellectronica/ruler](https://github.com/intellectronica/ruler)

## Quick Reference

| Command | What it does |
|---------|-------------|
| `ruler init` | Scaffold `.ruler/` in current project |
| `ruler init --global` | Scaffold global config at `~/.config/ruler/` |
| `ruler apply` | Fan rules out to all configured agents |
| `ruler apply --dry-run` | Preview changes without writing |
| `ruler apply --agents claude,codex` | Target specific agents only |
| `ruler revert` | Undo last apply (restores from `.bak` files) |
| `ruler revert --dry-run` | Preview what revert would undo |

For full CLI flags, see [reference/cli.md](reference/cli.md).

## Core Concepts

### How It Works

1. You write rules as `.md` files in `.ruler/` (local) or `~/.config/ruler/` (global)
2. `ruler.toml` maps agent names to output paths
3. `ruler apply` concatenates all rule files (sorted alphabetically) and writes them to each agent's config file
4. Each rule gets a source marker: `<!-- Source: ruler/filename.md -->`

### Global vs Local Rules

| Scope | Location | When to use |
|-------|----------|-------------|
| **Global** | `~/.config/ruler/` | Cross-project defaults (commit style, general preferences) |
| **Local** | `.ruler/` in project root | Project-specific context (architecture, conventions, workflows) |

Search order: local `.ruler/` first (walks up directory tree), falls back to global config. Use `--local-only` to skip global fallback.

### Supported Agents (30+)

Claude, Codex, Gemini CLI, Copilot, Cursor, Windsurf, Cline, Aider, Roo, JetBrains AI, Zed, Warp, and many more. Run `ruler apply --help` to see the full list.

## Workflows

### Add a New Rule

1. Create a focused `.md` file — one concern per file:
   ```
   # Testing Guidelines

   - Run the full test suite before committing: `npm test`
   - Write tests for all new functions. Prefer integration tests over unit tests.
   - Use descriptive test names that explain the expected behavior.
   ```
2. Place it in the rules directory (global or local)
3. Apply: `ruler apply`

### Add a New Agent Target

Add to `ruler.toml`:
```toml
[agents.cursor]
enabled = true
output_path = ".cursor/rules/global.md"
```
Then `ruler apply`.

### Set Up a New Project (Imperative)

```bash
cd /path/to/project
ruler init           # Creates .ruler/ruler.toml and starter files
# Edit .ruler/ rule files
ruler apply          # Fan out to agents
# Commit .ruler/ to the project repo
```

### Troubleshoot

- **Rules not appearing**: Check `ruler apply --dry-run` output and verify file paths in `ruler.toml`
- **Wrong agent getting rules**: Check `ruler.toml` — ensure `enabled = true` and `output_path` is correct
- **Undo changes**: `ruler revert` restores from `.bak` files (only works if `--no-backup` wasn't used)

## Rule Writing Best Practices

- **One concern per file**: `commits.md`, `testing.md`, `security.md` — not one giant file
- **Actionable over aspirational**: "Use `rg` for search" not "search efficiently"
- **Use clear headings**: Agents parse markdown structure for navigation
- **Keep files short**: Each rule file should be scannable in seconds
- **Name files descriptively**: They sort alphabetically — prefix with numbers if order matters (`01-general.md`)
- **Avoid duplication**: Global rules apply everywhere; project rules add project-specific context only

## Declarative Nix Integration (This Config)

This nix-config manages ruler **declaratively** via a custom home-manager module. Rules are git-tracked source files that flow through nix to all agents on every rebuild.

### Architecture

```
ai/ruler/rules/*.md          (source of truth, git-tracked)
        |
home/features/ai.nix         (declares rules + agents)
        |
modules/home/ruler.nix       (home-manager module)
        |
darwin-rebuild switch         (triggers activation)
        |
   ruler apply                (runs automatically)
        |
~/.claude/CLAUDE.md           (output)
~/.codex/AGENTS.md            (output)
~/.gemini/GEMINI.md           (output)
```

### Current Configuration

**Rules** (in `ai/ruler/rules/`):
| File | Purpose |
|------|---------|
| `AGENTS.md` | Core behavior (destructive commands, search tools) |
| `commits.md` | Conventional commits, no AI attribution |
| `planning.md` | 5-step planning workflow |
| `nix-package-management.md` | Package add workflow for nix-darwin |

**Agents** (in `home/features/ai.nix`):
| Agent | Output Path |
|-------|-------------|
| Claude | `~/.claude/CLAUDE.md` |
| Codex | `~/.codex/AGENTS.md` |
| Gemini | `~/.gemini/GEMINI.md` |

### Modify Rules (Global Workflow)

1. **Edit** the rule file in `ai/ruler/rules/` (or create a new one)
2. **Register** new rules in `home/features/ai.nix` under `programs.ruler.rules`:
   ```nix
   rules = {
     general = ../../ai/ruler/rules/AGENTS.md;
     my-new-rule = ../../ai/ruler/rules/my-new-rule.md;
   };
   ```
3. **Commit**: `git add ai/ruler/rules/ home/features/ai.nix`
4. **Rebuild**:
   ```bash
   sudo darwin-rebuild switch --flake ~/nix-config#$(scutil --get LocalHostName)
   ```
   Home-manager activation automatically runs `ruler apply`.

### Add a New Agent

Edit `programs.ruler.agents` in `home/features/ai.nix`:
```nix
agents = {
  claude = { enable = true; outputPath = ".claude/CLAUDE.md"; };
  codex  = { enable = true; outputPath = ".codex/AGENTS.md"; };
  gemini = { enable = true; outputPath = ".gemini/GEMINI.md"; };
  cursor = { enable = true; outputPath = ".cursor/rules/global.md"; };
};
```
Then rebuild.

### Key Files

| File | Role |
|------|------|
| `home/features/ai.nix` | Declares ruler rules + agents |
| `modules/home/ruler.nix` | Home-manager module (builds ruler, generates TOML, runs apply) |
| `ai/ruler/rules/*.md` | Source rule files |

For detailed nix module internals, see [reference/nix-integration.md](reference/nix-integration.md).

## Reference

- [reference/cli.md](reference/cli.md) — Full CLI commands and flags
- [reference/nix-integration.md](reference/nix-integration.md) — Nix module implementation details
