{
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    # Communication
    zoom-us

    # Productivity
    obsidian

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

  homebrew = {
    brews = [
      "beads"
    ];

    casks = [
      "hammerspoon"
      "protonvpn"
    ];
  };
}
