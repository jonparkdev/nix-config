<h2 align="center">My Nix Configuration (macOS + NixOS [coming soon])</h2>

<p align="center">
  <a href="https://lix.systems/">
    <img alt="Lix" src="https://img.shields.io/badge/Lix-Nix-informational?style=for-the-badge&logo=nixos&color=F2CDCD&logoColor=D9E0EE&labelColor=302D41" />
  </a>
  <a href="https://github.com/LnL7/nix-darwin">
    <img alt="nix-darwin" src="https://img.shields.io/badge/nix--darwin-macOS-informational?style=for-the-badge&logo=apple&color=B5E8E0&logoColor=D9E0EE&labelColor=302D41" />
  </a>
</p>

<p align="center">Welcome to my Nix configuration!</p>

## How I Work

My daily driver is a MacBook Pro running macOS with [nix-darwin](https://github.com/LnL7/nix-darwin) and [home-manager](https://github.com/nix-community/home-manager) managing the entire system declaratively. I use [Lix](https://lix.systems/) as my Nix implementation, though nothing here is Lix-specific — standard Nix works fine.

My work is mostly cloud-native — Kubernetes, AWS, Terraform — so the tooling reflects that.

For package management, CLI tools come from Nix and GUI apps that need proper macOS integration (1Password, Firefox, VPN clients) come from Homebrew via [nix-homebrew](https://github.com/zhaofengli-wip/nix-homebrew). The line is simple: if it lives in your terminal, Nix manages it. If it lives in your Dock, Homebrew probably does.

I'm still learning Nix — the learning curve is no joke. This repo is a record of that journey. As I get more comfortable, I hope it becomes something others can reference. If nothing else, reading other people's configs was the single most useful thing when I was starting out, so maybe this one helps someone too.

> This is my personal configuration. If you run it as-is, you'll get *my* machine. Fork it and make it yours, or just use it as a reference.

## What's In Here

- **System packages**: Docker, kubectl, helm, k9s, AWS CLI, tenv, vim, Obsidian, Zed, and more
- **Homebrew casks**: 1Password, Firefox, Claude, Codex, Hammerspoon, AWS VPN Client, ProtonVPN
- **Shell**: Zsh with Starship prompt, distro-aware icons, kube context display
- **Git**: Commit signing via 1Password SSH agent, LFS, rebase-on-pull
- **macOS preferences**: Touch ID for sudo, keyboard repeat tuning, three-finger drag, Dock layout
- **Dev tools**: VS Code with JetBrains Mono Nerd Font, AWS Granted for role switching

## Structure

```
.
├── flake.nix                      # Entry point — inputs, helper functions, host definitions
├── hosts/
│   └── darwin/
│       ├── personal-macbook/
│       │   └── default.nix        # Personal host identity (hostname, user)
│       └── work-macbook/
│           └── default.nix        # Work host identity (hostname, user)
├── modules/
│   ├── shared/
│   │   ├── default.nix
│   │   └── nix-core.nix          # Nix daemon, garbage collection, experimental features
│   ├── darwin/
│   │   ├── default.nix
│   │   ├── apps.nix              # Shared system packages (Nix)
│   │   ├── homebrew.nix          # Shared Homebrew config and common casks
│   │   ├── system.nix            # macOS system preferences
│   │   ├── dock/common.nix       # Shared Dock layout
│   │   └── roles/
│   │       ├── personal.nix      # Personal-only packages/casks
│   │       └── work.nix          # Work-only packages/casks
│   └── nixos/
│       └── default.nix           # Placeholder for future NixOS hosts
└── home/
    ├── default.nix
    ├── base/
    │   ├── shell.nix              # Zsh, Starship
    │   ├── git.nix                # Git config, 1Password signing
    │   └── ssh.nix                # 1Password SSH agent
    ├── features/
    │   ├── dev.nix                # VS Code, Granted
    │   └── hammerspoon.nix        # Window management hotkeys
    ├── profiles/
    │   ├── laptop.nix
    │   ├── work.nix
    │   └── server-admin.nix
    └── hosts/
        └── personal-macbook.nix   # Host-only home-manager override
```

The architecture is layered: `flake.nix` defines helper functions (`mkDarwinConfig`, `mkNixosConfig`) that wire together host identity, shared modules, role modules, and home-manager. Adding a new host means creating a directory under `hosts/` and adding host metadata (system/role/flags) in `flake.nix`.

## Host Model

This config uses a 3-layer model for host management:

- **Host**: machine identity (`hostname`, `system`, primary user)
- **Role**: default package/profile grouping (for example `personal` vs `work`)
- **Home profiles**: reusable user-level bundles selected per host
- **Feature flags**: optional system capabilities toggled per host

Why this split:

- Hostnames can change; behavior should not depend on string comparisons.
- Roles capture broad system defaults you want to reuse across similar machines.
- Home profiles let one user setup span many machines without copy/paste.
- Flags let you opt in to system behavior without creating a new role.

Current examples:

- `personal-macbook`: `role = "personal"`, `homeProfiles = ["laptop" "server-admin"]`, `enableLinuxBuilder = true`
- `work-macbook`: `role = "work"`, `homeProfiles = ["laptop" "work"]`, `enableLinuxBuilder = false`

## Getting Started

### Install Nix

With [Lix](https://lix.systems/) (what I use):
```bash
curl -sSf -L https://install.lix.systems/lix | sh -s -- install
```

Or standard Nix:
```bash
sh <(curl -L https://nixos.org/nix/install)
```

### Build

```bash
git clone https://github.com/jonparkdev/nix-config.git ~/nix-config
cd ~/nix-config
sudo nix run nix-darwin -- switch --flake .
```

After the initial build, rebuild with:
```bash
sudo darwin-rebuild switch --flake .#personal-macbook
# or
sudo darwin-rebuild switch --flake .#work-macbook
```

## References

Configs I've learned from:

- [dustinlyons/nixos-config](https://github.com/dustinlyons/nixos-config)
- [ryan4yin/nix-config](https://github.com/ryan4yin/nix-config)
- [mitchellh/nixos-config](https://github.com/mitchellh/nixos-config)

## License

MIT
