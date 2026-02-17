{
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
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
  ];

  homebrew = {
    casks = [
      "aws-vpn-client"
    ];
  };
}
