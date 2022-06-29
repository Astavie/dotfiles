{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.05";

  inputs.home-manager.url = "github:rycee/home-manager/release-22.05";
  inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs";

  outputs = inputs @ { self, home-manager, nixpkgs, ... }: {

    homeManagerConfigurations = {
      "astavie" = home-manager.lib.homeManagerConfiguration {
        # system = "x86_64-linux";
        modules = [
          ./home/default.nix
          ./home/vb.nix
        ];
      };
    };

    nixosConfigurations = {

      nixos = nixpkgs.lib.nixosSystem {

        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./hardware/vb_demo.nix
          ./system/default.nix
          ./system/vb.nix
        ];

      };

    };

  };
}
