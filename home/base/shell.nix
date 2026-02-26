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
    settings = {
      theme = "github_dark";
    };
  };

  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    plugins = {
      faster-piper = pkgs.fetchFromGitHub {
        owner = "alberti42";
        repo = "faster-piper.yazi";
        rev = "main";
        sha256 = "sha256-m6ZiwA36lcdZORK3KIz4Xq3bs7mmtC6j62B/+BuDGAQ=";
      };
      toggle-pane = pkgs.yaziPlugins.toggle-pane;
      full-border = pkgs.yaziPlugins.full-border;
    };
    initLua = ''
      require("full-border"):setup {
        type = ui.Border.ROUNDED,
      }
    '';
    keymap = {
      mgr.prepend_keymap = [
        {
          on = "T";
          run = "plugin toggle-pane max-preview";
          desc = "Maximize or restore the preview pane";
        }
        {
          on = "<C-k>";
          run = "seek -20";
          desc = "Seek half page up";
        }
        {
          on = "<C-j>";
          run = "seek 20";
          desc = "Seek half page down";
        }
      ];
    };
    settings =
      {
        mgr.ratio = [
          1
          2
          5
        ];

        preview = {
          max_width = 1000;
          max_height = 1000;
        };

        plugin.prepend_previewers = [
          {
            url = "*.md";
            run = "faster-piper -- CLICOLOR_FORCE=1 glow -w=$w -s=dracula \"$1\"";
          }
        ];
      }
      // lib.optionalAttrs pkgs.stdenv.isDarwin {
        opener.typora_fullscreen = [
          {
            run = "open -a \"Typora\" %s; osascript -e 'tell application \"Typora\" to activate' -e 'delay 0.2' -e 'tell application \"System Events\" to keystroke \"f\" using {control down, command down}'";
            orphan = true;
            desc = "Open Typora Full Screen";
            for = "macos";
          }
        ];

        open.prepend_rules = [
          {
            url = "*.md";
            use = [
              "open"
              "edit"
              "reveal"
              "exif"
              "typora_fullscreen"
            ];
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
