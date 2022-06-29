{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.05";

  outputs = inputs @ { self, nixpkgs, ... }: {

    nixosConfigurations = {

      terrestrial = nixpkgs.lib.nixosSystem {

        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./configuration.nix
        ];

      };
    };

  };
}
