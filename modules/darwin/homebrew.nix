{
  ...
}:
{
  homebrew = {
    enable = true;

    onActivation.cleanup = "zap";

    casks = [
      "1password"
      "1password-cli"
      "aws-vpn-client"
      "claude"
      "firefox"
      "hammerspoon"
      "protonvpn"
      "codex"
      "codex-app"
    ];

    # Mac App Store apps (requires mas CLI)
    # masApps = {
    #   "Magnet" = 441258766;
    # };
  };
}
