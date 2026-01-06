{
  self,
  lib,
  config,
  pkgs,
  ...
}:
let
  user = "jonpark";
in
{
  imports = [
    ../../home-manager/home.nix
  ];

  nix = {
    package = pkgs.nix;

    settings = {
      download-buffer-size = 500000000;
      trusted-users = [
        "@admin"
        "${user}"
      ];
      substituters = [
        "https://nix-community.cachix.org"
        "https://cache.nixos.org"
      ];
      trusted-public-keys = [ "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" ];
    };

    gc = {
      automatic = true;
      interval = {
        Weekday = 0;
        Hour = 2;
        Minute = 0;
      };
      options = "--delete-older-than 30d";
    };

    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };
  
  nixpkgs = {
    config.allowUnfreePredicate =
      pkg:
      builtins.elem (lib.getName pkg) [
        # Add additional package names here
        "vscode"
        "slack"
        "zoom"
        "claude-code"
      ];
  };

  security.pam.services.sudo_local.touchIdAuth = true;

  environment.systemPackages = with pkgs; [
    # Nix related packages
    nixfmt-rfc-style

    gnupg

    vim
    ghostty-bin
    slack
    zoom-us
    nerd-fonts.jetbrains-mono
    claude-code

    # Cloud-related tools and SDKs
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
    enable = true;
    casks = [ 
      "aws-vpn-client" 
      "1password" 
      "1password-cli" 
      "firefox"
    ];

    # These app IDs are from using the mas CLI app
    # mas = mac app store
    # https://github.com/mas-cli/mas
    #
    # $ nix shell nixpkgs#mas
    # $ mas search <app name>
    #
    # If you have previously added these apps to your Mac App Store profile (but not installed them on this system),
    # you may receive an error message "Redownload Unavailable with This Apple ID".
    # This message is safe to ignore. (https://github.com/dustinlyons/nixos-config/issues/83)

    # masApps = {
    #  "Magnet" = 441258766;
    # };
  };

  system = {
    checks.verifyNixPath = false;
    primaryUser = user;
    stateVersion = 6;
    configurationRevision = self.rev or self.dirtyRev or null;
    activationScripts.extraActivation.text = ''
      softwareupdate --install-rosetta --agree-to-license
    '';

    defaults = {
      NSGlobalDomain = {
        AppleShowAllExtensions = true;
        ApplePressAndHoldEnabled = false;

        KeyRepeat = 2; # Values: 120, 90, 60, 30, 12, 6, 2
        InitialKeyRepeat = 15; # Values: 120, 94, 68, 35, 25, 15

        "com.apple.mouse.tapBehavior" = 1;
        "com.apple.sound.beep.volume" = 0.0;
        "com.apple.sound.beep.feedback" = 0;
      };

      dock = {
        autohide = false;
        show-recents = false;
        launchanim = true;
        orientation = "bottom";
        tilesize = 60;
        persistent-apps = [
          {
            app = "System/Applications/Apps.app/";
          }
          {
            app = "${pkgs.ghostty-bin}/Applications/ghostty.app/";
          }
          {
            app = "${pkgs.vscode}/Applications/Visual Studio Code.app";
          }
          {
            app = "/Applications/AWS VPN Client/AWS VPN Client.app/";
          }
          {
            app = "${pkgs.slack}/Applications/Slack.app";
          }
          {
            app = "/Applications/Firefox.app/";
          }
          {
            app = "/Applications/1password.app/";
          }
          {
            app = "System/Applications/System Settings.app/";
          }
        ];
        persistent-others = [
          "/Users/jonpark//Downloads"
        ];
      };

      finder = {
        _FXShowPosixPathInTitle = false;
      };

      trackpad = {
        Clicking = true;
        TrackpadThreeFingerDrag = true;
      };
    };
  };
}
