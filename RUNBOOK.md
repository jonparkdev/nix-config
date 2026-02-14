# Runbook

Operational reference for this nix-config. Covers how things work, common issues, and debugging steps.

## Linux Builder (aarch64-linux on macOS)

### How it works

`modules/darwin/builders.nix` enables `nix.linux-builder`, which runs a NixOS VM via QEMU on macOS. This lets you build `aarch64-linux` packages without a separate Linux machine.

The chain: **launchd** (`org.nixos.linux-builder`) → **QEMU** (aarch64 VM) → **NixOS guest** (SSH on port 31022) → **nix daemon** connects as `builder@localhost` to offload Linux builds.

### Key files and paths

| What | Where |
|------|-------|
| Config | `modules/darwin/builders.nix` |
| SSH key (private) | `/etc/nix/builder_ed25519` (root-only, by design) |
| SSH config | `/etc/ssh/ssh_config.d/100-linux-builder.conf` |
| VM disk image | `/var/lib/linux-builder/nixos.qcow2` |
| VM runtime state | `/run/org.nixos.linux-builder/` |
| launchd plist | `/Library/LaunchDaemons/org.nixos.linux-builder.plist` |

### After a rebuild

The VM takes ~1-2 minutes to boot on first start. You'll see port 31022 open but SSH returning "broken pipe" until the guest OS finishes booting. This is normal.

### Verifying the builder

```bash
# Check launchd service is running
sudo launchctl list | grep linux-builder

# Check QEMU process is alive
ps aux | grep qemu

# Check port 31022 is listening
sudo lsof -nP -iTCP:31022

# Test SSH as root (how the nix daemon connects)
sudo ssh -i /etc/nix/builder_ed25519 -p 31022 builder@localhost "echo ok"

# Smoke test: build a Linux package
nix build --system aarch64-linux nixpkgs#hello --print-build-logs
file result/bin/hello  # should say "ELF 64-bit ... ARM aarch64 ... GNU/Linux"
```

### Common issues

**"Host key verification failed" with `nix store ping --store ssh-ng://linux-builder`**
This runs as your user, but the SSH private key is root-only (`600 root:nixbld`). This is by design — the nix daemon (running as root) handles builder connections. Use the smoke test build above instead.

**"Broken pipe" on SSH to port 31022**
The VM is still booting. Wait 1-2 minutes. Verify QEMU is running with `ps aux | grep qemu` and the port is open with `sudo lsof -nP -iTCP:31022`.

**VM not starting after rebuild**
```bash
sudo launchctl start org.nixos.linux-builder
```

**Flake eval error: `builders.nix` does not exist**
New files in a dirty git tree aren't visible to Nix flake evaluation. Run `git add` on the new file before rebuilding:
```bash
git add modules/darwin/builders.nix
```

### Useful debugging commands

| Command | What it does |
|---------|-------------|
| `sudo launchctl list \| grep linux-builder` | Shows PID and exit status of the builder service |
| `sudo launchctl print system/org.nixos.linux-builder` | Full service details: PID, args, env, working dir |
| `ps aux \| grep qemu` | Confirms QEMU VM process is alive |
| `sudo lsof -nP -iTCP:31022` | Shows what's listening on the SSH port |
| `nc -w 5 localhost 31022 < /dev/null` | Raw TCP check — shows SSH banner if VM is up |
| `ssh-keyscan -p 31022 localhost` | Retrieves host keys (fails with broken pipe if VM still booting) |
| `file result/bin/hello` | Confirms a built binary is the right architecture |
