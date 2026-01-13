{
  lib,
  ...
}:
{
  programs = {
    starship = {
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
              *arch*)                  ICON="";;
              *debian*)                ICON="";;
              *raspbian*)              ICON="";;
              *ubuntu*)                ICON="";;
              *elementary*)            ICON="";;
              *fedora*)                ICON="";;
              *coreos*)                ICON="";;
              *gentoo*)                ICON="";;
              *mageia*)                ICON="";;
              *centos*)                ICON="";;
              *opensuse*|*tumbleweed*) ICON="";;
              *sabayon*)               ICON="";;
              *slackware*)             ICON="";;
              *linuxmint*)             ICON="";;
              *alpine*)                ICON="";;
              *aosc*)                  ICON="";;
              *nixos*)                 ICON="";;
              *devuan*)                ICON="";;
              *manjaro*)               ICON="";;
              *rhel*)                  ICON="";;
              *)                       ICON="";;
          esac
        fi
        if [[ $MACOS ]]; then
          ICON=""
        fi

        export STARSHIP_DISTRO="$ICON"
      '';
    };
  };
}
