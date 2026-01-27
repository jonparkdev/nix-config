{
  user,
  ...
}:
{
  users.users.${user} = {
    name = user;
    home = "/Users/${user}";
  };

  home-manager = {
    useGlobalPkgs = true;

    sharedModules = [
      {
        targets.darwin.linkApps.enable = false;
      }
    ];

    users.${user} = {
      imports = [
        ./shell.nix
        ./git.nix
        ./ssh.nix
        ./dev.nix
        ./hammerspoon.nix
      ];

      home.stateVersion = "25.05";
      programs.home-manager.enable = true;
      fonts.fontconfig.enable = true;
    };
  };
}
