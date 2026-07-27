# PROJECT.md — nix-config dendritic migration

## Artifact

`~/nix-config` restructured to the dendritic pattern: flake-parts + import-tree
replaces the centralized `darwinHosts` registry in `flake.nix`. Feature modules
self-register into a `darwin.modules` option; host files self-register into
`darwin.configurations`. The result: adding a module or machine = create a file,
`flake.nix` never changes.

Structural blueprint: `TDD-001` in `~/projects/theinfra-rc/docs/TDD/TDD-001.md`,
adapted for nix-darwin + home-manager in place of NixOS.

## Shipped v0.0.1
<!-- Versioning: semver. Convention defined in ~/.claude/skills/scope/SKILL.md. -->

`darwin-rebuild switch --flake .#personal-macbook` succeeds on the migrated
config. No behavior change — same packages, same settings, same home-manager
output. Config pushed to remote.

Who sees it: me, running my daily machine from the new structure.

## Not doing

- work-macbook migration (until personal-macbook is confirmed working)
- home-manager structural overhaul
- sops-nix
- NixOS hosts
- Adding new packages or features during the migration — structural changes only

## Bait list

- **Meta-tooling spiral** — this is tooling-on-tooling; the pattern has clear
  right answers and perfectionism has extra grip here. Flag by name if module
  boundary debates stall forward motion.
- **Module boundary perfectionism** — the dendritic pattern is flexible; no
  single correct split exists. Good-enough-and-building beats elegant-and-stalled.
- **work-macbook before personal-macbook ships** — the second host is not v0.0.1.
- **"While I'm in here" features** — adding packages or reconfiguring during
  the migration is scope creep; do it after the switch succeeds.

## Urgency source

Internal: current workflow for managing development software has real daily
friction. No external deadline or witness. This project is missing the external
input the system routes toward — flag if motivation stalls; consider posting the
finished config to a nix community or sending to someone who uses nix-darwin.
