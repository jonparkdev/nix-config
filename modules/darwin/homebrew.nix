{
  ...
}:
{
  homebrew = {
    enable = true;

    # Shared casks - available on all Darwin hosts
    casks = [
      "1password"
      "1password-cli"
      "firefox"
    ];

    # Mac App Store apps (requires mas CLI)
    # masApps = {
    #   "Magnet" = 441258766;
    # };
  };
}
