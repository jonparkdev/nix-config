# This is your home-manager configuration file
{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  user,
  ...
}:
let
  name = "Jonathan Park";
  email = "accounts@jonpark.dev";
in
{
  users.users.${user} = {
    name = "${user}";
    home = "/Users/${user}";
  };

  home-manager = {
    useGlobalPkgs = true;

    # For details see: https://github.com/nix-community/home-manager/issues/1341#issuecomment-3256894180
    sharedModules = [
      (
        { config, pkgs, ... }:
        {
          targets.darwin.linkApps.enable = false;
        }
      )
    ];

    users.${user} =
      {
        pkgs,
        config,
        lib,
        ...
      }:
      {
        home = {
          enableNixpkgsReleaseCheck = false;
          # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
          stateVersion = "25.05";

          # Packages are not automatically symlink'd to MacOS ~/Applications directory
          # For details see: https://github.com/nix-community/home-manager/issues/1341#issuecomment-3256894180
          packages = with pkgs; [];
        };

        manual.manpages.enable = false;
        
        fonts.fontconfig.enable = true;

        # Add stuff for your user as you see fit:
        # programs.neovim.enable = true;
        # home.packages = with pkgs; [ steam ];

        # Enable home-manager and git
        programs.home-manager.enable = true;
     
        # programs.firefox.enable = true;
        # programs.firefox.package = (pkgs.wrapFirefox.override {
        #  libcanberra-gtk3 = pkgs.libcanberra-gtk2;
        # }) pkgs.firefox-unwrapped { };

        programs = {
          granted = {
            enable = true;
            enableZshIntegration = true;
          };

          vscode = {
            enable = true;
            mutableExtensionsDir = false;
            profiles.default.userSettings = {
              "editor.fontFamily" = "'JetbrainsMono Nerd Font' , Menlo, Monaco, 'Courier New', monospace";
              "editor.fontLigatures" = true;
            };
          };

          # No Darwin support
          # ghostty = {
          #   enable = true;
          # };

          starship = {
            enable = true;
            settings = {
              add_newline = true;
              command_timeout = 1300;
              scan_timeout = 50;
              format = "$env_var $all";
              character = {
                success_symbol = "[](bold green) ";
                error_symbol = "[✗](bold red) ";
              };
              # Shows an icon that should be included by zshrc script based on the distribution or os
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

          zsh = {
            enable = true;

            initContent = lib.mkBefore ''
              [ "$(uname -s)" = "Darwin" ] && export MACOS=1
              [ "$(uname -s)" = "Linux" ] && export LINUX=1 

              if [[ $LINUX ]]; then
                # find out which distribution we are running on
                distro=$(awk '/^ID=/' /etc/*-release | awk -F'=' '{ print tolower($2) }')

                # set an icon based on the distro
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
              fi
              if [[ $MACOS ]]; then
                ICON=""
              fi

              export STARSHIP_DISTRO="$ICON"
            '';
          };

          ssh = {
            enable = true;
            extraConfig = ''IdentityAgent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"'';
          
            # See https://home-manager-options.extranix.com/?query=programs.ssh.enableDefaultConfig&release=master for configuration details 
            enableDefaultConfig = false;
            matchBlocks."*" = {
              forwardAgent = false;
              addKeysToAgent = "no";
              compression = false;
              serverAliveInterval = 0;
              serverAliveCountMax = 3;
              hashKnownHosts = false;
              userKnownHostsFile = "~/.ssh/known_hosts";
              controlMaster = "no";
              controlPath = "~/.ssh/master-%r@%n:%p";
              controlPersist = "no";
            };
          };
          

          git = {
            enable = true;

            settings = {
              user.name = name;
              user.email = email;

              gpg.format = "ssh";
              gpg.ssh.program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
              init.defaultBranch = "main";
              core = {
                editor = "vim";
                autocrlf = "input";
              };
              # commit.gpgsign = true;
              pull.rebase = true;
              rebase.autoStash = true;
            };

            ignores = [ "*.swp" ];
            
            lfs = {
              enable = true;
            };

            # Set the specific key to use for signing
            signing = {
              key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICE/pXGITxyPntwU0eIxLlleA0OhtGikNx5T+b6fiVRg";
              signByDefault = true;
            };
          };
        };

        # Nicely reload system units when changing configs
        systemd.user.startServices = "sd-switch";

      };
  };
}
