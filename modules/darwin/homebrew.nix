{
  ...
}:
{
  homebrew = {
    enable = true;

    onActivation.cleanup = "zap";

    taps = [
      "homebrew/cask"
      "homebrew/bundle"
    ];

    casks = [
      "1password"
      "1password-cli"
      "claude"
      "firefox"
      "codex"
      "codex-app"
    ];
  };
}
