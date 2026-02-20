{
  ...
}:
{
  homebrew = {
    enable = true;

    # Avoid noisy uninstall attempts for dependency formulas across role switches.
    onActivation.cleanup = "none";

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
      "codex"
      "codex-app"
    ];
  };
}
