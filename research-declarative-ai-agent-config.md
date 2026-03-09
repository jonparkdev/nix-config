# Declarative AI Agent Configuration with Nix

**Researched:** 2026-03-06
**Context:** Managing Claude Code config (CLAUDE.md, settings, hooks, MCP servers) declaratively via Nix/home-manager instead of imperatively.

---

## The Problem

Nix/home-manager makes system config declarative and reproducible. But AI coding assistant configs (`~/.claude/CLAUDE.md`, `~/.claude/settings.json`, MCP servers, hooks) are typically managed imperatively — edited in place, not version controlled, not composable across machines.

The tension:
- Claude Code mutates `~/.claude.json` at runtime (auth state, MCP toggles)
- `CLAUDE.md` is prose, not structured — no native inheritance or composition
- Rules often need to be duplicated across AI tools (Claude, Cursor, Copilot, etc.)

---

## Solutions

### 1. `nix-community/home-manager` — `programs.claude-code`

**Status:** Stable, merged Sept 2025 ([PR #7711](https://github.com/nix-community/home-manager/pull/7711))
**Docs:** [MyNixOS options reference](https://mynixos.com/home-manager/options/programs.claude-code)
**Source:** [`modules/programs/claude-code.nix`](https://github.com/nix-community/home-manager/blob/master/modules/programs/claude-code.nix)

The upstream home-manager module. Manages ~17 options under `programs.claude-code`:

| Option | What it manages |
|--------|----------------|
| `enable` / `package` | Install Claude Code CLI |
| `settings` | Generates `~/.claude/settings.json` |
| `memory.text` / `memory.source` | Inline or file-path for `~/.claude/CLAUDE.md` (mutually exclusive) |
| `mcpServers` | Declarative MCP server definitions |
| `enableMcpIntegration` | Auto-pulls in `programs.mcp.servers` |
| `agentsDir` / `agents` | Symlinks to `~/.claude/agents/` |
| `commandsDir` / `commands` | Symlinks to `~/.claude/commands/` |
| `hooksDir` / `hooks` | Symlinks to `~/.claude/hooks/` |
| `rulesDir` / `rules` | Symlinks to `~/.claude/rules/` |
| `skillsDir` / `skills` | Symlinks to `~/.claude/skills/` |

**Known limitation:** Claude Code has a bug where it can't follow symlinks in some contexts. The module uses symlinks by default. If this bites you, see the `flyinggrizzly/claude-config.nix` workaround below (copy instead of symlink via activation scripts).

**What it can't manage:** `~/.claude.json` — Claude mutates this at runtime (auth state, MCP enabled/disabled toggles). Every project in this space punts on it.

**Minimal example:**

```nix
programs.claude-code = {
  enable = true;
  memory.source = ./claude/CLAUDE.md;
  settings = {
    theme = "dark";
  };
  mcpServers = {
    github = {
      command = "npx";
      args = ["-y" "@modelcontextprotocol/server-github"];
      env.GITHUB_PERSONAL_ACCESS_TOKEN = "$(cat ~/.secrets/github-token)";
    };
  };
};
```

---

### 2. `roman/mcps.nix`

**Repo:** [github.com/roman/mcps.nix](https://github.com/roman/mcps.nix)
**Status:** Active

Curated library of 16 pre-configured MCP server presets. Integrates with both devenv and home-manager.

Included presets: Git, GitHub, LSP servers for Go/Nix/Python/Rust/TypeScript, Buildkite, Grafana, Asana, Obsidian.

Security note: reads API tokens from files rather than embedding them in the Nix store (important — secrets in the Nix store are world-readable).

```nix
# devenv.nix
imports = [ inputs.mcps.devenvModules.claude ];
claude.mcps = {
  github.enable = true;
  git.enable = true;
};
```

---

### 3. `devenv` Claude Code Integration

**Docs:** [devenv.sh/integrations/claude-code](https://devenv.sh/integrations/claude-code/)
**Status:** Active

Per-project declarative MCP config scoped to the devenv shell. Generates `.mcp.json` in the project root. Works alongside `mcps.nix` for presets.

Good for: project-scoped MCP servers that shouldn't be global (e.g., a database MCP only active in a specific project shell).

---

### 4. `flyinggrizzly/claude-config.nix` (Archived)

**Repo:** [github.com/flyinggrizzly/claude-config.nix](https://github.com/flyinggrizzly/claude-config.nix)
**Status:** Archived Jan 2026 (superseded by upstream home-manager)

Worth reading for its design decisions, especially the symlink workaround. Used activation scripts to *copy* files rather than symlink, at the cost of idempotency. Also merged declarative MCP config into the live `~/.claude.json` rather than replacing it — the only real approach for a file Claude mutates at runtime.

---

### 5. `Veraticus/nix-config` (Reference Implementation)

**Repo:** [github.com/Veraticus/nix-config/tree/main/home-manager/claude-code](https://github.com/Veraticus/nix-config/tree/main/home-manager/claude-code)

The most operationally complete public example. Notable for:
- Hooks wired to a Go daemon (`cc-tools`) via Unix socket — type-safe, testable, composable hooks
- Separate subdirectory with `default.nix`, `CLAUDE.md`, `settings.json`, `hooks/`, `commands/`

Worth studying if you want production-grade hooks rather than simple shell scripts.

---

### 6. Cross-Tool: Ruler and Rulesync

Not Nix-specific, but address the problem of maintaining one source of truth that fans out to multiple AI assistants.

**Ruler** — [github.com/intellectronica/ruler](https://github.com/intellectronica/ruler)
- Single `.ruler/` directory of Markdown files as source of truth
- `ruler apply` distributes to 32+ agent configs (CLAUDE.md, AGENTS.md, `.cursorrules`, Copilot, Cline, etc.)
- `ruler.toml` for declarative agent targeting and merge strategies
- `--nested` flag for monorepo support

**Rulesync** — [github.com/dyoshikawa/rulesync](https://github.com/dyoshikawa/rulesync)
- Node.js CLI; `.rulesync/*.md` files with frontmatter as source
- Generates configs for Claude Code, Gemini CLI, Cursor, Cline, Roo Code, Copilot
- Supports glob-scoped rules (apply a rule only to `*.ts` files, etc.)

These could be wrapped in a Nix module + home-manager activation script to get cross-tool fan-out under declarative control. Nobody has published this as a module yet.

---

### 7. Declarative MCP with Secret Injection (Lewis Flude's Pattern)

**Post:** [lewisflude.com/blog/mcp-nix-blog-post](https://lewisflude.com/blog/mcp-nix-blog-post)

Documents a two-stage copy approach (generate in `~/.mcp-generated/`, copy to final locations during activation) to work around the symlink bug. Also covers SOPS-based secret injection via wrapper scripts — keys never touch the Nix store.

Worth reading if you're managing API keys for MCP servers and care about secret hygiene.

---

## Open Gaps

| Gap | Status | Notes |
|-----|--------|-------|
| `~/.claude.json` runtime mutation | Unresolved | File is owned by Claude at runtime. Best approach: merge declarative config in, don't replace. |
| Composable `CLAUDE.md` (`@include`) | [Open PR #13621](https://github.com/anthropics/claude-code/issues/13614) | Would allow `@include ~/.claude/languages/elixir.md` style composition natively |
| `extends` for `settings.json` | [Open issue #4800](https://github.com/anthropics/claude-code/issues/4800) | ESLint/TSConfig-style inheritance; 15+ upvotes, still open |
| Cross-tool declarative fan-out in Nix | Doesn't exist | Would need Ruler/Rulesync wrapped in a home-manager module |
| Type-safe composable hooks | DIY only | Veraticus's cc-tools daemon is the only published example |
| Nix module for `CLAUDE.md` composition | Doesn't exist | home-manager supports one file; no module system for composing rules from multiple sources |

---

## Further Reading

- [awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code) — curated list of Claude Code tools, hooks, commands, and configs
- [0xdevalias gist on AI agent rule files](https://gist.github.com/0xdevalias/f40bc5a6f84c4c5ad862e314894b2fa6) — survey of all agent rule file formats across tools
- [sadjow/claude-code-nix](https://github.com/sadjow/claude-code-nix) — keeps the Claude Code CLI package current in Nix (nixpkgs lags Anthropic's release cadence; this does hourly updates)

---

## Recommended Path for This Setup

Given nix-darwin + home-manager already in use:

1. **Enable `programs.claude-code`** in `home.nix` — gets CLAUDE.md, settings, MCP, hooks under version control immediately
2. **Point `memory.source`** to a `claude/CLAUDE.md` file committed in `nix-config`
3. **Use `roman/mcps.nix`** for MCP server presets rather than configuring each manually
4. **Watch `~/.claude.json`** — accept it's outside declarative control, or implement the merge-on-activation pattern from `flyinggrizzly/claude-config.nix`
5. **Consider Ruler** if you want the same rules to apply in Cursor or Copilot contexts too
