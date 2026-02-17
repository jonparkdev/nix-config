{
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    # Nix tools
    nixfmt

    # Core utilities
    vim
    gnupg
    bat

    # Terminal & fonts
    ghostty-bin
    nerd-fonts.jetbrains-mono

    # Core dev tools
    gh

    # AI/CLI tools
    claude-code
    gemini-cli
  ];
}
