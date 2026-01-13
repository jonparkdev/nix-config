# My Nix Configuration (MacOS + NixOS\[coming soon\])

Welcome to my Nix configuration!

I use Nix to manage my not so many systems.  Just my personal and work MacBooks but, Coming Soon, configuration for my 
For those who are uninitiated. 

 What does that mean? I can build and rebuild my machine from scratch as much as I want.  You'll find currently that I only manage a MacOS configuration but eventually plan to dabble in NixOS for my homelab machines. Coming Soon! 

I am currently learning Nix and it's no joke that there is a steap learning curve. With that said this repo represent my Nix journey and through my exploration I hope, the content can become something og value can add value in some becomes something that someone can reference. I will try my best to document my journey
What you will find in this repo is the declarative configuration for managing my many(just my MacOS hosts so far) machines

## Why Nix?

I originally managed my system configuration using the typical (bash powered dotfiles)[] Nix was introduced to me my a colleague at work. 

## Community

A


## What This Is

This repository uses **Nix Flakes** and **nix-darwin** to define my entire macOS development environment as code. Everything from installed packages to system preferences to shell configurations lives here, version-controlled and reproducible.

Why Nix? I wanted a system where I could:
- Rebuild my machine from scratch in minutes, not hours
- Track every change to my development environment in Git
- Share configurations across machines (when I get there)
- Actually understand what's installed and why

This setup is optimized for cloud-native development work with Kubernetes, AWS, and Docker, plus the usual suspects for a modern development workflow.

## Quick Start

### Prerequisites

Install Nix with flakes enabled:
```bash
sh <(curl -L https://nixos.org/nix/install)
```

### Initial Setup

Clone this repo and run the initial build:
```bash
git clone https://github.com/jonpark/nix-config.git ~/nix-config
cd ~/nix-config
nix run nix-darwin -- switch --flake .
```

### Daily Commands

**Rebuild system after making changes:**
```bash
darwin-rebuild switch --flake ~/nix-config
```

**Update all packages:**
```bash
cd ~/nix-config
nix flake update
darwin-rebuild switch --flake .
```

**Garbage collect old generations (free up space):**
```bash
nix-collect-garbage -d
```

**See what's installed:**
```bash
nix profile list
```

## What's Inside

### Development Tools
- **Containers & Orchestration:** Docker, kubectl, helm, k9s
- **Cloud & IaC:** AWS CLI, Terraform (via tenv), AWS IAM Granted
- **Editor:** VS Code with JetBrains Mono Nerd Font
- **Terminal:** Ghostty with Starship prompt (shows Kubernetes context)
- **Version Control:** Git with LFS support

### System Configuration
- **Package Management:** Nix + Homebrew integration for Mac-native apps
- **Security:** 1Password integration for SSH keys and Git signing
- **macOS Preferences:** Dock layout, keyboard settings (key repeat = 2), trackpad with three-finger drag, Touch ID for sudo

### Applications
- **Communication:** Slack, Zoom
- **Security:** 1Password, 1Password CLI
- **Browsers:** Firefox
- **VPN:** AWS VPN Client
- **AI Tools:** claude-code

### Shell Environment
- **Shell:** Zsh with custom initialization
- **Prompt:** Starship with Kubernetes metadata display
- **SSH:** Integrated with 1Password agent for key management

## Structure Overview

```
nix-config/
├── flake.nix                 # Main entry point - defines inputs/outputs
├── flake.lock                # Locked dependency versions for reproducibility
├── hosts/
│   └── darwin/
│       └── default.nix       # macOS system configuration (packages, settings)
└── home-manager/
    └── home.nix              # User environment (git, shell, dotfiles)
```

### Key Files Explained

**`flake.nix`**
The heart of the configuration. Declares dependencies (nixpkgs, nix-darwin, home-manager) and defines your system outputs. This is where everything comes together.

**`hosts/darwin/default.nix`**
System-level configuration for macOS. This is where you:
- Install system packages
- Configure Homebrew apps
- Set macOS preferences (Dock, keyboard, trackpad, etc.)
- Configure Nix daemon settings

**`home-manager/home.nix`**
User-level configuration. This manages:
- Git configuration
- Shell setup (Zsh, Starship)
- SSH configuration
- Dotfiles and user-specific settings

## Useful Commands & Tips

### Adding a New Package

**Add to system (available to all users):**
Edit `hosts/darwin/default.nix` and add to `environment.systemPackages`:
```nix
environment.systemPackages = with pkgs; [
  # ... existing packages
  your-new-package
];
```

**Add to user environment:**
Edit `home-manager/home.nix` and add to `home.packages`:
```nix
home.packages = with pkgs; [
  # ... existing packages
  your-new-package
];
```

Then rebuild:
```bash
darwin-rebuild switch --flake ~/nix-config
```

### Searching for Packages

```bash
# Search nixpkgs
nix search nixpkgs <package-name>

# Example: search for postgres
nix search nixpkgs postgres
```

### Rolling Back Changes

If something breaks after a rebuild:
```bash
# List previous generations
darwin-rebuild --list-generations

# Roll back to previous generation
darwin-rebuild --rollback

# Or switch to specific generation
darwin-rebuild switch --flake . --switch-generation <number>
```

### Managing Homebrew Apps

Add Mac-native apps in `hosts/darwin/default.nix` under `homebrew.casks`:
```nix
homebrew.casks = [
  "1password"
  "firefox"
  # Add your app here
];
```

### Checking for Updates

```bash
# Update flake inputs to latest versions
nix flake update

# See what changed
git diff flake.lock
```

## Customization

This is my personal configuration, but it's designed to be forkable. Here's how to make it yours:

1. **Personal Info:** Update git config in `home-manager/home.nix`
2. **Packages:** Add/remove from the packages lists in both files
3. **macOS Settings:** Tweak `system.defaults` in `hosts/darwin/default.nix`
4. **Shell:** Customize Zsh and Starship in `home-manager/home.nix`
5. **Dock:** Modify `system.dock` settings to match your workflow

The beauty of Nix is that you can experiment freely - if something breaks, just roll back.

## Resources & Learning

I'm learning Nix as I build this. Here are resources that have helped me:

- [Nix Darwin Documentation](https://daiderd.com/nix-darwin/)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Nix Flakes Wiki](https://nixos.wiki/wiki/Flakes)
- [Zero to Nix](https://zero-to-nix.com/) - Great intro to Nix concepts
- [MyNixOS](https://mynixos.com/) - Search nix-darwin and home-manager options
- [Nix Package Search](https://search.nixos.org/packages) - Find packages

### Helpful Community Configs

Looking at others' configs has been invaluable:
- [dustinlyons/nixos-config](https://github.com/dustinlyons/nixos-config)
- [mathiasbynens/dotfiles](https://github.com/mathiasbynens/dotfiles) - Great for macOS defaults

## License

MIT - Feel free to fork and adapt this for your own use.

---

*Still learning, still tinkering. If you spot something that could be better, I'm all ears.*
