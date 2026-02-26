{
  ...
}:
{
  homebrew = {
    enable = true;

    onActivation.cleanup = "uninstall";

    brews = [
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
      "claude-code"
      "firefox"
      "typora"
      "codex"
      "codex-app"
    ];
  };
}
