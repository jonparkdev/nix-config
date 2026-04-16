{
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    nerd-fonts.jetbrains-mono

    # Communication
    zoom-us

    # Machine-level runtime tooling
    colima
    docker
    docker-compose

    # AWS
    ssm-session-manager-plugin
  ];
}
