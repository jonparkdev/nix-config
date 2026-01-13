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

  networking.hostName = "macbook";
  system.primaryUser = user;

  system.defaults.dock = {
    persistent-apps = [
      { app = "System/Applications/Apps.app/"; }
      { app = "${pkgs.ghostty-bin}/Applications/ghostty.app/"; }
      { app = "${pkgs.vscode}/Applications/Visual Studio Code.app"; }
      { app = "/Applications/AWS VPN Client/AWS VPN Client.app/"; }
      { app = "${pkgs.slack}/Applications/Slack.app"; }
      { app = "/Applications/Firefox.app/"; }
      { app = "/Applications/1password.app/"; }
      { app = "System/Applications/System Settings.app/"; }
    ];
    persistent-others = [
      "/Users/${user}/Downloads"
    ];
  };
}
