{
  ...
}:
{
  homebrew = {
    enable = true;

    onActivation.autoUpdate = true;
    onActivation.upgrade = true;
    onActivation.cleanup = "uninstall";

    brews = [
      "backlog-md"
    ];

    taps = [
      "homebrew/cask"
      "homebrew/bundle"
    ];

    casks = [
      "1password"
      "1password-cli"
      "claude"
      "firefox"
      "google-chrome"
      "typora"
      "tailscale-app"
    ];
  };
}
