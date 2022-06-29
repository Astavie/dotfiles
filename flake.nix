{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.05";

  inputs.home-manager.url = "github:rycee/home-manager/release-22.05";
  inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs";

  outputs = { self, home-manager, nixpkgs, ... }:
  
    let
      username = "astavie";

      stateVersion = "22.05";
      configurationRevision = if self ? rev then self.rev else null;

      mkSystem = { modules, system }:
        let
        in nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit username;
            inherit stateVersion;
            inherit configurationRevision;
          };
          modules =
            modules.hardware ++
            modules.system ++
            [home-manager.nixosModules.home-manager{
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.users.${username} = { modules, ... }: { imports = modules; };
                home-manager.extraSpecialArgs.modules = modules.home;
            }];
        };

    in {

      nixosConfigurations = {

        # VirtualBox demo of NixOS
        nixos = mkSystem {
          system = "x86_64-linux";

          modules.hardware = [
            ./hardware/vb_demo.nix
          ];
          modules.system = [
            ./system/default.nix
            ./system/vb.nix
          ];
          modules.home = [
            ./home/default.nix
            ./home/vb.nix
          ];
        };

      };

    };

}
