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
          packages = with pkgs; [
            _1password-cli
            _1password-gui
          ];
        };

        manual.manpages.enable = false;

        # Add stuff for your user as you see fit:
        # programs.neovim.enable = true;
        # home.packages = with pkgs; [ steam ];

        # Enable home-manager and git
        programs.home-manager.enable = true;

        programs = {
          ssh = {
            enable = true;
            extraConfig = ''
              Host *
                  IdentityAgent ~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock
            '';
          };

          git = {
            enable = true;
            ignores = [ "*.swp" ];
            userName = name;
            userEmail = email;
            lfs = {
              enable = true;
            };

            # Set the specific key to use for signing
            signing = {
              key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICE/pXGITxyPntwU0eIxLlleA0OhtGikNx5T+b6fiVRg";
              signByDefault = true;
            };

            extraConfig = {
              gpg.format = "ssh";
              gpg.ssh.program = "${pkgs._1password-gui}/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
              init.defaultBranch = "main";
              core = {
                editor = "vim";
                autocrlf = "input";
              };
              # commit.gpgsign = true;
              pull.rebase = true;
              rebase.autoStash = true;
            };
          };
        };

        # Nicely reload system units when changing configs
        systemd.user.startServices = "sd-switch";

      };
  };
}
