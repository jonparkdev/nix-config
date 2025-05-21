{
    description = "Jon's NixOS Configuration";

    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";

        home-manager = {
            url = "github:nix-community/home-manager/release-24.11";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        darwin = {
            url = "github:nix-darwin/nix-darwin/nix-darwin-24.11";
            inputs.nixpkgs.follows = "nixpkgs";
        };
    };

    outputs = {
        self,
        nixpkgs,
        home-manager,
        ...
    } @ inputs: let
        darwinSystems = [ "aarch64-darwin" ];
    in {
        darwinConfigurations = nixpkgs.lib.genAttrs darwinSystems (system:
            darwin.lib.darwinSystem {
                inherit system;
                specialArgs = inputs;
                modules = [
                    home-manager.darwinModules.home-manager
                    ./hosts/darwin
                ];
            }
        );
    }
}
