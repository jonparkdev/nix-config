{
  description = "Jon's Nix Configurations";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-homebrew = {
      url = "github:zhaofengli-wip/nix-homebrew";
    };

    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };

    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };

    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      darwin,
      nix-homebrew,
      homebrew-core,
      homebrew-cask,
      homebrew-bundle,
      ...
    }@inputs:
    let
      user = "jonpark";

      # Darwin hosts configuration
      darwinHosts = {
        personal-macbook = {
          system = "aarch64-darwin";
          role = "personal";
          homeProfiles = [
            "laptop"
            "server-admin"
          ];
          enableLinuxBuilder = true;
        };
        work-macbook = {
          system = "aarch64-darwin";
          role = "work";
          homeProfiles = [
            "laptop"
            "work"
          ];
          enableLinuxBuilder = false;
        };
      };

      # NixOS hosts configuration (for future use)
      nixosHosts = {
        # homelab = { system = "x86_64-linux"; };
      };

      # Helper function to create Darwin configurations
      mkDarwinConfig =
        hostname:
        {
          system,
          role,
          homeProfiles,
          enableLinuxBuilder,
        }:
        darwin.lib.darwinSystem {
          inherit system;
          specialArgs = inputs // {
            inherit
              user
              hostname
              role
              homeProfiles
              enableLinuxBuilder
              ;
          };
          modules = [
            home-manager.darwinModules.home-manager
            nix-homebrew.darwinModules.nix-homebrew
            {
              nix-homebrew = {
                inherit user;
                enable = true;
                enableRosetta = true;
                taps = {
                  "homebrew/homebrew-core" = homebrew-core;
                  "homebrew/homebrew-cask" = homebrew-cask;
                  "homebrew/homebrew-bundle" = homebrew-bundle;
                };
                mutableTaps = false;
                autoMigrate = true;
              };
            }
            ./hosts/darwin/${hostname}
          ];
        };

      # Helper function to create NixOS configurations (for future use)
      mkNixosConfig = hostname: { system }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = inputs // {
            inherit user hostname;
          };
          modules = [
            home-manager.nixosModules.home-manager
            ./hosts/nixos/${hostname}
          ];
        };

    in
    {
      # Generate Darwin configurations for all Darwin hosts
      darwinConfigurations = builtins.mapAttrs mkDarwinConfig darwinHosts;

      # Generate NixOS configurations for all NixOS hosts (empty for now)
      nixosConfigurations = builtins.mapAttrs mkNixosConfig nixosHosts;
    };
}
