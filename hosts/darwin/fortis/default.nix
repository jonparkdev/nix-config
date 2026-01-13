{
  pkgs,
  user,
  ...
}:
{
  imports = [
    ../../../modules/shared
    ../../../modules/darwin
    ../../../home
  ];

  networking.hostName = "fortis";
  system.primaryUser = user;

  # Work-specific dock layout
  system.defaults.dock = {
    persistent-apps = [
      { app = "System/Applications/Apps.app/"; }
      { app = "${pkgs.ghostty-bin}/Applications/ghostty.app/"; }
      { app = "${pkgs.vscode}/Applications/Visual Studio Code.app"; }
      { app = "/Applications/AWS VPN Client/AWS VPN Client.app/"; }
      { app = "${pkgs.slack}/Applications/Slack.app"; }
      { app = "/Applications/Firefox.app/"; }
      { app = "/Applications/1password.app/"; }
      { app = "System/Applications/System Settings.app/"; }
    ];
    persistent-others = [
      "/Users/${user}/Downloads"
    ];
  };

  # Work-specific packages
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

  # Work-specific homebrew casks
  homebrew.casks = [
    "aws-vpn-client"
  ];
}
