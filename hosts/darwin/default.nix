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
        "warp-terminal"
        "1password"
        "1password-cli"
        "1password-gui"
        "slack"
        "zoom"
      ];
  };
  environment.systemPackages = with pkgs; [
    # Nix related packages
    nixfmt-rfc-style

    gnupg

    vim
    firefox
    vscode
    warp-terminal

    # Cloud-related tools and SDKs
    docker
    docker-compose
    kubectl
    kustomize
    kubernetes-helm
    awscli2
    granted
    opentofu
    tenv
  ];

  homebrew = {
    enable = true;
    casks = [ "aws-vpn-client" "mullvad-vpn" ];

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
    # Fore details see: https://github.com/nix-community/home-manager/issues/1341#issuecomment-3256894180
    build.applications = lib.mkForce (
      pkgs.buildEnv {
        name = "system-applications";
        pathsToLink = "/Applications";
        paths =
          config.environment.systemPackages
          ++ (lib.concatMap (x: x.home.packages) (lib.attrsets.attrValues config.home-manager.users));
      }
    );
    
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
            app = "/Applications/Nix Apps/Warp.app/";
          }
          {
            app = "/Applications/Nix Apps/Visual Studio Code.app/";
          }
          {
            app = "/Applications/AWS VPN Client/AWS VPN Client.app/";
          }
          {
            app = "/Applications/Nix Apps/Slack.app/";
          }
          {
            app = "/Applications/Nix Apps/Firefox.app/";
          }
          {
            app = "/Applications/Nix Apps/1password.app/";
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
