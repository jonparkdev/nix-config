{
  lib,
  user,
  hostname,
  homeProfiles ? [ ],
  ...
}:
let
  profileModule = profile: ./profiles + "/${profile}.nix";
  hostModule = ./hosts + "/${hostname}.nix";
in
{
  users.users.${user} = {
    name = user;
    home = "/Users/${user}";
  };

  home-manager = {
    useGlobalPkgs = true;
    backupFileExtension = "backup";

    sharedModules = [
      {
        targets.darwin.linkApps.enable = false;
      }
    ];

    users.${user} = {
      imports = [
        ./base/shell.nix
        ./base/git.nix
        ./base/ssh.nix
        ./base/ai.nix
      ]
      ++ builtins.map profileModule homeProfiles
      ++ lib.optionals (builtins.pathExists hostModule) [
        hostModule
      ];

      home.stateVersion = "26.05";
      programs.home-manager.enable = true;
      fonts.fontconfig.enable = true;
    };
  };
}
