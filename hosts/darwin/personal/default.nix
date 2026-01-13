{
  pkgs,
  user,
  ...
}:
{
  imports = [
    ../../../modules/shared
    ../../../modules/darwin
    ../../../home
  ];

  networking.hostName = "personal";
  system.primaryUser = user;

  # Personal-specific dock layout
  system.defaults.dock = {
    persistent-apps = [
      { app = "System/Applications/Apps.app/"; }
      { app = "${pkgs.ghostty-bin}/Applications/ghostty.app/"; }
      { app = "${pkgs.vscode}/Applications/Visual Studio Code.app"; }
      { app = "/Applications/Firefox.app/"; }
      { app = "/Applications/1password.app/"; }
      { app = "System/Applications/System Settings.app/"; }
    ];
    persistent-others = [
      "/Users/${user}/Downloads"
    ];
  };

  # Personal-specific packages (add any personal-only apps here)
  # environment.systemPackages = with pkgs; [];

  # Personal-specific homebrew casks (add any personal-only casks here)
  # homebrew.casks = [];
}
