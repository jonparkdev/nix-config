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

    # Communication
    slack
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

    # AI/CLI tools
    claude-code
    gemini-cli
  ];
}
