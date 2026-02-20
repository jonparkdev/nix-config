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
    bun

    # AI/CLI tools
    claude-code
    gemini-cli

    # Communication
    zoom-us

    # Cloud & DevOps tools
    colima
    docker
    docker-compose
    kubectl
    kustomize
    kubernetes-helm
    awscli2
    tenv
    k9s
  ];
}
