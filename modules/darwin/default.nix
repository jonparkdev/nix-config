{
  lib,
  role,
  enableLinuxBuilder,
  ...
}:
{
  imports = [
    ./system.nix
    ./apps.nix
    ./homebrew.nix
    ./dock.nix
  ] ++ lib.optionals (role == "personal") [
    ./roles/personal.nix
  ] ++ lib.optionals (role == "work") [
    ./roles/work.nix
  ] ++ lib.optionals enableLinuxBuilder [
    ./builders.nix
  ];
}
