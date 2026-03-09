# Ruler CLI Reference

## ruler init

Scaffold a new ruler configuration directory.

```bash
ruler init              # Creates .ruler/ in current project
ruler init --global     # Creates ~/.config/ruler/
```

Creates:
- `ruler.toml` — agent configuration
- Starter rule files
- `mcp.json` — MCP server configuration (if applicable)

## ruler apply

Fan rules out to all configured agents.

```bash
ruler apply [options]
```

### Options

| Flag | Default | Description |
|------|---------|-------------|
| `--project-root <path>` | Current directory | Project root; output paths are relative to this |
| `--agents <list>` | All enabled | Comma-separated agent list to target |
| `--config <path>` | Auto-discovered | Path to custom `ruler.toml` |
| `--dry-run` | `false` | Preview changes without writing files |
| `--verbose`, `-v` | `false` | Enable verbose logging |
| `--local-only` | `false` | Only use local `.ruler/`, skip global config |
| `--nested` | `false` | Load rules from parent directories too (experimental) |
| `--no-backup` | `false` | Skip `.bak` backup file creation |
| `--no-gitignore` | `false` | Skip `.gitignore` updates |
| `--gitignore-local` | `false` | Write to `.git/info/exclude` instead of `.gitignore` |
| `--no-mcp` | `false` | Disable MCP server configuration |
| `--mcp-overwrite` | `false` | Replace (not merge) native MCP config |
| `--no-skills` | `false` | Disable skills support (experimental) |

### Available Agents

`agentsmd`, `aider`, `amazonqcli`, `amp`, `antigravity`, `augmentcode`, `claude`, `cline`, `codex`, `copilot`, `crush`, `cursor`, `factory`, `firebase`, `firebender`, `gemini-cli`, `goose`, `jetbrains-ai`, `jules`, `junie`, `kilocode`, `kiro`, `mistral`, `opencode`, `openhands`, `pi`, `qwen`, `roo`, `trae`, `warp`, `windsurf`, `zed`

### Examples

```bash
# Preview what would change
ruler apply --dry-run

# Apply to Claude and Codex only
ruler apply --agents claude,codex

# Apply with custom config and project root
ruler apply --config ./my-ruler.toml --project-root /path/to/project

# Verbose output for debugging
ruler apply -v
```

## ruler revert

Undo changes from the last `ruler apply`. Restores files from `.bak` backups.

```bash
ruler revert [options]
```

### Options

| Flag | Default | Description |
|------|---------|-------------|
| `--project-root <path>` | Current directory | Project root directory |
| `--agents <list>` | All enabled | Comma-separated agent list to revert |
| `--config <path>` | Auto-discovered | Path to `ruler.toml` |
| `--dry-run` | `false` | Preview revert without writing |
| `--keep-backups` | `false` | Keep `.bak` files after revert |
| `--verbose`, `-v` | `false` | Enable verbose logging |
| `--local-only` | `false` | Only use local `.ruler/`, skip global config |

**Note**: Revert only works if backups exist. If `ruler apply` was run with `--no-backup`, revert has nothing to restore from.

## ruler.toml Format

```toml
[agents.claude]
enabled = true
output_path = ".claude/CLAUDE.md"

[agents.codex]
enabled = true
output_path = ".codex/AGENTS.md"

[agents.gemini]
enabled = false
output_path = ".gemini/GEMINI.md"
```

Each agent has:
- `enabled` — Whether ruler writes to this agent's config (`true`/`false`)
- `output_path` — Where to write, relative to `--project-root`

## Config Discovery

Ruler searches for configuration in this order:
1. `.ruler/` in current directory (walks up the directory tree)
2. `$XDG_CONFIG_HOME/ruler` (defaults to `~/.config/ruler/`)

Rule files (`.md`) are discovered recursively within the config directory, sorted alphabetically, and concatenated with source markers.
