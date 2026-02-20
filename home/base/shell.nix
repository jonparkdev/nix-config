{
  lib,
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    nixfmt
    vim
    gnupg
    bat
    glow
    gh
    bun
    kubectl
    kustomize
    kubernetes-helm
    awscli2
    tenv
    k9s
  ];

  programs.ghostty = {
    enable = true;
    package =
      if pkgs.stdenv.hostPlatform.system == "aarch64-darwin" && pkgs ? ghostty-bin
      then pkgs.ghostty-bin
      else if pkgs ? ghostty
      then pkgs.ghostty
      else null;
    settings = {
      fullscreen = true;
      split-divider-color = "#f5a97f";
    };
  };

  programs.helix = {
    enable = true;
    defaultEditor = true;
  };

  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    plugins = {
      piper = pkgs.yaziPlugins.piper;
    };
    settings = {
      manager.ratio = [
        1
        2
        5
      ];

      plugin.prepend_previewers = [
        {
          url = "*.md";
          run = "piper -- CLICOLOR_FORCE=1 glow -w=$w -s=dark \"$1\"";
        }
      ];
    };
  };

  programs.starship = {
    enable = true;
    settings = {
      add_newline = true;
      command_timeout = 1300;
      scan_timeout = 50;
      format = "$env_var $all";
      character = {
        success_symbol = "[](bold green) ";
        error_symbol = "[✗](bold red) ";
      };
      env_var.STARSHIP_DISTRO = {
        format = "[$env_value](white)";
        variable = "STARSHIP_DISTRO";
        disabled = false;
      };
      kubernetes = {
        disabled = false;
      };
    };
  };

  programs.zsh = {
    enable = true;
    initContent = lib.mkBefore ''
      if [[ "$(uname -s)" == "Linux" ]]; then
        distro=$(awk '/^ID=/' /etc/*-release | awk -F'=' '{ print tolower($2) }')
        case $distro in
            *kali*)                  ICON="ﴣ";;
            *arch*)                  ICON="";;
            *debian*)                ICON="";;
            *raspbian*)              ICON="";;
            *ubuntu*)                ICON="";;
            *elementary*)            ICON="";;
            *fedora*)                ICON="";;
            *coreos*)                ICON="";;
            *gentoo*)                ICON="";;
            *mageia*)                ICON="";;
            *centos*)                ICON="";;
            *opensuse*|*tumbleweed*) ICON="";;
            *sabayon*)               ICON="";;
            *slackware*)             ICON="";;
            *linuxmint*)             ICON="";;
            *alpine*)                ICON="";;
            *aosc*)                  ICON="";;
            *nixos*)                 ICON="";;
            *devuan*)                ICON="";;
            *manjaro*)               ICON="";;
            *rhel*)                  ICON="";;
            *)                       ICON="";;
        esac
      else
        ICON=""
      fi
      export STARSHIP_DISTRO="$ICON"
    '';
  };
}
