{
  ...
}:
{
  homebrew = {
    enable = true;

    onActivation.cleanup = "uninstall";

    brews = [
      "backlog-md"
      "gemini-cli"
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
      "codex"
      "codex-app"
      "tailscale"
    ];
  };
}
