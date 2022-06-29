{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.05";

  inputs.home-manager.url = "github:rycee/home-manager/release-22.05";
  inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs";

  outputs = { self, home-manager, nixpkgs, ... }:
  
    let
      system = "x86_64-linux";
      stateVersion = "22.05";

      users."astavie" = { modules, ... }: {
        imports = [ ./home/default.nix ] ++ modules;
      };

    in {

      nixosConfigurations = {

        nixos = nixpkgs.lib.nixosSystem {

          inherit system;
          specialArgs = {
            inherit stateVersion;
            rev = if self ? rev then self.rev else null;
          };
          modules = [
            ./hardware/vb_demo.nix
            ./system/default.nix
            ./system/vb.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users = users;
              home-manager.extraSpecialArgs.modules = [ ./home/vb.nix ];
            }
          ];

        };

      };

    };
}
