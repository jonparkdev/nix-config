{
  lib,
  user,
  ...
}:
let
  # Import program configurations
  shellConfig = import ./shell.nix { inherit lib; };
  gitConfig = import ./git.nix {};
  sshConfig = import ./ssh.nix {};
  devConfig = import ./dev.nix {};
in
{
  users.users.${user} = {
    name = "${user}";
    home = "/Users/${user}";
  };

  home-manager = {
    useGlobalPkgs = true;

    sharedModules = [
      (
        { config, pkgs, ... }:
        {
          targets.darwin.linkApps.enable = false;
        }
      )
    ];

    users.${user} =
      {
        pkgs,
        config,
        lib,
        ...
      }:
      {
        home = {
          enableNixpkgsReleaseCheck = false;
          stateVersion = "25.05";
          packages = with pkgs; [];
        };

        manual.manpages.enable = false;
        fonts.fontconfig.enable = true;

        # Merge all program configurations
        programs = lib.mkMerge [
          { home-manager.enable = true; }
          shellConfig.programs
          gitConfig.programs
          sshConfig.programs
          devConfig.programs
        ];

        # Reload systemd services on config change
        systemd.user.startServices = "sd-switch";
      };
  };
}
