{
  ...
}:
{
  homebrew = {
    enable = true;

    casks = [
      "1password"
      "1password-cli"
      "firefox"
      "aws-vpn-client"
      "protonvpn"
    ];

    # Mac App Store apps (requires mas CLI)
    # masApps = {
    #   "Magnet" = 441258766;
    # };
  };
}
