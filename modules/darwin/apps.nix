{
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    # Nix tools
    nixfmt-rfc-style

    # Core utilities
    vim
    gnupg

    # Terminal & fonts
    ghostty-bin
    nerd-fonts.jetbrains-mono

    # AI/CLI tools
    claude-code
  ];
}
