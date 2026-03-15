{
  ...
}:
{
  homebrew = {
    enable = true;

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
      "typora"
      "tailscale-app"
    ];
  };
}
