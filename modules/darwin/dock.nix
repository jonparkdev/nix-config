{
  pkgs,
  user,
  ...
}:
{
  system.defaults.dock = {
    persistent-apps = [
      { app = "System/Applications/Apps.app/"; }
      { app = "${pkgs.ghostty-bin}/Applications/ghostty.app/"; }
      { app = "/Applications/Firefox.app/"; }
      { app = "/Applications/1password.app/"; }
      { app = "System/Applications/System Settings.app/"; }
    ];
    persistent-others = [
      "/Users/${user}/Downloads"
    ];
  };
}
